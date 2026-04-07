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

#' Boton de accion generico con alineacion configurable
#'
#' @param id ID del boton.
#' @param label Texto del boton. Use `NULL` para omitir texto.
#' @param icono Nombre del icono Font Awesome. Use `NULL` para omitir icono.
#' @param align Alineacion: `"left"`, `"center"`, `"right"`.
#' @param size Tamano visual del boton: `"xxs"`, `"xs"`, `"sm"`, `"md"`, `"lg"`, `"xl"`, `"xxl"`.
#' @param hover_color Color del hover del boton. Por defecto `"firebrick"`.
#' @param label_posicion Posicion del label respecto al icono: `"right"` o `"below"`.
#' @param titulo Tooltip del boton al pasar el cursor. `NULL` para omitir.
#' @param ... Argumentos adicionales para `shiny::actionButton`.
#' @return Componente Shiny.
#' @export
#' @examples
#' \dontrun{
#'   Boton("guardar_form", label = "Guardar cambios", align = "center")
#'   Boton("guardar_icono", label = NULL, icono = "floppy-disk")
#'   Boton("guardar_completo", label = "Guardar", icono = "floppy-disk")
#'   Boton("guardar_abajo", label = "Guardar", icono = "floppy-disk", label_posicion = "below")
#' }
Boton <- function(
    id,
    label = "Guardar",
    icono = "floppy-disk",
    align = "right",
    size = "sm",
    hover_color = "firebrick",
    label_posicion = "right",
    titulo = NULL,
    ...) {

  align <- match.arg(align, c("left", "center", "right"))
  size <- match.arg(size, c("xxs", "xs", "sm", "md", "lg", "xl", "xxl"))
  label_posicion <- match.arg(label_posicion, c("right", "below"))

  if (is.null(label) && is.null(icono)) {
    stop("Debe especificar al menos `label` o `icono`.", call. = FALSE)
  }
  if (!is.character(hover_color) || nchar(hover_color) == 0) {
    stop("`hover_color` debe ser una cadena de color valida.", call. = FALSE)
  }
  if (!is.null(titulo) && (!is.character(titulo) || length(titulo) != 1)) {
    stop("`titulo` debe ser `NULL` o una cadena de longitud 1.", call. = FALSE)
  }

  hover_color_css <- tryCatch(
    {
      rgb_vals <- grDevices::col2rgb(hover_color)
      sprintf("rgb(%d,%d,%d)", rgb_vals[1], rgb_vals[2], rgb_vals[3])
    },
    error = function(e) {
      stop(sprintf("Color '%s' no reconocido.", hover_color), call. = FALSE)
    }
  )

  clase_align <- switch(
    align,
    left = "text-left",
    center = "text-center",
    right = "text-right"
  )

  clase_label <- if (!is.null(icono) && !is.null(label) && identical(label_posicion, "below")) {
    "racafe-btn-content racafe-btn-content--column"
  } else {
    "racafe-btn-content"
  }

  contenido_boton <- shiny::tags$span(
    class = clase_label,
    if (!is.null(icono)) shiny::icon(icono, class = "racafe-btn-icon") else NULL,
    if (!is.null(label)) shiny::tags$span(class = "racafe-btn-label", label) else NULL
  )

  clase_boton <- c(
    "btn btn-success racafe-btn-guardar",
    sprintf("racafe-btn-guardar--%s", size),
    "racafe-btn-content-host",
    if (identical(label_posicion, "below")) "racafe-btn-content-host--column" else NULL
  )

  boton <- shiny::actionButton(
    inputId = id,
    label = contenido_boton,
    class = paste(clase_boton, collapse = " "),
    icon = NULL,
    ...
  )

  boton <- shiny::tagAppendAttributes(
    boton,
    `data-racafe-hover-color` = hover_color_css,
    `data-racafe-label-pos` = label_posicion,
    style = sprintf("--racafe-btn-hover:%s;", hover_color_css),
    title = titulo
  )

  shiny::div(
    class = clase_align,
    boton
  )
}
