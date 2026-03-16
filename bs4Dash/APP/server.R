server <- function(input, output, session) {
  
  usuario <- reactive({
    if (is.null(session$user)) "HCYATE" else str_to_upper(session$user)
  })
  output$user <- renderUI({
    div(
      style = "display:flex;align-items:center;justify-content:center;height:100%;",
      tags$span(
        style = "font-weight:bold;font-size:0.8em;color:#17202a;",
        usuario()
      )
    )
  })
  
  grupo <- reactive({
    grps <- session$groups
    if (is.null(grps) || length(grps) == 0) "SIN_GRUPO" else str_to_upper(grps[[1]])
  })
  observe({
    cat("[SESION] Usuario:", usuario(), "| Grupo:", grupo(), "\n")
  })
  
}
