variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The location/region where the cluster is created."
}

variable "cluster_name" {
  type        = string
  description = "The name of the AKS cluster."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the AKS managed cluster."
}

variable "node_count" {
  type        = number
  description = "The number of nodes in the AKS cluster."
}

variable "vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
  description = "The size of the Virtual Machine."
}
