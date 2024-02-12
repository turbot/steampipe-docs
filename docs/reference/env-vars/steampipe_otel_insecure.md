---
title: STEAMPIPE_OTEL_INSECURE
sidebar_label: STEAMPIPE_OTEL_INSECURE
---
# STEAMPIPE_OTEL_INSECURE

Set the `STEAMPIPE_OTEL_INSECURE` to bypass the default secure connection requirements when connecting to an OpenTelemetry server. This enables steampipe to communicate with the OpenTelemetry server without needing SSL/TLS encryption. This can be useful for local testing or when operating within a secure, isolated network where encryption may not be deemed necessary.

## Usage

If you are connecting to a local insecure OpenTelemetry server:

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:16686/
export STEAMPIPE_OTEL_INSECURE=true
```