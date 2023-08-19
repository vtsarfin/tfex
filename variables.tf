variable "server_port" {
  description = "server port for http heredoc"
  type        = number
  default     = 8080
}
variable "ssh_port" {
  description = "ssh port"
  type        = number
  default     = 22
}
variable "prefix_u" {
  description = "universal prefix"
  type        = string
  default     = "vt"
}
variable "alert_emails" {
  description = "alert emails for SNS topic"
  type        = list(string)
  default     = ["vtse01@gmail.com"]
}
