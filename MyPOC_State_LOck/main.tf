terraform { 
backend "s3" 
{ 
bucket = "terraformbackend1" 
dynamodb_table = "terraform_state_lock" 
region = "eu-west-1"
key = "terraform.tfstate"
 }
}
