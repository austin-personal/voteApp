#Terraform relies on plugins called "providers" to interact with remote systems.
terraform { 
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
#Local names are module-specific, and are assigned when requiring a provider.
provider "aws" {
  region              = "us-southeest-2"
  shared_config_files = ["~/.aws/credentials"] #Credential must be a form of list[]
  profile             = "vscode"
}