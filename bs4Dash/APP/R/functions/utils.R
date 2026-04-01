# Utilidades -------------------------------------------------------------------
# Incluye helpers para formato de texto y transformación de valores en la UI.

FormatearTexto <- function(texto, tamano_pct = 1, color = "#17202a", negrita = FALSE) {
  tags$span(
    style = paste0(
      "font-size:", tamano_pct, "em;",
      "color:", color, ";",
      if (isTRUE(negrita)) "font-weight:bold;" else ""
    ),
    texto
  )
}

str_to_title <- function(texto) {
  tools::toTitleCase(tolower(texto))
}

formatear_booleano <- function(x) {
  ifelse(isTRUE(x), "Sí", "No")
}
