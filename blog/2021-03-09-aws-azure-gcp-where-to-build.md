---
id: aws-azure-gcp-where-to-build
title: "Analysis of Cloud Provider Market Share – 2021"
category: Research
description: "Using developer interest in infrastructure as code tools to gauge popularity of cloud providers."
summary: "Using developer interest in infrastructure as code tools to gauge popularity of cloud providers."
author:
  name: David Boeke
  twitter: "@boeke"
publishedAt: "2021-03-08T14:00:00"
durationMins: 9
image: /images/blog/2021-03-09-aws-azure-gcp-where-to-build/hero.jpg
slug: aws-azure-gcp-where-to-build
schema: "2021-01-08"
---

Steampipe is an open source tool that allows you to query your cloud infrastructure with SQL. While we built it for ourselves, and our primary use case was AWS, we decided to build a robust plugin capability and to support multiple cloud providers from day one.

As we neared the launch date we had to make difficult trade-off decisions on what would be in-scope for the release. This included deciding which plugins we would focus on first. Gauging the size of community around each of the cloud platforms helped us make that a data-based decision, and we thought publishing what we found might be insightful to others.

## Infrastructure as Code Market Share

If you are building cloud infrastructure in 2021, you are building `infrastructure as code` using a declarative templating language. Let’s see what we can learn by following the developers and the development community around these tools.

First Party Tools from the Cloud Vendors:

- **AWS**: [CloudFormation](https://aws.amazon.com/cloudformation/)
- **Azure**: [Resource Manager](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
- **GCP**: [Deployment Manager](https://cloud.google.com/deployment-manager)
- **Alibaba Cloud**: [Resource Orchestration Service (ROS)](https://www.alibabacloud.com/product/ros)
- **Oracle Cloud Infrastructure**: [Resource Manager](https://www.oracle.com/devops/resource-manager/)
- **DigitalOcean**: [Not proprietary](https://www.digitalocean.com/community/conceptual_articles/infrastructure-as-code-explained)

Each of the cloud service providers has a github repo with example templates to serve as starting guides for your development. 

| Repo | # Stars | # Temp | Contrib | Other Repos |
| --- | --- |  --- | --- |  --- | 
| [Azure/azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates) | 9.6k | 1,000 | 1,027 | 582 |
| [awslabs/aws-cloudformation-templates](https://github.com/awslabs/aws-cloudformation-templates) | 2.8k | 60* | 61 | 5,031 |
| [GoogleCloudPlatform/deploymentmanager-samples](https://github.com/GoogleCloudPlatform/deploymentmanager-samples) | 820 | 70 | 98 | 50 |
| [aliyun/ros-templates](https://github.com/aliyun/ros-templates) | 13 | 20 | 3 | 5 |
| [oracle-quickstart](https://github.com/oracle-quickstart) | 28 | 134 | 9 | 21 |
| [do-community/ansible-playbooks](https://github.com/do-community/ansible-playbooks) | 280 | 6 | 2 | 140 |

It is curious that **AWS** does not open source all of their templates, they have a few hundred more templates available in docs:
- [AWS CloudFormation sample templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-sample-templates.html)
- [Amazon Quickstarts](https://aws.amazon.com/quickstart/)

**Azure** has done well to create an open source community hub around resource manager, while Amazon has allowed a long tail of smaller repositories. I prefer Azure’s approach here, as it is more likely (especially if new to the platform) that you will be able to join, contribute and have people find your work.

**Google** doesn’t seem to have a strategy to promote, or a community that cares much about Deployment Manager (there isn’t even a github tag available to search on). Most of the devs doing infrastructure as code on GCP must be using Terraform.

**Oracle** has done a significant amount of first party work to create infrastructure templates and publish them in advance of building the larger community. 

**DigitalOcean** actually has a thriving open source community with 140 repositories that have some type of example, but their concept of infrastructure as code is focused primarily on the operating system vs broader IaaS configuration.

## Search Statistics

We can get an initial feel for the relative popularity of these platforms using Google Search Trends:

<div className="row mb-1 mt-4"> 
  <div className="col col-12 col-lg-4 d-none d-lg-block">
    <h2 className="pt-5">There is a huge drop off of interest across all platforms in Q4 last year.</h2>
  </div>
  <div className="col col-12 col-lg-8">
    <img width="100%" src="/images/blog/2021-03-09-aws-azure-gcp-where-to-build/cloud-search-trends.png" />
  </div>
  <div className="col col-12 col-lg-8">
    <img width="100%" src="/images/blog/2021-03-09-aws-azure-gcp-where-to-build/cloud-search-trends-native-iac.png" />
  </div>
  <div className="col col-12 col-lg-4 d-none d-lg-block">
    <h2 className="pt-5">CloudFormation's popularity eclipses that of other native tools.</h2>
  </div>
</div>
Cloudformation has a huge advantage over the other platforms native tools. Let's see if Terraform helps level the playing field.


## Terraform Usage as a Surrogate Metric

When building infrastructure as code, Terraform is the 800 lb gorilla in the room. Operating across all cloud providers their open source repos and developer communities dwarf those of the first party clients. Terraform’s tooling works across all the cloud providers due to their plugin architecture, and we can learn quite a bit from stargazing the various plugin repositories.


<img width="100%" src="/images/blog/2021-03-09-aws-azure-gcp-where-to-build/tf-star-chart.png" />


### Terraform Providers by the Numbers

<div className="row mb-1 mt-4"> 
  <div className="col col-12 col-md-8 col-xl-8">

| Repo | # Downloads | # Stars | # Contrib |
| --- | --- | --- | --- |
| [terraform-provider-aws](https://registry.terraform.io/providers/hashicorp/aws/latest) | 268.2M | 5.5k | 1,744 |
| [terraform-provider-azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | 41.0M | 2.3k | 800 |
| [terraform-provider-google](https://registry.terraform.io/providers/hashicorp/google/latest) | 38.4M | 1.3k | 431 |

  </div>
  <div className="col col-12 col-lg-4 d-none d-lg-block">
    <h2 className="pt-2">AWS is 6.5x larger on Terraform</h2> (and that is on top of their CloudFormation numbers.)
  </div>
</div>

It is clear from these metrics that all three hypercloud companies have massive user bases and healthy growth curves in terms of usage of infrastructure as code tools. Microsoft recovered from an early slow start and has been on a higher growth trajectory since Q1 2019, but Amazon’s lead is real and it continues to grow. 


### Alternative Clouds 


| Repo | # Downloads | # Stars | # Contrib |
| --- | --- | --- | --- |
| terraform-provider-oci | 1.4M | 396 | 69 |
| terraform-provider-digitalocean | 202K | 294 | 119 |
| terraform-provider-alicloud | 174K | 334 | 98 |


It is great to see healthy active communities around each of these platforms, but combined the alternative platforms are barely 1/20th of the usage of even GCP at this stage. 

## What can your questions tell us?

When you are working with a technical platform, you are going to have questions, and the number of questions generally correlate with an increased number of developers and increased usage of the platform. We will use data from [Stack Overflow](https://stackoverflow.com) in this section, specifically looking at the number of questions that are tagged with specific categories.

Stack Overflow categorizes questions based on a tagging system. Here are results for questions tagged with each cloud service provider's name:


| Cloud Service | # Questions |
| --- | --- |
| [[amazon-web-services]](https://stackoverflow.com/questions/tagged/amazon-web-services) | 112,653 |
| [[azure]](https://stackoverflow.com/questions/tagged/azure) | 101,381 |
| [[google-cloud-platform]](https://stackoverflow.com/questions/tagged/google-cloud-platform) | 28,986 |
| [[digital-ocean]](https://stackoverflow.com/questions/tagged/digital-ocean) | 3,120 |
| [[oracle-cloud-infrastructure]](https://stackoverflow.com/questions/tagged/oracle-cloud-infrastructure) | 303 |
| [[google-deployment-manager]](https://stackoverflow.com/questions/tagged/google-deployment-manager) | 217 |
| [[alibaba-cloud]](https://stackoverflow.com/questions/tagged/alibaba-cloud) | 192 |

<br />

The Azure numbers being on par with AWS seemed surprising given we didn’t see that in other places, but it makes more sense when you realize that there are things like `Azure DevOps` and `Azure AD` so `Azure` represents more than just PaaS and IaaS. lets see if we can narrow down to our target audience by looking specifically at questions related to infrastructure as code tools:

| Stack Overflow Tag | # Questions |
| --- | --- |
| [[terraform]](https://stackoverflow.com/questions/tagged/terraform) | 7,858 |
| [[amazon-cloudformation]](https://stackoverflow.com/questions/tagged/amazon-cloudformation) | 5,840 |
| [[terraform]](https://stackoverflow.com/questions/tagged/terraform) [[amazon-web-services]](https://stackoverflow.com/questions/tagged/amazon-web-services) | 2,280 |
| [[azure-resource-manager]](https://stackoverflow.com/questions/tagged/azure-resource-manager) | 2,135 |
| [[terraform]](https://stackoverflow.com/questions/tagged/terraform) [[azure]](https://stackoverflow.com/questions/tagged/azure) | 786 |
| [[terraform]](https://stackoverflow.com/questions/tagged/terraform) [[google-cloud-platform]](https://stackoverflow.com/questions/tagged/google-cloud-platform) | 424 |
| [[google-deployment-manager]](https://stackoverflow.com/questions/tagged/google-deployment-manager) | 217 |
| [[terraform]](https://stackoverflow.com/questions/tagged/terraform) [[digital-ocean]](https://stackoverflow.com/questions/tagged/digital-ocean) | 31 |
| [[terraform]](https://stackoverflow.com/questions/tagged/terraform) [[oracle-cloud-infrastructure]](https://stackoverflow.com/questions/tagged/oracle-cloud-infrastructure) | 16 |
| [[alibaba-cloud]](https://stackoverflow.com/questions/tagged/alibaba-cloud) [[terraform]](https://stackoverflow.com/questions/tagged/terraform) | 13 |


These numbers align more closely with the relative size of the platforms we have seen in other communities. 

## Karma Counts

The last area we considered in our research was the size of the fan base for each cloud platform. Both Twitter and Reddit give us an easy way to measure the size of the social graph for these companies and the cloud platforms themselves:

<div className="row mb-1 mt-4"> 
  <div className="col col-12 col-md-6 col-xl-6">

| Subreddit | # Members |
| --- | --- |
| [r/aws](https://reddit.com/r/) | 161,000 |
| [r/azure](https://reddit.com/r/azure) | 66,600 |
| [r/googlecloud](https://reddit.com/r/googlecloud) | 20,900 |
| [r/terraform](https://reddit.com/r/terraform) | 15,100 |
| [r/cloudcomputing](https://reddit.com/r/cloudcomputing) | 14,700 |
| [r/cloud](https://reddit.com/r/cloud) | 10,200 |
| [r/digital_ocean](https://reddit.com/r/digital_ocean) | 2,100 |
| [r/oraclecloud](https://reddit.com/r/oraclecloud) | 1,100 |
| [r/AlibabaCloud](https://reddit.com/r/AlibabaCloud) | 191 |

A subreddit is a community of people on [Reddit](https://reddit.com) dedicated to sharing information and news on a given topic. The size of the subreddit indicates the number of people who are members of that community.
</div>
<div className="col col-12 col-md-6 col-xl-6">

| Twitter | Followers |
| --- | --- |
| [@awscloud](https://twitter.com/awscloud) | 1,800,000 |
| [@azure](https://twitter.com/azure) | 799,500 |
| [@googlecloud](https://twitter.com/googlecloud) | 290,900 |
| [@digitalocean](https://twitter.com/digitalocean) | 205,500 |
| [@oraclecloud](https://twitter.com/oraclecloud) | 81,200 |
| [@hashicorp](https://twitter.com/hashicorp) | 66,000 |
| [@alibaba_cloud](https://twitter.com/alibaba_cloud) | 61,800 |

Kudo’s to the @digitalocean twitter team, they are hitting way above expectations given their relative size.

</div>
</div>


## Conclusions

Our analysis of this data gave our development team confidence to deep dive on AWS and Azure first. For the broader cloud providers, we made sure we have coverage, but leave a lot of room for the communities around these tools to jump in and fill the remaining gaps. One of the brilliant parts of open source is that our community can contribute and extend where they have passion.

Using Steampipe we can query our embedded PostgreSQL database to see current coverage across cloud providers:


   <Terminal mode="light" title="">
      <TerminalCommand >
    {`
select
  split_part(table_name, '_', 1) as cloud,
  count(*) as tables
from
  information_schema.tables
where
  split_part(table_name, '_', 1) in ('aws','azure','digitalocean','alicloud','gcp')
group by 1
order by 2 desc;
    `}
  </TerminalCommand>
  <TerminalResult>
    {`
+--------------+--------+
| cloud        | tables |
+--------------+--------+
| aws          | 85     |
| gcp          | 42     |
| azure        | 38     |
| alicloud     | 22     |
| digitalocean | 14     |
+--------------+--------+
    `}
      </TerminalResult>
    </Terminal>

## What cloud are you building on?

Regardless of your cloud platform choice, [Steampipe has you covered with our own multi-cloud plugins](https://hub.steampipe.io/plugins). We hope it is both delightful and a huge time saver for you in your day-to-day cloud work. 

If you’d like to help expand the Steampipe universe, or even dive into the CLI code, the whole project is open source (https://github.com/turbot/steampipe) and we’d love to collaborate!

[Download, install](https://steampipe.io/downloads), and get cloud work done with Steampipe.