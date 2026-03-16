ui <- bs4DashPage(
  title = "Presupuesto", header = bs4DashNavbar(),
  sidebar = bs4DashSidebar(), controlbar = bs4DashControlbar(),
  footer = bs4DashFooter(),
  body   = bs4DashBody(useShinyjs(), PresupuestoUI("presupuesto"))
)
server <- function(input, output, session) {
  Presupuesto(
    "presupuesto",
    dat = reactive({ BaseDatos %>% filter(Asesor == "JGCANON", Segmento == "GRANDES")})
  )
}
shinyApp(ui, server)