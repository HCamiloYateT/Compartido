# Prueba local con el mismo includeCSS de las aplicaciones consumidoras ----
.root <- normalizePath(Sys.getenv("COMPARTIDO_ROOT", file.path("..", "..")), mustWork = TRUE)
.reference <- Sys.getenv("COMPARTIDO_REFERENCE_CSS")
.form_ui <- function(id, size, variant) {
  ns <- shiny::NS(id)
  racafeForms::racafeForm(id = "form", ns = ns, size = size, variant = variant,
    racafeForms::racafeFormGroup(title = paste(size, variant),
      racafeForms::racafeFormRow(
        racafeForms::racafeInputText("nombre", "Nombre", required = TRUE, ns = ns),
        racafeForms::racafeInputSelect("categoria", "Categoría", c("Café", "Cacao"), ns = ns)),
      racafeForms::racafeFormRow(
        racafeForms::racafeInputNumeric("importe", "Importe", 1234.56, ns = ns),
        racafeForms::racafeInputDateTime("fecha", "Fecha y hora", value = "2026-11-03 10:30:00", ns = ns)),
      racafeForms::racafeInputSwitch("activo", "Activo", ns = ns)),
    racafeForms::racafeFormFooter(racafeForms::racafeButtonSave("guardar", ns = ns),
      racafeForms::racafeButton("modal", "Abrir modal", variant = "secondary", ns = ns)),
    shiny::uiOutput(ns("resultado")), shiny::verbatimTextOutput(ns("valores")))
}
.form_server <- function(id, size, variant) {
  shiny::moduleServer(id, function(input, output, session) {
    validation <- racafeForms::racafeFormValidation(input, .form_ui(id, size, variant), session)
    shiny::observeEvent(input$guardar, {
      if (!validation$validate()) return()
      output$resultado <- shiny::renderUI(racafeForms::racafeFormMessage("Datos válidos", "success"))
    })
    shiny::observeEvent(input$modal, {
      shiny::showModal(racafeForms::racafeModal("Contenido de prueba", title = "Modal corporativo"))
    })
    output$valores <- shiny::renderPrint(list(nombre = input$nombre, importe = input$importe, fecha = input$fecha,
                                            activo = input$activo))
  })
}
.combinations <- expand.grid(size = c("compact", "normal", "comfortable"), variant = c("plain", "soft", "bordered"),
                              stringsAsFactors = FALSE)
ui <- function(request) {
  query <- shiny::parseQueryString(request$QUERY_STRING)
  file <- if (identical(query$mode, "reference")) .reference else file.path(.root, "Styles", "style.css")
  if (!file.exists(file)) stop("No existe el CSS de prueba; genere la referencia si corresponde.")
  forms <- if (!identical(query$forms, "0")) lapply(seq_len(nrow(.combinations)), function(i) {
    .form_ui(paste0("demo", i), .combinations$size[[i]], .combinations$variant[[i]])
  })
  page <- bs4Dash::dashboardPage(title = "Regresión CSS Compartido",
    header = bs4Dash::dashboardHeader(title = bs4Dash::dashboardBrand(title = "Racafé · Regresión"),
      rightUi = bs4Dash::dropdownMenu(type = "messages", badgeStatus = "success")),
    sidebar = bs4Dash::dashboardSidebar(skin = "light", minified = FALSE,
      bs4Dash::sidebarMenu(id = "navegacion",
        bs4Dash::menuItem("Generalidades", tabName = "general", icon = shiny::icon("house"), selected = TRUE),
        bs4Dash::menuItem("Gestión comercial", icon = shiny::icon("briefcase"), startExpanded = TRUE,
          bs4Dash::menuSubItem("Clientes", tabName = "clientes"),
          bs4Dash::menuSubItem("Pedidos", tabName = "pedidos")),
        bs4Dash::menuItem("Herramientas", tabName = "herramientas", icon = shiny::icon("gear")))),
    body = bs4Dash::dashboardBody(shiny::tagAppendAttributes(shiny::includeCSS(file), id = "corporate-css"),
      racafeForms::racafePanel("Formulario corporativo", forms),
      racafeForms::racafeMetricGrid(racafeForms::racafeMetric(12, "Pedidos"),
                                   racafeForms::racafeMetric(4, "Clientes"), columns = 2)),
    footer = bs4Dash::dashboardFooter(left = "Racafé · Prueba local", right = "Sin datos empresariales"))
  shiny::tagList(htmltools::suppressDependencies("googlefonts", "ionicons"), page)
}
server <- function(input, output, session) {
  for (i in seq_len(nrow(.combinations))) .form_server(paste0("demo", i),
    .combinations$size[[i]], .combinations$variant[[i]])
}
shiny::shinyApp(ui, server)
