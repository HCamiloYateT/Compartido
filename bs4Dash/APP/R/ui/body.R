# Body -------------------------------------------------------------------------

# Cuerpo principal con estilos y tabs ----
body <- bs4DashBody(
  tags$head(
    tags$link(
      rel  = "stylesheet",
      type = "text/css",
      href = paste0(
        "https://raw.githubusercontent.com/HCamiloYateT/Compartido/",
        "refs/heads/main/Styles/style.css"
      )
    )
  ),
  use_waiter(),

  bs4TabItems(

    # Tab Dashboard ----
    bs4TabItem(
      tabName = "tab_dashboard",
      fluidRow(
        bs4ValueBox(
          value    = uiOutput("kpi_ventas"),
          subtitle = "Ventas Totales",
          icon     = icon("dollar-sign"),
          color    = "danger",
          width    = 3
        ),
        bs4ValueBox(
          value    = uiOutput("kpi_clientes"),
          subtitle = "Clientes Activos",
          icon     = icon("users"),
          color    = "info",
          width    = 3
        ),
        bs4ValueBox(
          value    = uiOutput("kpi_leads"),
          subtitle = "Leads Activos",
          icon     = icon("bullseye"),
          color    = "warning",
          width    = 3
        ),
        bs4ValueBox(
          value    = uiOutput("kpi_ticket"),
          subtitle = "Ticket Promedio",
          icon     = icon("receipt"),
          color    = "success",
          width    = 3
        )
      ),
      fluidRow(
        bs4Card(
          title       = "Ventas Mensuales",
          status      = "danger",
          solidHeader = TRUE,
          width       = 8,
          plotlyOutput("plot_ventas_mes", height = "320px")
        ),
        bs4Card(
          title       = "Ventas por Producto",
          status      = "info",
          solidHeader = TRUE,
          width       = 4,
          plotlyOutput("plot_productos", height = "320px")
        )
      )
    ),

    # Tab Clientes ----
    bs4TabItem(
      tabName = "tab_clientes",
      fluidRow(
        bs4Card(
          title       = "Filtros",
          status      = "secondary",
          solidHeader = FALSE,
          collapsible = TRUE,
          width       = 12,
          column(
            width = 3,
            selectInput(
              "fil_segmento",
              label    = "Segmento",
              choices  = c("Todos", "Premium", "Estandar", "Basico"),
              selected = "Todos"
            )
          ),
          column(
            width = 3,
            selectInput(
              "fil_ciudad",
              label    = "Ciudad",
              choices  = c("Todas", "Bogota", "Medellin", "Cali",
                           "Barranquilla", "Bucaramanga"),
              selected = "Todas"
            )
          ),
          column(
            width = 3,
            selectInput(
              "fil_activo",
              label    = "Estado",
              choices  = c("Todos", "Activo", "Inactivo"),
              selected = "Todos"
            )
          )
        )
      ),
      fluidRow(
        bs4Card(
          title       = "Listado de Clientes",
          status      = "danger",
          solidHeader = TRUE,
          width       = 12,
          DTOutput("tabla_clientes")
        )
      )
    ),

    # Tab Ventas ----
    bs4TabItem(
      tabName = "tab_ventas",
      fluidRow(
        bs4Card(
          title       = "Filtros",
          status      = "secondary",
          solidHeader = FALSE,
          collapsible = TRUE,
          width       = 12,
          column(
            width = 4,
            selectInput(
              "fil_estado_venta",
              label    = "Estado",
              choices  = c("Todos", "Cerrada", "Pendiente", "Cancelada"),
              selected = "Todos"
            )
          ),
          column(
            width = 4,
            selectInput(
              "fil_producto",
              label    = "Producto",
              choices  = c("Todos", "Cafe Premium", "Cafe Molido",
                           "Cafe Instantaneo", "Capsulas", "Accesorios"),
              selected = "Todos"
            )
          ),
          column(
            width = 4,
            selectInput(
              "fil_trimestre",
              label    = "Trimestre",
              choices  = c("Todos", "Q1", "Q2", "Q3", "Q4"),
              selected = "Todos"
            )
          )
        )
      ),
      fluidRow(
        bs4Card(
          title       = "Detalle de Ventas",
          status      = "danger",
          solidHeader = TRUE,
          width       = 12,
          DTOutput("tabla_ventas")
        )
      )
    ),

    # Tab Leads ----
    bs4TabItem(
      tabName = "tab_leads",
      fluidRow(
        bs4Card(
          title       = "Embudo de Leads",
          status      = "warning",
          solidHeader = TRUE,
          width       = 5,
          plotlyOutput("plot_embudo", height = "350px")
        ),
        bs4Card(
          title       = "Leads por Origen",
          status      = "info",
          solidHeader = TRUE,
          width       = 7,
          plotlyOutput("plot_leads_origen", height = "350px")
        )
      ),
      fluidRow(
        bs4Card(
          title       = "Listado de Leads",
          status      = "warning",
          solidHeader = TRUE,
          width       = 12,
          DTOutput("tabla_leads")
        )
      )
    )

  )
)
