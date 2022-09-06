variable "name" {
    default = "string"
    type = string
    description = "Name of the vpc"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "pub_cidr" {
    type  =list(any)
    default =["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24" ]
  
}

variable "private_cidr" {
    type  =list(any)
    default =["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24" ]
  
}

variable "data_cidr" {
    type  =list(any)
    default =["10.1.6.0/24", "10.1.7.0/24", "10.1.8.0/24" ]
  
}

#variable "db_password" {
#  description = "RDS  password"
 # type        = string
  #sensitive   = true
  #default = "Nani"
#}


