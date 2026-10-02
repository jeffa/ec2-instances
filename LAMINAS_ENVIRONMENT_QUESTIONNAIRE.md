# Laminas environment questionnaire

Use this checklist to gather the information needed to build the first Laminas test server and design a reusable development/integration environment.

Do not include passwords, API keys, private keys, or other secrets in this document. Record secret names and where they will be supplied instead.

## 1. First environment

What should we build first?

```text
Environment type: ______________________________________________
Primary purpose: ________________________________________________
Expected lifetime: ______________________________________________
Who needs access: _______________________________________________
Target AWS region: ______________________________________________
```

- [ ] Individual developer environment
- [ ] Shared development server
- [ ] Integration/test server
- [ ] Other: _________________________________________________

Should the first server be disposable, persistent, or recreated regularly?

```text
Answer: _________________________________________________________
```

## 2. Application source

Where will the application source come from?

```text
Source archive/repository: ______________________________________
Branch or release: ______________________________________________
Build instructions or deployment notes: _________________________
```

- [ ] The source includes `composer.json`
- [ ] The source includes `composer.lock`
- [ ] The source includes the Laminas `public/` directory
- [ ] The source includes application configuration
- [ ] The source includes uploaded/static files required at runtime

If any item is missing, explain how it is currently supplied:

```text
Answer: _________________________________________________________
```

## 3. PHP and Composer

```text
Production PHP version: __________________________________________
Approved test PHP version: _______________________________________
Composer version, if fixed: ______________________________________
Required PHP extensions: _________________________________________
Required OS packages/libraries: __________________________________
```

List any commands that must run after Composer installation:

```text
Commands: _______________________________________________________
```

Which dependencies are needed at runtime?

- [ ] Production dependencies only
- [ ] Development dependencies too
- [ ] PHPUnit or test tooling
- [ ] Psalm/static analysis
- [ ] Code-style tooling
- [ ] Other: _________________________________________________

## 4. Application startup and web serving

```text
Application document root: ______________________________________
Required startup command: _______________________________________
Required working directory: _____________________________________
Required web-server rewrite rules: _______________________________
Required application environment name: ___________________________
```

- [ ] Apache is acceptable
- [ ] nginx is required
- [ ] PHP-FPM is required
- [ ] PHP’s built-in server is acceptable for development only
- [ ] Other: _________________________________________________

Does the application require a special Laminas cache/configuration command?

```text
Command: _______________________________________________________
When it must run: _______________________________________________
```

## 5. Database

```text
Database engine: ________________________________________________
Production version: ______________________________________________
Test version: __________________________________________________
Database name: _________________________________________________
Character set/collation: ________________________________________
SQL mode requirements: __________________________________________
Database configuration file(s): _________________________________
```

How is the database initialized?

- [ ] Fresh schema migrations
- [ ] SQL dump restore
- [ ] Fixtures/seed data
- [ ] Combination of the above
- [ ] Other: _________________________________________________

```text
Initialization commands/order: __________________________________
__________________________________________________________________
```

Database dump details:

```text
Format: _________________________________________________________
Approximate size: _______________________________________________
Compressed: ____________________________________________________
Contains real client/customer data: ______________________________
Anonymization required: _________________________________________
Known import issues: ____________________________________________
```

Never place database passwords in this questionnaire or in the source archive. Describe where the application expects the values and how they can be overridden:

```text
Configuration mechanism: ________________________________________
Variable/file names: ____________________________________________
```

## 6. External services and scheduled work

List every service the application calls or expects:

| Service | Required? | Test endpoint/account | Credentials supplied by | Notes |
|---|---|---|---|---|
| Email/SMTP | | | | |
| External API | | | | |
| Object/file storage | | | | |
| Payment/service provider | | | | |
| Queue/cache | | | | |
| Other | | | | |

Does the application require background work?

```text
Workers: ________________________________________________________
Cron/scheduled tasks: ____________________________________________
Queue technology: ________________________________________________
How often: ______________________________________________________
```

## 7. Runtime data and filesystem

Which directories must be writable by the web process?

```text
Directories: ___________________________________________________
Purpose: _______________________________________________________
```

Which data must survive container recreation?

- [ ] Database
- [ ] User uploads
- [ ] Generated reports/files
- [ ] Application cache
- [ ] Logs
- [ ] None; everything can be recreated
- [ ] Other: _________________________________________________

## 8. Networking and access

```text
Expected URL/hostname: __________________________________________
HTTP required: __________________________________________________
HTTPS required: _________________________________________________
Allowed browser/source IPs: ______________________________________
SSH allowed from: _______________________________________________
```

- [ ] Public HTTP is acceptable for the temporary lab
- [ ] Access must be private/VPN-only
- [ ] A DNS name is available
- [ ] TLS certificate is available
- [ ] No public database access

## 9. Security and data handling

```text
Data classification: ____________________________________________
Can production data be copied to AWS? ____________________________
Required anonymization rules: ___________________________________
Required retention period: ______________________________________
Who may access the server: ______________________________________
```

- [ ] No secrets in Git
- [ ] No production credentials in the lab
- [ ] Separate test credentials are available
- [ ] Database dump is safe for development
- [ ] Database dump needs sanitizing
- [ ] Logs may contain sensitive data
- [ ] Logs need redaction or restricted access

## 10. Reusable image and environment strategy

Which workflow do you want for each environment?

| Environment | Source workflow | Database workflow | Expected lifetime |
|---|---|---|---|
| Developer | | | |
| Shared development | | | |
| Integration | | | |
| Demo | | | |

Choose the preferred application delivery method:

- [ ] Developers edit a mounted source directory
- [ ] Servers pull a prebuilt Docker image
- [ ] CI builds and publishes Docker images
- [ ] Terraform/Ansible copies a source tarball
- [ ] Undecided

```text
Preferred image registry: ________________________________________
Image naming/tagging convention: _________________________________
CI system: ______________________________________________________
Who can publish images: _________________________________________
```

How should new environments be created?

- [ ] One documented manual command
- [ ] Terraform command plus Compose
- [ ] An automated CI workflow
- [ ] A reusable Terraform module
- [ ] A reusable AMI as well as a Docker image
- [ ] Other: _________________________________________________

## 11. Acceptance checks

What must be true before the environment is considered working?

- [ ] Application homepage loads
- [ ] User login works
- [ ] Database reads work
- [ ] Database writes work
- [ ] File uploads work
- [ ] Email is captured or delivered safely
- [ ] Background jobs run
- [ ] Automated tests pass
- [ ] Health-check endpoint responds
- [ ] Logs are accessible
- [ ] Environment can be destroyed and recreated
- [ ] Other: _________________________________________________

Additional acceptance requirements:

```text
__________________________________________________________________
__________________________________________________________________
```

## 12. Open questions and notes

```text
__________________________________________________________________
__________________________________________________________________
__________________________________________________________________
```
