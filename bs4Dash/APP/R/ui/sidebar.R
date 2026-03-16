# Sidebar ----------------------------------------------------------------------
# Define menú lateral y monta un módulo de prueba con datos dummy.

sidebar <- bs4DashSidebar(
  skin = "light",
  status = "primary",
  elevation = 3,
  bs4SidebarMenu(
    id = "menu_principal",
    bs4SidebarMenuItem(
      text = "Inicio",
      tabName = "tab_inicio",
      icon = icon("house")
    )
  ),
  hr(),
  ModuloPruebaUI("mod_sidebar", titulo = "Dummy en Sidebar")
)
