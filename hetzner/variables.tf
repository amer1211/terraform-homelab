variable "hetzner_token" {
  description = "API-Token von Hetzner Cloud"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name des Servers"
  type        = string
  default     = "web-server-01"
}

variable "location" {
  description = "Rechenzentrum (nbg1=Nürnberg, fsn1=Falkenstein)"
  type        = string
  default     = "hel1"
}

variable "server_type" {
  description = "Servertyp (cax11 = 2 vCPU ARM, 4GB RAM)"
  type        = string
  default     = "cax11"
}
