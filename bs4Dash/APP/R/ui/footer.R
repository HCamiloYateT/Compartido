# Footer -----------------------------------------------------------------------

# Pie de pagina con version y logo institucional ----
footer <- bs4DashFooter(
  left = FormatearTexto(
    str_to_title(paste(tit_app, "Version 1")),
    tamano_pct = 0.6
  ),
  right = tags$a(
    href   = "https://analitica.racafe.com/PortalAnalitica/",
    target = "_blank",
    tags$img(
      src    = "logo.png",
      height = "25px",
      style  = "vertical-align: middle;"
    )
  )
)
