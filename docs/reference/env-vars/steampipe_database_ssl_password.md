---
title: STEAMPIPE_DATABASE_SSL_PASSWORD
sidebar_label: STEAMPIPE_DATABASE_SSL_PASSWORD
---


# STEAMPIPE_DATABASE_SSL_PASSWORD

Sets the `server.key` passphrase.  By default, this value is empty because of steampipe that generates a certificate without passphrase.  To use your own certificate, set the `STEAMPIPE_DATABASE_SSL_PASSWORD` variable and start the steampipe service.

Note the following:
- If the `--database-ssl-password` is passed to `steampipe service start`, steampipe will behave as if the key were protected by a passphrase.
- The `server.key` content **must** contains [Proc-Type](https://datatracker.ietf.org/doc/html/rfc1421#section-4.6.1.1) and [DEK-Info](https://datatracker.ietf.org/doc/html/rfc1421#section-4.6.1.3) headers.

## Usage 
Start the steampipe service with a custom password:

```bash
export STEAMPIPE_DATABASE_SSL_PASSWORD=MyPassPhrase
steampipe service start
```

