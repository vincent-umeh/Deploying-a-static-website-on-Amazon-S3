# Terraform AWS Static Website Hosting with S3 and CloudFront

This Terraform project automates the deployment of a static website on AWS using S3 for storage and CloudFront for content delivery. The infrastructure is defined as code, making it reproducible and version-controlled.

## Features

- Creates an S3 bucket configured for static website hosting
- Sets up proper public access permissions
- Uploads website assets (HTML, CSS, JS) with correct MIME types
- Handles image uploads to a dedicated `images/` folder
- Creates a CloudFront distribution for global content delivery
- Outputs the website endpoints for easy access

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed (v1.0+ recommended)
- AWS CLI configured with credentials
- Static website files ready for deployment

## Usage

1. Clone this repository
2. Create a `terraform.tfvars` file with your configuration (see Variables section)
3. Run `terraform init` to initialize the project
4. Run `terraform plan` to review changes
5. Run `terraform apply` to deploy the infrastructure

## Variables

Configure these variables in `terraform.tfvars` or via command line:

```hcl
aws_region   = "eu-west-1"        # AWS region for resources
bucket_name  = "my-website-bucket" # Unique S3 bucket name
tags = {                          # Tags for resources
  Project     = "StaticWebsite"
  Environment = "Production"
}
website_path = "./website-files"   # Local path to website files
```

## Outputs

After successful deployment, Terraform will output:

- `bucket_endpoint`: The S3 website endpoint URL
- `name`: The CloudFront distribution domain name

## File Structure

The Terraform configuration handles:

1. **S3 Bucket Creation**: Sets up the bucket with proper naming and tags
2. **Website Configuration**: Configures index and error documents
3. **Public Access**: Ensures the bucket is publicly accessible
4. **Bucket Policy**: Grants read-only access to all objects
5. **File Uploads**:
   - Uploads all website assets with proper MIME types
   - Handles image uploads to an `images/` folder
6. **CloudFront Distribution**:
   - Creates a CDN for better performance
   - Configures caching behaviors
   - Uses default CloudFront certificate

## Customization

- Modify the `locals.mime_types` block to add support for additional file types
- Adjust CloudFront cache TTL values in `default_cache_behavior` as needed
- Uncomment and modify the `cache_control` attribute in the image upload resource for custom caching

## Clean Up

To destroy all created resources:

```bash
terraform destroy
```

## Notes

- Ensure your bucket name is globally unique
- The website files should include at least `index.html` and `error.html`
- Images should be placed in a local `images/` directory relative to the Terraform files
- CloudFront distribution may take 10-15 minutes to fully deploy