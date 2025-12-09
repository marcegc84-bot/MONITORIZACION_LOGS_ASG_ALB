locals {
  sufix = "${var.tags.proyecto}-${var.tags.region}-${var.tags.env}" #Recurso-NomProyecto-region-entorno
}

resource "random_string" "sufijo-s3" {
  length  = 4
  special = false #para que solo utilice carcteres normales
  upper   = false

}

locals {
  s3-sufix = "${var.tags.proyecto}${random_string.sufijo-s3.id}"
}