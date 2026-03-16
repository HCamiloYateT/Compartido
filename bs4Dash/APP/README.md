# App Template - Racafe CRM

## Estructura del proyecto

```
app_template/
├── global.R              # Configuracion regional, librerias, carga de modulos
├── ui.R                  # Definicion bs4DashPage
├── server.R              # Logica del servidor
├── R/
│   ├── preloader.R       # Estilos y creador de preloaders (page / modal)
│   ├── header.R          # Navbar bs4Dash con brand y usuario
│   ├── sidebar.R         # Menu lateral de navegacion
│   ├── body.R            # Cuerpo con CSS remoto, waiter y tabs
│   ├── controlbar.R      # Panel lateral derecho
│   └── footer.R          # Pie de pagina con version y logo
├── www/
│   ├── logo.png          # Logo Racafe (descargado via download_assets.sh)
│   └── logo2.png         # Logo app (descargado via download_assets.sh)
└── download_assets.sh    # Script para descargar imagenes desde GitHub
```

## Setup inicial

```bash
# Descargar imagenes
bash download_assets.sh
```

## Librerias requeridas
- shiny, bs4Dash, shinyjs, shinytoastr, shinyWidgets
- waiter, DBI, tidyverse, lubridate, DT
- scales, plotly, racafe, racafeModulos

## Variables de entorno
| Variable      | Default | Descripcion                    |
|---------------|---------|-------------------------------|
| APP_VERBOSE   | false   | Activa logs detallados         |
| APP_DEBUG     | false   | Activa fullstacktrace en Shiny |

## Preloaders disponibles
- `preloader`              -> carga inicial (tipo page)
- `preloader_actualizando` -> actualizacion de datos (tipo modal)
- `preloader_procesando`   -> procesamiento en curso (tipo modal)

## CSS
Cargado remotamente desde:
https://raw.githubusercontent.com/HCamiloYateT/Compartido/refs/heads/main/Styles/style.css

> Para produccion se recomienda copiar el CSS a www/style.css y usar includeCSS("www/style.css")
