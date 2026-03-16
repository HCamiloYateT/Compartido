# Configuracion regional y del sistema ----
Sys.setenv(TZ      = "America/Bogota",
           LANG    = "es_CO.UTF-8",
           LC_ALL  = "es_CO.UTF-8",
           LC_TIME = "es_CO.UTF-8"
           )

# Fallback robusto de locales por SO
locales_es <- c("es_CO.UTF-8", "es_ES.UTF-8", "Spanish_Spain.1252", "es_ES", "Spanish")
try(Sys.setlocale("LC_TIME", "es_CO.UTF-8"), silent = TRUE)
if (identical(Sys.getlocale("LC_TIME"), "C")) {
  for (loc in locales_es) {
    suppressWarnings(try(Sys.setlocale("LC_TIME", loc), silent = TRUE))
    if (!identical(Sys.getlocale("LC_TIME"), "C")) break
  }
}

# Opciones globales ----
options(
  repos                  = c(CRAN = "https://cloud.r-project.org"),
  dplyr.summarise.inform = FALSE,
  dplyr.show_progress    = FALSE,
  OutDec                 = ",",
  scipen                 = 99999,
  lubridate.week.start   = 1,
  lubridate.verbose      = FALSE,
  lubridate.quiet        = TRUE,
  encoding               = "UTF-8",
  width                  = 120,
  max.print              = 1000
)

# Variables de entorno de control ----
verbose <- tolower(Sys.getenv("APP_VERBOSE", "false")) %in% c("1", "true", "yes")
debug   <- tolower(Sys.getenv("APP_DEBUG",   "false")) %in% c("1", "true", "yes")

# Opciones Shiny ----
options(shiny.autoreload     = FALSE,
        shiny.fullstacktrace = debug,
        shiny.error          = function() { cat("Error en la aplicación\n") }
        )

# Librerias ----
required_packages <- c("shiny", "bs4Dash", "shinyjs", "shinyWidgets",
                       "waiter", "DBI", "tidyverse", "lubridate", 
                       "scales", "plotly", "racafe", "racafeModulos")

racafe::Loadpkg(required_packages)

# racafeModulos: carga condicional
if (requireNamespace("racafeModulos", quietly = TRUE)) {
  library(racafeModulos)
} else {
  message("[INFO] racafeModulos no instalado - omitiendo carga")
}

# Titulo de la aplicacion ----
tit_app <- "App Template"

# Carga de archivos por orden de dependencia ----
# 1. misc    : datos dummy, constantes y valores
# 2. functions: helpers y utilitarios
# 3. modules : modulos Shiny (dependen de functions)
# 4. ui      : elementos de layout (dependen de modules)
cargar_carpeta <- function(path) {
  archivos <- list.files(path, pattern = "\\.R$", full.names = TRUE, recursive = FALSE)
  if (length(archivos) == 0) return(invisible(NULL))
  if (verbose) message("[LOAD] ", path, " (", length(archivos), " archivos)")
  purrr::walk(archivos, ~ {
    if (verbose) message("  - ", basename(.x))
    source(.x, local = FALSE)
  })
}

cargar_carpeta("R/misc")
cargar_carpeta("R/functions")
cargar_carpeta("R/modules")
cargar_carpeta("R/ui")
