# Controlbar -------------------------------------------------------------------
# Añade un panel lateral derecho simple con instrucciones de uso.

controlbar <- bs4DashControlbar(
  skin = "light",
  title = "Ayuda rápida",
  p("1) Descarga el proyecto."),
  p("2) Ejecuta runApp('bs4Dash/APP')."),
  p("3) Personaliza módulos y datos.")
)
