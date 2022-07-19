---
id: cis-v140-aws-benchmark
title: "What's new in the CIS v1.4 benchmark for AWS"
category: Announcement
description: "Analysis of the changes in the CIS v1.4 benchmark for AWS"
summary: "Analysis of the changes in the CIS v1.4 benchmark for AWS"
author:
  name: David Boeke
  twitter: "@boeke"
publishedAt: "2021-06-11T14:00:00"
durationMins: 6
image: /images/blog/cis-14-console-output.jpg
slug: cis-v140-aws-benchmark
schema: "2021-01-08"
---

CIS just released an updated version (v1.4) of their CIS benchmark for AWS, it was exciting to see that the Steampipe open source community was the first out with [support for the new controls](https://hub.steampipe.io/mods/turbot/aws_compliance/controls/benchmark.cis_v140).

## Analysis of the key changes 

 - **New mapping of all of the benchmark controls to CIS Controls v8** — We noticed when working on the 1.3 benchmark that there were inconsistencies with the previous mappings, so good to see they were all updated, nice!

 - **2.1.3 Enforce MFA delete on buckets** — Reading the policy intent shows that this is recommended for "sensitive and classified" buckets, but automated scanning will now likely check against all buckets. You could easily adjust Steampipe controls to check for buckets matching a naming pattern or with specific tags:

<div className="row mb-5 mt-5"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-7">
    <Terminal title="steampipe cli">
      <TerminalCommand>
        {`
select
  arn as "Buckets without MFA Delete"
from
  aws_s3_bucket
where
  not versioning_mfa_delete
  and tags->>'data-class' in ('med', 'high');
        `}
      </TerminalCommand>
      <TerminalResult>
        {`
+---------------------------------------+
| Buckets without MFA Delete            |
+---------------------------------------+
| arn:aws:s3:::dmi-employee-data        |
| arn:aws:s3:::dmi-data-lake-metadata   |
| arn:aws:s3:::paper-competitive-intel  |
| arn:aws:s3:::test-principal-wildcard  |
+---------------------------------------+
        `}
      </TerminalResult>
    </Terminal>
  </div>
</div>

 - **2.3.1 Enforce RDS encryption** — Most surprising thing about this to me is that this is the first RDS check for CIS...  A lot more opportunity space here.

 - **3.5 Implementing AWS config in all regions** — Was moved to a level 2 control because there is additional cost associated with enabling it.

 - **1.12 Unused credentials time limit changed from 90 days to 45** — This stemmed from new guidance in CIS Controls v8. It always struck me that 90 days is arbitrarily long for this, 6 weeks seems like a reasonable time period that balances productivity vs security a bit better.

 - **2.1.5 Ensure Amazon S3 has been discovered, classified and secured 'when required'** — This is a new recommendation to ensure all data is classified via automated analysis. The remediation section just shows how to enable Amazon Macie for your buckets, but many orgs will have their own tooling/approach here.

The rest of the changes were mainly typos and changes to audit/remediation procedures. The open source [Steampipe AWS compliance mod has codified the changes in this repo](https://github.com/turbot/steampipe-mod-aws-compliance).  If you want to run a quick v1.4 scan on your account, clone the repo locally and run from the CLI:

<div className="row mb-5 mt-5"> 
  <div className="col col-0 col-lg-1"></div>
  <div className="col col-12 col-lg-9">
  <Terminal title="bash">
    <TerminalCommand withPrompt={false} enableCopyToClipboard={false}>
      {`
git clone https://github.com/turbot/steampipe-mod-aws-compliance.git
cd steampipe-mod-aws-compliance
steampipe check benchmark.cis_v140
      `}
    </TerminalCommand>
  </Terminal>
  </div>
</div>

<img width="100%" className="center-block" src="/images/blog/aws_cis_v140_console.png" />

## We love open source!

Steampipe now delivers a full suite of tools to build, execute and share cloud configuration, compliance, and security frameworks using SQL, HCL and a little elbow grease! We would love your help to expand the open source documentation and control coverage for CIS, PCI, HIPAA, NIST… and the best way to get started is to [join our new Slack workspace](https://steampipe.io/community/join) and raise your hand; we would love to talk to you!