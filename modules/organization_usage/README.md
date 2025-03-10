# USAGE SignalFx detectors

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
:link: **Contents**

- [How to use this module?](#how-to-use-this-module)
- [What are the available detectors in this module?](#what-are-the-available-detectors-in-this-module)
- [How to collect required metrics?](#how-to-collect-required-metrics)
  - [Metrics](#metrics)
- [Notes](#notes)
- [Related documentation](#related-documentation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## How to use this module?

This directory defines a [Terraform](https://www.terraform.io/)
[module](https://www.terraform.io/docs/modules/usage.html) you can use in your
existing [stack](https://github.com/claranet/terraform-signalfx-detectors/wiki/Getting-started#stack) by adding a
`module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "signalfx-detectors-organization-usage" {
  source = "github.com/claranet/terraform-signalfx-detectors.git//modules/organization_usage?ref={revision}"

  environment   = var.environment
  notifications = local.notifications
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of the module. The double slash (`//`) is intentional  and required.
  Terraform uses it to specify subfolders within a Git repo (see [module
  sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in
  this repository. It is recommended to use the latest "pinned" version in place of `{revision}`. Avoid using a branch
  like `master` except for testing purpose. Note that every modules in this repository are available on the Terraform
  [registry](https://registry.terraform.io/modules/claranet/detectors/signalfx) and we recommend using it as source
  instead of `git` which is more flexible but less future-proof.

* `environment`: Use this parameter to specify the
  [environment](https://github.com/claranet/terraform-signalfx-detectors/wiki/Getting-started#environment) used by this
  instance of the module.
  Its value will be added to the `prefixes` list at the start of the [detector
  name](https://github.com/claranet/terraform-signalfx-detectors/wiki/Templating#example).
  In general, it will also be used in the `filtering` internal sub-module to [apply
  filters](https://github.com/claranet/terraform-signalfx-detectors/wiki/Guidance#filtering) based on our default
  [tagging convention](https://github.com/claranet/terraform-signalfx-detectors/wiki/Tagging-convention) by default.

* `notifications`: Use this parameter to define where alerts should be sent depending on their severity. It consists
  of a Terraform [object](https://www.terraform.io/docs/configuration/types.html#object-) where each key represents an
  available [detector rule severity](https://docs.signalfx.com/en/latest/detect-alert/set-up-detectors.html#severity)
  and its value is a list of recipients. Every recipients must respect the [detector notification
  format](https://registry.terraform.io/providers/splunk-terraform/signalfx/latest/docs/resources/detector#notification-format).
  Check the [notification binding](https://github.com/claranet/terraform-signalfx-detectors/wiki/Notifications-binding)
  documentation to understand the recommended role of each severity.

These 3 parameters alongs with all variables defined in [common-variables.tf](common-variables.tf) are common to all
[modules](../) in this repository. Other variables, specific to this module, are available in
[variables.tf](variables.tf).
In general, the default configuration "works" but all of these Terraform
[variables](https://www.terraform.io/docs/configuration/variables.html) make it possible to
customize the detectors behavior to better fit your needs.

Most of them represent usual tips and rules detailled in the
[guidance](https://github.com/claranet/terraform-signalfx-detectors/wiki/Guidance) documentation and listed in the
common [variables](https://github.com/claranet/terraform-signalfx-detectors/wiki/Variables) dedicated documentation.

Feel free to explore the [wiki](https://github.com/claranet/terraform-signalfx-detectors/wiki) for more information about
general usage of this repository.

## What are the available detectors in this module?

This module creates the following SignalFx detectors which could contain one or multiple alerting rules:

|Detector|Critical|Major|Minor|Warning|Info|
|---|---|---|---|---|---|
|Organization usage hosts limit|-|X|-|-|-|
|Organization usage containers limit|-|X|-|-|-|
|Organization usage custom metrics limit|-|X|-|-|-|
|Organization usage containers ratio per host included|-|X|-|-|-|
|Organization usage custom metrics ratio per host included|-|X|-|-|-|

## How to collect required metrics?

This module uses metrics available from
[SignalFx
organization](https://docs.signalfx.com/en/latest/integrations/integrations-reference/integrations.signalfx.organization.metrics.html).
There are always available and do not need any configuration to work.



### Metrics


Here is the list of required metrics for detectors in this module.

* `${"sf.org.${var.is_parent ? "child." : ""}numCustomMetrics"}`
* `${"sf.org.${var.is_parent ? "child." : ""}numResourcesMonitored"}`
* `${"sf.org.${var.is_parent ? "child." : ""}subscription.containers"}`
* `${"sf.org.${var.is_parent ? "child." : ""}subscription.customMetrics"}`
* `${"sf.org.${var.is_parent ? "child." : ""}subscription.hosts"}`


## Notes

The `is_parent` parameter allow to deploy either on a parent org or a child org.

This module could be used with related
[dashboards](https://github.com/claranet/terraform-signalfx-dashboards/tree/master/organization/usage):

```hcl
module "signalfx-dashboards-organization-usage" {
  source = "github.com/claranet/terraform-signalfx-dashboards.git//organization/usage?ref=usage"

  default_org_name = "MyFavoriteOrg" # optional but recommended
}

module "signalfx-detectors-organization-usage" {
  source = "github.com/claranet/terraform-signalfx-detectors.git//organization/usage?ref=usage"

  notifications = ["Email,billing@mycorp.net"]
}

```


## Related documentation

* [Terraform SignalFx provider](https://registry.terraform.io/providers/splunk-terraform/signalfx/latest/docs)
* [Terraform SignalFx detector](https://registry.terraform.io/providers/splunk-terraform/signalfx/latest/docs/resources/detector)
