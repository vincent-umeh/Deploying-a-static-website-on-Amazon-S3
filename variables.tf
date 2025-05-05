variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Unique S3 bucket name"
  type        = string
}

variable "website_path" {
  description = "Path to website files"
  default     = "./website"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {
    Project = "StaticWebsite"
  }
}

variable "images_folder" {
  description = "Local folder containing the image"
  type        = string
  default     = "./image"  # Relative to Terraform directory

}


