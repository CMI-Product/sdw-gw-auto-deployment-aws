variable "vpc_mpls_cidr" {
  type = string
  description = "the secondary cidr block for vpc to host mpls interface"
}

variable "vpc_internet_cidr" {
  type = string
  description = "the cidr block for vpc to host internet eni"
}

variable "vpc_lan_cidr" {
  type = string
  description = "the third cidr block for vpc to host lan interface"
}

variable "lan_if_enable" {
  type = bool
  default = false
  description = "enable lan interface"
}

variable "lan_interface" {
  type = string
  description = "the lan interface id for c8000v"
}

variable "vpc_name_prefix" {
  type = string
  description = "avoid vpc name duplication in the same region"
  default = "CMI01"
}

variable "amz_asn" {
  type = string
  description = "the asn number for amazon"
  default = "65412"
}