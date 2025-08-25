variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket (leave empty for auto-generated name)"
  type        = string
  default     = ""
}

variable "versioning_enabled" {
  description = "Enable versioning"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (leave empty for AES256)"
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public policy"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules"
  type = list(object({
    id                                   = string
    status                              = string
    expiration_days                     = number
    noncurrent_version_expiration_days = number
    transition_rules = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = []
}

variable "notification_configurations" {
  description = "Notification configurations"
  type = object({
    lambda_functions = list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = string
      filter_suffix       = string
    }))
    topics = list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = string
      filter_suffix = string
    }))
    queues = list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = string
      filter_suffix = string
    }))
  })
  default = {
    lambda_functions = []
    topics          = []
    queues          = []
  }
}

variable "bucket_policy" {
  description = "Bucket policy JSON"
  type        = string
  default     = ""
}

variable "cors_rules" {
  description = "CORS rules"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "logging_target_bucket" {
  description = "Target bucket for access logging"
  type        = string
  default     = ""
}

variable "logging_target_prefix" {
  description = "Target prefix for access logging"
  type        = string
  default     = "access-logs/"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}