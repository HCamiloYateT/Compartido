# Sidebar ----------------------------------------------------------------------

# Menu lateral de navegacion ----
sidebar <- bs4DashSidebar(
  status        = "danger",
  expandOnHover = FALSE,
  bs4SidebarMenu(
    id = "menu_principal",
    bs4SidebarMenuItem(
      "Dashboard",
      tabName = "tab_dashboard",
      icon    = icon("gauge")
    ),
    bs4SidebarMenuItem(
      "Clientes",
      tabName = "tab_clientes",
      icon    = icon("users")
    ),
    bs4SidebarMenuItem(
      "Ventas",
      tabName = "tab_ventas",
      icon    = icon("chart-line")
    ),
    bs4SidebarMenuItem(
      "Leads",
      tabName = "tab_leads",
      icon    = icon("bullseye")
    )
  )
)
