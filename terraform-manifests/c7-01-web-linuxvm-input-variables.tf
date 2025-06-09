# Linux VM Input Variables Placeholder file.
variable "web_linuxvm_size" {
  description = "Web Linux VM Size"
  type = string 
  default = "Standard_B1s"
}

variable "web_linuxvm_admin_user" {
  description = "Web Linux VM Admin Username"
  type = string 
  default = "azureuser"
}