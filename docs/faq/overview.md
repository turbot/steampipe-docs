---
title:  FAQ
sidebar_label: FAQ
---

# FAQ

## Where is the Dockerfile or container example?

Steampipe can be run in a containerized setup. We run it ourselves that way as part of [Turbot Pipes](https://turbot.com/pipes). However, we don't publish or support a container definition because:

* The CLI is optimized for developer use on the command line.
* Everyone has specific goals and requirements for their containers.
* Container setup requires various mounts and access to configuration files.
* It's hard to support containers across many different environments.

We welcome users to create and share open-source container definitions for Steampipe.