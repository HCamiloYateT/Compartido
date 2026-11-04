# Demo local de interacciones bs4Dash; sin datos ni servicios empresariales ----
.root <- normalizePath(Sys.getenv("COMPARTIDO_ROOT", file.path("..", "..")), mustWork = TRUE)
.choices <- c("Café" = "cafe", "Cacao" = "cacao", "Té" = "te")

.controls_ui <- function(id, corporate = FALSE) {
  ns <- shiny::NS(id)
  text <- if (corporate) racafeForms::racafeInputText("text", "Texto", ns = ns) else
    shiny::textInput(ns("text"), "Texto")
  number <- if (corporate) racafeForms::racafeInputNumeric("number", "Número", ns = ns) else
    shiny::numericInput(ns("number"), "Número", 0)
  picker <- function(id, multiple = FALSE, portal = FALSE) {
    if (corporate) {
      tag <- racafeForms::racafeInputSelect(id, id, .choices, multiple = multiple, ns = ns)
      if (portal) tag <- htmltools::tagQuery(tag)$find("select")$addAttrs(`data-container` = "body")$allTags()
      return(tag)
    }
    shinyWidgets::pickerInput(ns(id), id, .choices, multiple = multiple,
      options = shinyWidgets::pickerOptions(liveSearch = TRUE, actionsBox = multiple,
                                            container = if (portal) "body" else FALSE))
  }
  date <- if (corporate) racafeForms::racafeInputDate("date", "Fecha", ns = ns) else
    shinyWidgets::airDatepickerInput(ns("date"), "Fecha", language = "es", dateFormat = "dd/MM/yyyy", addon = "none")
  range <- if (corporate) racafeForms::racafeInputDateRange("range", "Rango", ns = ns) else
    shiny::dateRangeInput(ns("range"), "Rango", start = "2026-11-04", end = "2026-11-10", language = "es")
  tabs <- shiny::tabsetPanel(id = ns("tabs"),
    shiny::tabPanel("Campos", text, number, picker("single"), picker("multi", TRUE, TRUE), picker("search"),
      shiny::actionButton(ns("renew"), "Reconstruir selector"), shiny::uiOutput(ns("dynamic_ui"))),
    shiny::tabPanel("Fechas y modales", date, range,
      shiny::actionButton(ns("modal"), shiny::tags$span("Abrir confirmación")),
      if (corporate) shiny::actionButton(ns("alert"), "Confirmación SweetAlert")),
    shiny::tabPanel("Cotizador",
      shiny::tags$div(class = "cotizador-producto-grid", "Producto A"),
      shiny::tags$div(class = "cotizador-producto-grid", "Producto B"),
      shiny::tags$div(class = "cot-product-total", shiny::tags$span("Total"), shiny::htmlOutput(ns("total"))),
      shiny::tags$div(class = "cot-resumen-modal",
        shiny::tags$div(class = "cot-resumen-tabla", shiny::uiOutput(ns("table"))))))
  if (corporate) racafeForms::racafeForm(variant = "plain", tabs) else tabs
}
.controls_server <- function(id, corporate = FALSE) {
  shiny::moduleServer(id, function(input, output, session) {
    revision <- shiny::reactiveVal(0L)
    confirmed <- shiny::reactiveVal(0L)
    shiny::observeEvent(input$renew, { revision(revision() + 1L) })
    output$dynamic_ui <- shiny::renderUI({
      shinyWidgets::pickerInput(session$ns("dynamic"), paste("Dinámico", revision()), .choices,
        options = shinyWidgets::pickerOptions(liveSearch = TRUE, container = "body"))
    })
    shiny::observeEvent(input$modal, {
      content <- shiny::textInput(session$ns("notes"), "Notas")
      modal <- if (corporate) racafeForms::racafeConfirmation("confirm", list(Texto = input$text), content,
        ns = session$ns) else shiny::modalDialog(content, title = "Confirmación", easyClose = TRUE,
          footer = shiny::tagList(shiny::modalButton("Cancelar"),
            shiny::actionButton(session$ns("confirm"), shiny::tags$span("Confirmar"))))
      shiny::showModal(modal)
    })
    shiny::observeEvent(input$confirm, { confirmed(confirmed() + 1L); shiny::removeModal() })
    shiny::observeEvent(input$alert, {
      racafeForms::racafeConfirm(session, "accepted", "Confirmar", "Ejemplo local", ns = session$ns)
    })
    output$total <- shiny::renderUI(shiny::tags$strong("COP 1,234.56"))
    output$table <- shiny::renderUI(shiny::tags$table(
      shiny::tags$thead(shiny::tags$tr(shiny::tags$th("Producto"), shiny::tags$th("Cantidad"))),
      shiny::tags$tbody(shiny::tags$tr(shiny::tags$td("Café"), shiny::tags$td(2)),
        shiny::tags$tr(shiny::tags$td("Cacao"), shiny::tags$td(3)))))
    output$state <- shiny::renderPrint(list(text = input$text, number = input$number, single = input$single,
      multi = input$multi, search = input$search, dynamic = input$dynamic, date = input$date, range = input$range,
      notes = input$notes, confirmed = confirmed(), accepted = input$accepted, tabs = input$tabs))
  })
}

ui <- function(request) {
  query <- shiny::parseQueryString(request$QUERY_STRING)
  bar <- !identical(query$bar, "0")
  corporate <- identical(query$rf, "1")
  enabled <- !identical(query$script, "0")
  if (corporate && !requireNamespace("racafeForms", quietly = TRUE)) stop("Instale racafeForms para ?rf=1.")
  page <- bs4Dash::dashboardPage(
    header = bs4Dash::dashboardHeader(title = "Controlbar Compartido"),
    sidebar = bs4Dash::dashboardSidebar(disable = TRUE),
    body = bs4Dash::dashboardBody(
      shiny::tags$head(shiny::includeCSS(file.path(.root, "Styles", "style.css")),
        if (enabled) shiny::includeScript(file.path(.root, "Scripts", "controlbar.js"))),
      shiny::h1(id = "outside", "Prueba de clic fuera"),
      shiny::p("La misma app permite ?bar=0, ?rf=1 y ?script=0. No se fija el controlbar."),
      shiny::textInput("outside_text", "Campo ajeno al controlbar"),
      shiny::actionButton("outside_modal", "Modal ajeno"),
      shiny::tableOutput("outside_table"), shiny::verbatimTextOutput("demo-state")),
    controlbar = if (bar) bs4Dash::dashboardControlbar(.controls_ui("demo", corporate), width = 440,
      id = "test_controlbar", pinned = NULL) else NULL,
    footer = bs4Dash::dashboardFooter(left = "Sin persistencia"))
  shiny::tagList(htmltools::suppressDependencies("googlefonts", "ionicons"), page)
}
server <- function(input, output, session) {
  query <- shiny::parseQueryString(shiny::isolate(session$clientData$url_search))
  if (!identical(query$bar, "0")) .controls_server("demo", identical(query$rf, "1"))
  output$outside_table <- shiny::renderTable(data.frame(Ajena = "Sin estilos de Cotizador", Valor = 1))
  shiny::observeEvent(input$outside_modal, {
    shiny::showModal(shiny::modalDialog(shiny::textInput("outside_notes", "Notas ajenas"),
      title = "Modal ajeno", easyClose = TRUE))
  })
}
shiny::shinyApp(ui, server)
