---
title: STEAMPIPE_OTEL_INSECURE
sidebar_label: STEAMPIPE_OTEL_INSECURE
---
# STEAMPIPE_OTEL_INSECURE

To utilize a local, insecure OpenTelemetry server, please configure your environment by setting the `STEAMPIPE_OTEL_INSECURE` environment variable.

Set the `STEAMPIPE_OTEL_INSECURE` to bypass the default secure connection requirements. This enables steampipe to communicate with the OpenTelemetry server without needing SSL/TLS encryption. This can be useful for local testing or when operating within a secure, isolated network where encryption may not be deemed necessary.

## Usage

If you are connecting to a local insecure OpenTelemetry server:

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:16686/
export STEAMPIPE_OTEL_INSECURE=true
```