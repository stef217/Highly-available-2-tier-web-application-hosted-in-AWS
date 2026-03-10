variable "aws_region" {
  default = "eu-central-1"
}

variable "project_tags" {
  description = "Mandatory tags"
  type        = map(string)
  default = {
    Group          = "InterviewAssessments"
    ResourceStatus = "Temporary"
  }
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.micro"
}



