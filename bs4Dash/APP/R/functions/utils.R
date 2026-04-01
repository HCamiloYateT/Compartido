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

# Botón reutilizable con icono/label -------------------------------------------
# - size: xxs, xs, sm, md, lg, xl, xxl
# - hover_color: color de fondo al hacer hover
# - label_pos: "bottom" (debajo del icono) o "right" (a la derecha)
Boton <- function(
  input_id,
  label,
  icono = "floppy-disk",
  size = c("md", "xxs", "xs", "sm", "lg", "xl", "xxl"),
  hover_color = "firebrick",
  label_pos = c("bottom", "right"),
  class = NULL,
  ...
) {
  size <- match.arg(size)
  label_pos <- match.arg(label_pos)

  orientacion_class <- if (identical(label_pos, "right")) {
    "racafe-btn-guardar--horizontal"
  } else {
    "racafe-btn-guardar--vertical"
  }

  clases <- paste(
    "racafe-btn-guardar",
    paste0("racafe-btn-guardar--", size),
    orientacion_class,
    class
  )

  shiny::actionButton(
    inputId = input_id,
    label = shiny::tagList(
      shiny::icon(icono, class = "racafe-btn-icon"),
      shiny::span(class = "racafe-btn-label", label)
    ),
    class = clases,
    style = paste0("--racafe-btn-hover:", hover_color, ";"),
    ...
  )
}
