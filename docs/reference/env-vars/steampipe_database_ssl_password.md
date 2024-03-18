---
title: STEAMPIPE_DATABASE_SSL_PASSWORD
sidebar_label: STEAMPIPE_DATABASE_SSL_PASSWORD
---


# STEAMPIPE_DATABASE_SSL_PASSWORD

Sets the `server.key` passphrase.  By default, Steampipe generates a certificate without a passphrase; you only need to set this variable if you use a custom certificate that is protected by a passphrase.

To use a custom certificate with a passphrase:
- `STEAMPIPE_DATABASE_SSL_PASSWORD` must be set when you start Steampipe.
- The `server.key` content **must** contain [Proc-Type](https://datatracker.ietf.org/doc/html/rfc1421#section-4.6.1.1) and [DEK-Info](https://datatracker.ietf.org/doc/html/rfc1421#section-4.6.1.3) headers.

## Usage 
Start the Steampipe service with a custom password:

```bash
export STEAMPIPE_DATABASE_SSL_PASSWORD=MyPassPhrase
steampipe service start
```