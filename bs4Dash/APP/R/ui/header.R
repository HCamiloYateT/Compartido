# Header -----------------------------------------------------------------------

# Barra de navegacion principal ----
header <- bs4DashNavbar(
  status        = "white",
  border        = FALSE,
  sidebarIcon   = icon("bars"),
  controlbarIcon = icon("gears"),
  title = dashboardBrand(
    title = tit_app,
    href  = "https://analitica.racafe.com/PortalAnalitica/",
    image = "logo2.png"
  ),
  leftUi = tagList(
    uiOutput("user")
  )
)
