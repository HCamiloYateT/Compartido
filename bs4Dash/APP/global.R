# Global -----------------------------------------------------------------------
# Carga librerías, configuración mínima y source de archivos de la app plantilla.

required_packages <- c("shiny", "bs4Dash")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    paste(
      "Faltan paquetes requeridos:",
      paste(missing_packages, collapse = ", "),
      "\nInstálalos con install.packages() y vuelve a ejecutar la app."
    ),
    call. = FALSE
  )
}

lapply(required_packages, library, character.only = TRUE)

# Título principal de la plantilla.
tit_app <- "Plantilla bs4Dash"

# Cargador simple por carpetas en orden de dependencia.
cargar_carpeta <- function(path) {
  archivos <- list.files(path, pattern = "\\.R$", full.names = TRUE)
  if (length(archivos) == 0) return(invisible(NULL))
  for (archivo in archivos) {
    source(archivo, local = FALSE)
  }
}

cargar_carpeta("R/misc")
cargar_carpeta("R/functions")
cargar_carpeta("R/modules")
cargar_carpeta("R/ui")
