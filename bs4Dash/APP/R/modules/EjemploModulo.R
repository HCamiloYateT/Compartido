# UI del modulo EjemploModulo ----
EjemploModuloUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("contenido"))
  )
}
EjemploModulo <- function(id, datos = reactive(NULL)) {
  moduleServer(id, function(input, output, session) {

    # Render de contenido de ejemplo
    output$contenido <- renderUI({
      req(datos())
      tags$p(paste("Filas recibidas:", nrow(datos())))
    })

  })
}
