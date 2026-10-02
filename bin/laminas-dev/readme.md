The intended flow is now:

```
export EC2_HOST=<EC2-IP-or-DNS>
export EC2_USER=ec2-user

bin/laminas-dev/local/01-package-stack.sh
bin/laminas-dev/local/02-copy-stack.sh
bin/laminas-dev/local/03-copy-payloads.sh
```
