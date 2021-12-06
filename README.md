[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-aws-transformer-kinesis-ec2

A Terraform module which deploys the Transformer Kinesis service on EC2.  If you want to use a custom AMI for this deployment you will need to ensure it is based on top of Amazon Linux 2.

*WARNING:* Beware that Transformer Kinesis is using enhanced fan-out for Kinesis consumer. Also, it publishes Kinesis metrics to CloudWatch. They cause significant cost increase. Even though it is planned to make it [possible](https://github.com/snowplow/snowplow-rdb-loader/issues/760) to [disable them](https://github.com/snowplow/snowplow-rdb-loader/issues/759), it isn't possible to do these currently.

## Telemetry

This module by default collects and forwards telemetry information to Snowplow to understand how our applications are being used.  No identifying information about your sub-account or account fingerprints are ever forwarded to us - it is very simple information about what modules and applications are deployed and active.

If you wish to subscribe to our mailing list for updates to these modules or security advisories please set the `user_provided_id` variable to include a valid email address which we can reach you at.

### How do I disable it?

To disable telemetry simply set variable `telemetry_enabled = false`.

### What are you collecting?

For details on what information is collected please see this module: https://github.com/snowplow-devops/terraform-snowplow-telemetry

## Usage

### Standard usage

Transformer takes data from a enriched input stream and transforms this data and writes it into S3. There are two type of transformations. The first one is shredding and the second one is wide row. When shredding is activated, Transformer shreds event to custom entities in the event. When wide row is activated, it only converts event to JSON format.


```hcl
module "enriched_stream" {
  source  = "snowplow-devops/kinesis-stream/aws"
  version = "0.1.1"

  name = var.stream_name
}

module "transformed_bucket" {
  source  = "snowplow-devops/s3-bucket/aws"
  version = "0.1.1"

  bucket_name = var.transformed_bucket
}

resource "aws_sqs_queue" "message_queue" {
  content_based_deduplication = true
  kms_master_key_id           = "alias/aws/sqs"
  # queue name should end with '.fifo'
  name                        = var.queue_name
  fifo_queue                  = true
}

module "transformer_kinesis" {
  source = "snowplow-devops/transformer-kinesis-ec2/aws"

  name        = var.name
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids
  
  stream_name             = module.enriched_stream.name
  s3_bucket_name          = var.transformed_bucket
  s3_bucket_object_prefix = "transformed/good"
  window_period_min       = 10
  sqs_queue_name          = aws_sqs_queue.message_queue.name

  ssh_key_name     = var.key_name
  ssh_ip_allowlist = ["0.0.0.0/0"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.45.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kcl_autoscaling"></a> [kcl\_autoscaling](#module\_kcl\_autoscaling) | snowplow-devops/dynamodb-autoscaling/aws | 0.1.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | snowplow-devops/tags/aws | 0.1.2 |
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_dynamodb_table.kcl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_configuration.lc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_tcp_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_tcp_80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_udp_123](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_tcp_22](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket events will be loaded into | `string` | n/a | yes |
| <a name="input_s3_bucket_object_prefix"></a> [s3\_bucket\_object\_prefix](#input\_s3\_bucket\_object\_prefix) | An optional prefix under which Snowplow data will be saved | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The name of the SSH key-pair to attach to all EC2 nodes deployed | `string` | n/a | yes |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | The name of the input kinesis stream that the Transformer will pull data from | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of subnets to deploy Transformer across | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC to deploy Transformer within | `string` | n/a | yes |
| <a name="input_window_period_min"></a> [window\_period\_min](#input\_window\_period\_min) | Frequency to emit loading finished message - 5,10,15,20,30,60 etc minutes | `number` | n/a | yes |
| <a name="input_amazon_linux_2_ami_id"></a> [amazon\_linux\_2\_ami\_id](#input\_amazon\_linux\_2\_ami\_id) | The AMI ID to use which must be based of of Amazon Linux 2; by default the latest community version is used | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance | `bool` | `true` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Whether application logs should be reported to CloudWatch | `bool` | `true` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | The length of time in days to retain logs for | `number` | `7` | no |
| <a name="input_custom_iglu_resolvers"></a> [custom\_iglu\_resolvers](#input\_custom\_iglu\_resolvers) | The custom Iglu Resolvers that will be used by Transformer | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_default_iglu_resolvers"></a> [default\_iglu\_resolvers](#input\_default\_iglu\_resolvers) | The default Iglu Resolvers that will be used by Transformer | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central",<br>    "priority": 10,<br>    "uri": "http://iglucentral.com",<br>    "vendor_prefixes": []<br>  },<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central - Mirror 01",<br>    "priority": 20,<br>    "uri": "http://mirror01.iglucentral.com",<br>    "vendor_prefixes": []<br>  }<br>]</pre> | no |
| <a name="input_default_shred_format"></a> [default\_shred\_format](#input\_default\_shred\_format) | Format used by default when format type is 'shred' (TSV or JSON) | `string` | `"TSV"` | no |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | The permissions boundary ARN to set on IAM roles created | `string` | `""` | no |
| <a name="input_initial_position"></a> [initial\_position](#input\_initial\_position) | Where to start processing the input Kinesis Stream from (TRIM\_HORIZON or LATEST) | `string` | `"TRIM_HORIZON"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use | `string` | `"t3.micro"` | no |
| <a name="input_kcl_read_max_capacity"></a> [kcl\_read\_max\_capacity](#input\_kcl\_read\_max\_capacity) | The maximum READ capacity for the KCL DynamoDB table | `number` | `10` | no |
| <a name="input_kcl_read_min_capacity"></a> [kcl\_read\_min\_capacity](#input\_kcl\_read\_min\_capacity) | The minimum READ capacity for the KCL DynamoDB table | `number` | `1` | no |
| <a name="input_kcl_write_max_capacity"></a> [kcl\_write\_max\_capacity](#input\_kcl\_write\_max\_capacity) | The maximum WRITE capacity for the KCL DynamoDB table | `number` | `10` | no |
| <a name="input_kcl_write_min_capacity"></a> [kcl\_write\_min\_capacity](#input\_kcl\_write\_min\_capacity) | The minimum WRITE capacity for the KCL DynamoDB table | `number` | `1` | no |
| <a name="input_schemas_json"></a> [schemas\_json](#input\_schemas\_json) | List of schemas to get shredded as JSON | `list(string)` | `[]` | no |
| <a name="input_schemas_skip"></a> [schemas\_skip](#input\_schemas\_skip) | List of schemas to not get shredded (and thus not loaded) | `list(string)` | `[]` | no |
| <a name="input_schemas_tsv"></a> [schemas\_tsv](#input\_schemas\_tsv) | List of schemas to get shredded as TSV | `list(string)` | `[]` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of the SNS topic that Transformer will send the transforming complete message. Either `sqs_queue_name` or `sns_topic_arn` needs to be set | `string` | `""` | no |
| <a name="input_sqs_queue_name"></a> [sqs\_queue\_name](#input\_sqs\_queue\_name) | The name of the SQS queue that Transformer will send the transforming complete message. Either `sqs_queue_name` or `sns_topic_arn` needs to be set | `string` | `""` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The list of CIDR ranges to allow SSH traffic from | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_transformation_type"></a> [transformation\_type](#input\_transformation\_type) | Type of the transformation (shred or widerow) | `string` | `"shred"` | no |
| <a name="input_transformer_compression"></a> [transformer\_compression](#input\_transformer\_compression) | Transformer output compression, GZIP or NONE | `string` | `"GZIP"` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_id"></a> [asg\_id](#output\_asg\_id) | ID of the ASG |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the ASG |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | ID of the security group attached to the Transformer servers |

# Copyright and license

The Terraform AWS Transformer Kinesis on EC2 project is Copyright 2021-2022 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[release]: https://github.com/snowplow-devops/terraform-aws-transformer-kinesis-ec2/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-aws-transformer-kinesis-ec2

[ci]: https://github.com/snowplow-devops/terraform-aws-transformer-kinesis-ec2/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-aws-transformer-kinesis-ec2/workflows/ci/badge.svg

[license]: https://www.apache.org/licenses/LICENSE-2.0
[license-image]: https://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

[registry]: https://registry.terraform.io/modules/snowplow-devops/transformer-kinesis-ec2/aws/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform

[source]: https://github.com/snowplow/snowplow-rdb-loader
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=Transformer%20Kinesis&color=0E9BA4&logo=GitHub
