# Módulo de prueba -------------------------------------------------------------
# Muestra los datos dummy en tabla y texto para pruebas en sidebar y body.

ModuloPruebaUI <- function(id, titulo = "Módulo de prueba") {
  ns <- NS(id)
  tagList(
    h5(titulo),
    verbatimTextOutput(ns("resumen")),
    tableOutput(ns("tabla"))
  )
}

ModuloPruebaServer <- function(id, datos) {
  moduleServer(id, function(input, output, session) {
    output$resumen <- renderPrint({
      req(datos())
      cat("Filas:", nrow(datos()), "| Columnas:", ncol(datos()), "\n")
      print(utils::head(datos(), 3))
    })

    output$tabla <- renderTable({
      req(datos())
      tabla <- datos()
      tabla$activo <- formatear_booleano(tabla$activo)
      tabla
    }, striped = TRUE, bordered = TRUE, spacing = "s")
  })
}
