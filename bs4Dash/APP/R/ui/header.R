# Header -----------------------------------------------------------------------
# Construye la barra superior principal con título de la plantilla.

header <- bs4DashNavbar(
  skin = "light",
  status = "white",
  border = FALSE,
  title = dashboardBrand(title = tit_app)
)
