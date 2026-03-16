# Preloader --------------------------------------------------------------------

# Estilo base para preloaders de tipo modal ----
preloader_style_modal <- paste(
  "width: 300px;", "height: 200px;", "display: flex;",
  "flex-direction: column;", "align-items: center;",
  "justify-content: center;", "position: fixed;",
  "top: 50%;", "left: 50%;", "transform: translate(-50%, -50%);",
  "background: white;", "border-radius: 16px;",
  "box-shadow: 0 4px 20px rgba(0,0,0,0.15);",
  "z-index: 9999;"
)

# Creador generico de preloaders (page o modal) ----
crear_preloader <- function(
    texto,
    tipo           = c("page", "modal"),
    logo           = "logo2.png",
    spinner_color  = "text-danger",
    background     = "#e5e7e9"
) {

  tipo <- match.arg(tipo)

  # Contenedor segun tipo de preloader
  contenedor <- if (tipo == "page") {
    tags$div(
      style = paste(
        "display: flex;", "flex-direction: column;", "align-items: center;",
        "justify-content: center;", "height: 100vh;"
      ),
      tags$img(src = logo, width = "80px", style = "margin-bottom: 20px;"),
      tags$h3(texto, style = "color: black; font-size: 10pt; font-weight: bold;"),
      tags$div(class = paste("spinner-border", spinner_color), role = "status")
    )
  } else {
    tags$div(
      style = preloader_style_modal,
      tags$img(src = logo, width = "80px", style = "margin-bottom: 20px;"),
      tags$h3(texto, style = "color: black; font-size: 10pt; font-weight: bold;"),
      tags$div(class = paste("spinner-border", spinner_color), role = "status")
    )
  }

  list(
    html  = tagList(contenedor),
    color = if (tipo == "page") background else "transparent"
  )
}

# Instancias de preloaders ----
preloader <- crear_preloader(
  texto = "Cargando...",
  tipo  = "page"
)

preloader_actualizando <- crear_preloader(
  texto = "Actualizando...",
  tipo  = "modal"
)

preloader_procesando <- crear_preloader(
  texto = "Procesando...",
  tipo  = "modal"
)
