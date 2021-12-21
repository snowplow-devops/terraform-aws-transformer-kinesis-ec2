variable "name" {
  description = "A name which will be pre-pended to the resources created"
  type        = string
}

variable "vpc_id" {
  description = "The VPC to deploy Stream Shredder within"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets to deploy Stream Shredder across"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to this instance"
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "The name of the SSH key-pair to attach to all EC2 nodes deployed"
  type        = string
}

variable "ssh_ip_allowlist" {
  description = "The list of CIDR ranges to allow SSH traffic from"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "iam_permissions_boundary" {
  description = "The permissions boundary ARN to set on IAM roles created"
  default     = ""
  type        = string
}

variable "amazon_linux_2_ami_id" {
  description = "The AMI ID to use which must be based of of Amazon Linux 2; by default the latest community version is used"
  default     = ""
  type        = string
}

variable "kcl_read_min_capacity" {
  description = "The minimum READ capacity for the KCL DynamoDB table"
  type        = number
  default     = 1
}

variable "kcl_read_max_capacity" {
  description = "The maximum READ capacity for the KCL DynamoDB table"
  type        = number
  default     = 10
}

variable "kcl_write_min_capacity" {
  description = "The minimum WRITE capacity for the KCL DynamoDB table"
  type        = number
  default     = 1
}

variable "kcl_write_max_capacity" {
  description = "The maximum WRITE capacity for the KCL DynamoDB table"
  type        = number
  default     = 10
}

variable "tags" {
  description = "The tags to append to this resource"
  default     = {}
  type        = map(string)
}

variable "cloudwatch_logs_enabled" {
  description = "Whether application logs should be reported to CloudWatch"
  default     = true
  type        = bool
}

variable "cloudwatch_logs_retention_days" {
  description = "The length of time in days to retain logs for"
  default     = 7
  type        = number
}

# --- Configuration options

variable "stream_name" {
  description = "The name of the input kinesis stream that the Stream Shredder will pull data from"
  type        = string
}

variable "initial_position" {
  description = "Where to start processing the input Kinesis Stream from (TRIM_HORIZON or LATEST)"
  default     = "TRIM_HORIZON"
  type        = string
}

variable "shredded_output" {
  description = "S3 path to shredded output"
  type        = string
}

variable "shredder_compression" {
  description = "Shredder output compression, GZIP or NONE"
  default     = "GZIP"
  type        = string
}

variable "window_period" {
  description = "Frequency to emit loading finished message - 5,10,15,20,30,60 etc minutes"
  type        = string
}

variable "sqs_queue_name" {
  description = "SQS queue name"
  default     = ""
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN"
  default     = ""
  type        = string
}

variable "format_type" {
  description = "Type of the output format (shred or widerow)"
  default     = "shred"
  type        = string
}

variable "default_shred_format" {
  description = "Format used by default when format type is 'shred' (TSV or JSON)"
  default     = "TSV"
  type        = string
}

variable "schemas_json" {
  description = "List of schemas to get shredded as JSON"
  default     = []
  type        = list(string)
}

variable "schemas_tsv" {
  description = "List of schemas to get shredded as TSV"
  default     = []
  type        = list(string)
}

variable "schemas_skip" {
  description = "List of schemas to not get shredded (and thus not loaded)"
  default     = []
  type        = list(string)
}

# --- Iglu Resolver

variable "default_iglu_resolvers" {
  description = "The default Iglu Resolvers that will be used by Stream Shredder"
  default = [
    {
      name            = "Iglu Central"
      priority        = 10
      uri             = "http://iglucentral.com"
      api_key         = ""
      vendor_prefixes = []
    },
    {
      name            = "Iglu Central - Mirror 01"
      priority        = 20
      uri             = "http://mirror01.iglucentral.com"
      api_key         = ""
      vendor_prefixes = []
    }
  ]
  type = list(object({
    name            = string
    priority        = number
    uri             = string
    api_key         = string
    vendor_prefixes = list(string)
  }))
}

variable "custom_iglu_resolvers" {
  description = "The custom Iglu Resolvers that will be used by Stream Shredder"
  default     = []
  type = list(object({
    name            = string
    priority        = number
    uri             = string
    api_key         = string
    vendor_prefixes = list(string)
  }))
}

# --- Telemetry

variable "telemetry_enabled" {
  description = "Whether or not to send telemetry information back to Snowplow Analytics Ltd"
  type        = bool
  default     = true
}

variable "user_provided_id" {
  description = "An optional unique identifier to identify the telemetry events emitted by this stack"
  type        = string
  default     = ""
}
