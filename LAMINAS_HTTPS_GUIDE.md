# Laminas development HTTPS guide

This guide describes how to turn the disposable Laminas EC2 deployment into a usable development instance with trusted HTTPS.

The recommended design is:

```text
Internet
   |
   | HTTPS :443
   v
Caddy reverse proxy
   |
   | Docker network :80
   v
Laminas application
```

Caddy obtains and renews a trusted certificate automatically. The Laminas container remains an internal HTTP service and does not need to manage TLS itself.

## 1. Use a stable public address

Allocate an AWS Elastic IP and associate it with the EC2 instance. A normal EC2 public IPv4 address can change when an instance is stopped and started. An Elastic IP remains associated with the AWS account until it is released.

AWS charges for public IPv4 addresses, including Elastic IP addresses, so release the address when this disposable environment is finished.

## 2. Create a DNS record

At the DNS provider for a domain you control, create an A record such as:

```text
laminas-dev.example.com  A  <Elastic-IP>
```

Verify that it resolves to the instance before requesting a certificate:

```bash
dig +short laminas-dev.example.com
```

The DNS result should be the Elastic IP assigned to the instance.

## 3. Update the security group

Allow these inbound rules:

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 22 | Your IP address | SSH administration |
| TCP | 80 | `0.0.0.0/0` | HTTP and certificate validation |
| TCP | 443 | `0.0.0.0/0` | HTTPS |

Port 80 can later redirect all application traffic to HTTPS, but it should remain reachable for normal ACME HTTP validation.

## 4. Put Caddy in Compose

The current application maps its container port directly to host port 80. Change that mapping so the app is reachable only through the Docker network:

```yaml
  app:
    ports:
      - "127.0.0.1:8080:80"
```

Add a Caddy service to `laminas-dev/compose.yaml`:

```yaml
  caddy:
    image: caddy:2
    restart: unless-stopped
    depends_on:
      - app
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config

volumes:
  db-data:
  caddy-data:
  caddy-config:
```

Create `laminas-dev/Caddyfile`:

```caddyfile
laminas-dev.example.com {
    reverse_proxy app:80
}
```

Replace `laminas-dev.example.com` with the actual DNS name. Caddy uses the hostname to request the certificate and proxies requests to the `app` service over the Compose network.

Start the proxy after DNS is resolving:

```bash
docker compose up -d
docker compose logs -f caddy
```

Then test:

```bash
curl -I https://laminas-dev.example.com/
```

The application should be reachable at:

```text
https://laminas-dev.example.com/
```

## 5. Important development safeguards

- Keep the site protected from general public use if it contains development data.
- Restrict SSH to your own IP address.
- Use temporary development credentials and never reuse production secrets.
- Do not commit `.env`, private keys, Caddy data, or database volumes.
- Remember that HTTPS encrypts traffic; it does not make the application or its development data public-safe.
- Destroy the instance and release the Elastic IP when the test environment is no longer needed.

## IP-only certificate option

Let’s Encrypt now supports IPv4 and IPv6 address certificates, but these certificates are short-lived—approximately six days—and require automated renewal. This is possible for a temporary lab, but a DNS name with a normal automated certificate is easier to operate and better suited to a development instance.

References:

- [AWS EC2 stop/start IP behavior](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/how-ec2-instance-stop-start-works.html)
- [AWS Elastic IP addresses](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)
- [Let’s Encrypt IP address certificates](https://letsencrypt.org/2026/01/15/6day-and-ip-general-availability)
