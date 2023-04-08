variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-1"
}
variable "domain_name" {
  type        = string
  description = "The root domain name"
  default     = "winewithmargaret.com"
}
variable "cms_domain_name" {
  type        = string
  description = "The CMS subdomain name to use"
  default     = "cms.winewithmargaret.com"
}
variable "api_domain_name" {
  type        = string
  description = "The API subdomain name to use"
  default     = "api.winewithmargaret.com"
}
variable "bucket_prefix" {
  type = string
  description = "The prefix for the buckets"
  default = "winewithmargaret-"
}