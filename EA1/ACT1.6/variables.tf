variable "ssh_ingress_cidr" {
  description = "CIDR permitido para SSH (tu IP publica /32)"
  type        = string
  default     = "203.0.113.10/32" # CAMBIAR por ej. "200.1.2.3/32"
}