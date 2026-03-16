# Body -------------------------------------------------------------------------
# Crea el contenido principal con módulo de prueba y estilos CSS compartidos.

body <- bs4DashBody(
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "https://raw.githubusercontent.com/HCamiloYateT/Compartido/refs/heads/main/Styles/style.css"
    )
  ),
  bs4TabItems(
    bs4TabItem(
      tabName = "tab_inicio",
      fluidRow(
        bs4Card(
          title = "Estado de la plantilla",
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          p(mensaje_plantilla),
          p(sprintf("Versión: %s", version_app))
        )
      ),
      fluidRow(
        bs4Card(
          title = "Dummy en Body",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          ModuloPruebaUI("mod_body", titulo = "Módulo de prueba (Body)")
        )
      )
    )
  )
)
