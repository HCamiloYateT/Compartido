# Datos dummy ------------------------------------------------------------------
# Define datos de ejemplo simples para validar rápidamente la plantilla.

dummy_registros <- data.frame(
  id = 1:5,
  nombre = c("Ana", "Luis", "Marta", "Carlos", "Sofía"),
  rol = c("Admin", "Usuario", "Usuario", "Analista", "Invitado"),
  activo = c(TRUE, TRUE, FALSE, TRUE, FALSE),
  stringsAsFactors = FALSE
)
