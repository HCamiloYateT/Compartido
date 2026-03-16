# Server -----------------------------------------------------------------------
# Inicializa módulos, usuario demo y metadatos del pie de página.

server <- function(input, output, session) {
  datos_dummy_reactivos <- reactive(dummy_registros)

  output$user <- renderUI({
    tags$span(style = "font-weight:bold; font-size:0.85em;", "USUARIO DEMO")
  })

  output$last_update_info <- renderUI({
    FormatearTexto(
      paste("Última actualización:", format(Sys.time(), "%Y-%m-%d %H:%M")),
      tamano_pct = 0.75,
      color = "#566573"
    )
  })

  ModuloPruebaServer("mod_sidebar", datos = datos_dummy_reactivos)
  ModuloPruebaServer("mod_body", datos = datos_dummy_reactivos)
}
