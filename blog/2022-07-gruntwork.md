---
id: gruntwork
title: "Gruntwork partners with Steampipe to deliver continuous compliance as a service"
category: Partnerships
description: "Steampipe’s openness and support for AWS CIS v1.4.0 were key factors"
summary: "Steampipe’s openness and support for AWS CIS v1.4.0 were key factors"
author:
  name: Steampipe and Gruntwork
  twitter: "@steampipeio"
publishedAt: "2022-07-13T14:00:00"
durationMins: 5
image: "/images/blog/2022-07-gruntwork/opener.png"
slug: gruntwork
schema: "2021-01-08"
---

Last month Gruntwork announced [Steampipe Runner](https://blog.gruntwork.io/gruntwork-newsletter-june-2022-6f45c8de8d2b), a new module that enables their customers to use Steampipe mods to continuously check AWS accounts for compliance with CIS or other benchmarks. We asked the Gruntwork team to tell us more about what the company does and how Steampipe adds value.

"Gruntwork offers an [infrastructure-as-code library](https://gruntwork.io/infrastructure-as-code-library)," says cofounder Jim Brikman, "that provides reusable, battle-tested, production-grade infrastructure code (Terraform, Go, Bash, etc) for AWS. The modules in the library set you up with AWS and DevOps best practices and compliance standards, such as the AWS Well-Architected Framework and the CIS AWS Foundations Benchmark, out-of-the-box."

For example, it's a best practice to separate management and application VPCs, and subdivide those VPCs into public and private subnet tiers, with strict routing rules and network ACLs. You get all of this out-of-the-box with Gruntwork’s VPC modules.

The [reference architecture](https://gruntwork.io/reference-architecture) builds on this library of modules to define a complete, end-to-end tech stack — which includes networking, orchestration (EKS, ECS, EC2), data storage (RDS, ElastiCache, S3), monitoring (dashboards, log aggregation, alerts), CI / CD, and more, all managed as code — that Gruntwork can deploy into a customer's AWS accounts in about one day. One flavor of the reference architecture focuses on meeting objective compliance standards out of the box. "We can deploy a CIS-compliant reference architecture," says principal software engineer Yoriyasu Yano, "that passes the CIS AWS Foundations benchmark out of the box."

Initially Gruntwork used the AWS Security Hub as the objective way to check for that compliance. But while the [CIS Benchmark for CIS Amazon Web Services Foundations Benchmark](https://docs.aws.amazon.com/audit-manager/latest/userguide/CIS-1-2.html) is at version 1.4.0, Security Hub only checks for compliance with version 1.2.0. Since the Gruntwork reference architecture targets version 1.4.0, there was a gap that Steampipe -- which supports both v1.3.0 and v1.4.0 -- was enlisted to fill. 

Gruntwork delivers the Steampipe Runner using its [ECS Deploy Runner](https://docs.gruntwork.io/reference/services/ci-cd-pipeline/ecs-deploy-runner), and in that context allows only certain Steampipe commands and mods (public or private) as specified by the operator. The Steampipe Runner launches the [CIS v1.4.0  benchmark](https://hub.steampipe.io/mods/turbot/aws_compliance/controls/benchmark.cis_v140), exports to [ASFF](https://steampipe.io/docs/reference/cli/check#output-formats) (AWS Security Finding Format), then pushes the findings to Security Hub. 

Another reason to choose Steampipe was openness and extensibility. "We wanted to be able to add additional checks, or fix bugs, or improve error messages," Yori says. "With Steampipe we felt we could contribute back." And in fact that's already happening. What's more, Steampipe is readily extensible by Gruntwork’s customers, who can define their own checks using easy-to-learn SQL.

Steampipe's comprehensive suite of benchmarks was another draw. Security Hub supports three: AWS Foundational Security Best Practices, CIS, and PCI DSS. Steampipe adds FedRAMP, GDPR, HIPAA, SOC 2, and more. SOC 2 was especially interesting because Gruntwork's customers are asking for a reference architecture that complies with SOC 2, so Gruntwork needed an objective standard that captured and checked for SOC 2 requirements. "We'll use Steampipe," Yori says, "to help us identify the gaps between our current reference architecture and SOC 2."

We love the idea of continuous compliance as a service, and we're thrilled that Steampipe will help Gruntwork deliver it. 



