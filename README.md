# Compartido

Repositorio de **recursos compartidos** para aplicaciones de analítica y
prototipos de dashboards, especialmente aplicaciones Shiny.

> **Alcance actual:** este repositorio no contiene una aplicación Shiny ni una
> plantilla `bs4Dash` ejecutable. Proporciona assets y utilidades que deben
> integrarse en una aplicación existente. Por tanto, no se puede ejecutar con
> `shiny::runApp()` por sí solo.

## Objetivo

Centralizar elementos reutilizables para mantener una identidad visual y evitar
duplicar código entre proyectos:

- estilos CSS comunes;
- imágenes institucionales;
- un script de inicialización de tooltips; y
- utilidades en R para descargar capas geográficas del DANE.

## Estructura actual del repositorio

```text
Compartido/
├── README.md
├── Scripts/
│   └── scripts
├── Styles/
│   ├── README.md
│   └── style.css
├── img/
│   ├── Readme.md
│   ├── logo.png
│   └── logo2.png
└── utils/
    └── dane_utils.R
```

## Contenido principal

### 1) Estilos compartidos

- **Archivo:** `Styles/style.css`
- **Documentación adicional:** `Styles/README.md`

Incluye reglas globales para tipografías, componentes de interfaz, modales y
tablas `reactable`. Varias reglas están diseñadas para el marcado generado por
Shiny, Bootstrap y `bs4Dash`; incluir el CSS no instala esos paquetes ni crea
sus componentes.

### 2) Recursos gráficos

- **Carpeta:** `img/`
- **Documentación adicional:** `img/Readme.md`

Contiene `logo.png` y `logo2.png`, que se pueden usar en encabezados,
preloaders y otros elementos de identidad visual.

### 3) Script JavaScript

- **Archivo:** `Scripts/scripts` (es JavaScript aunque el archivo no tiene la
  extensión `.js`).

Al terminar de cargar el DOM, el script busca elementos con un atributo
`title` e inicializa sobre ellos el plugin de tooltips de Bootstrap mediante
`$('[title]').tooltip(...)`.

El script **depende de jQuery y del plugin JavaScript de Bootstrap**. Debe
cargarse después de esas dependencias. En una aplicación `bs4Dash`, normalmente
las aporta el propio framework; si se integra en otra página, la aplicación es
responsable de incluir versiones compatibles de jQuery y Bootstrap (y las
dependencias que requiera esa versión de Bootstrap).

### 4) Utilidades geográficas del DANE

- **Archivo:** `utils/dane_utils.R`

Define las URL de los conjuntos de departamentos y municipios del MGN 2025 y
la función `dane_leer_geojson()`. La función descarga un ZIP, localiza el primer
GeoJSON, lo lee, lo transforma a EPSG:4326 y guarda el resultado como RDS.

Para usarla se necesita R, acceso de red al geoportal del DANE y el paquete
`sf` (incluidas las bibliotecas de sistema que `sf` requiera en el entorno):

```r
install.packages("sf")
source("ruta/a/Compartido/utils/dane_utils.R")
dane_leer_geojson(url_dpto, "data/dpto_2025.rds")
```

## Integración de los assets en Shiny

Una ruta del sistema de archivos como `Styles/style.css` **no queda expuesta
automáticamente por el servidor web de Shiny**. El CSS, las imágenes y el
JavaScript deben copiarse a `www/` o publicarse explícitamente como recursos.

### Opción A: copiar los archivos a `www/`

Una aplicación puede mantener esta estructura:

```text
mi-app/
├── app.R
└── www/
    ├── css/style.css
    ├── js/compartido.js
    └── img/
        ├── logo.png
        └── logo2.png
```

Por ejemplo, desde la raíz de `mi-app/`:

```sh
mkdir -p www/css www/js www/img
cp ruta/a/Compartido/Styles/style.css www/css/style.css
cp ruta/a/Compartido/Scripts/scripts www/js/compartido.js
cp ruta/a/Compartido/img/logo.png ruta/a/Compartido/img/logo2.png www/img/
```

Después se usan rutas URL relativas a `www/` (sin escribir `www/` en el
`href` o `src`):

```r
shiny::tags$head(
  shiny::tags$link(rel = "stylesheet", href = "css/style.css"),
  shiny::tags$script(src = "js/compartido.js")
)

shiny::tags$img(src = "img/logo.png", alt = "Logo")
```

Esta opción permite que cada aplicación fije y despliegue su propia copia de
los assets. Si el repositorio se actualiza, las copias no se actualizan solas.

### Opción B: servir el repositorio con `addResourcePath()`

Si `Compartido` está disponible en el entorno donde se ejecuta la aplicación,
se puede asignar un prefijo URL a su directorio raíz antes de construir la UI:

```r
compartido_dir <- normalizePath("ruta/a/Compartido", mustWork = TRUE)
shiny::addResourcePath("compartido", compartido_dir)

ui <- shiny::fluidPage(
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet",
      href = "compartido/Styles/style.css"
    ),
    shiny::tags$script(src = "compartido/Scripts/scripts")
  ),
  shiny::tags$img(src = "compartido/img/logo.png", alt = "Logo")
)
```

El prefijo `compartido` es una URL pública, no una carpeta que deba existir en
la app. Esta alternativa evita copiar archivos, pero exige que la ruta esté
presente y sea accesible en cada entorno de ejecución. No se debe exponer así
el repositorio completo si contiene o llega a contener información sensible;
en ese caso, registrar por separado solo `Styles/`, `Scripts/` e `img/`.

## Dependencias y compatibilidad

No hay un conjunto de dependencias que convierta este repositorio en una app
lista para ejecutar. Las dependencias dependen del recurso consumido:

| Recurso | Dependencias relevantes |
| --- | --- |
| `Styles/style.css` | El navegador; algunos selectores solo tienen efecto sobre componentes generados por Shiny, Bootstrap, `bs4Dash` o `reactable`. |
| `Scripts/scripts` | jQuery y el plugin de tooltips de Bootstrap, cargados antes del script. |
| `img/*.png` | Ninguna dependencia de R; deben servirse como recursos web. |
| `utils/dane_utils.R` | R, el paquete `sf`, acceso de red y soporte del sistema para leer datos espaciales y ZIP. |

Antes de adoptar una nueva revisión del repositorio, conviene fijar un commit o
tag y comprobar los assets en la misma versión de Shiny/Bootstrap/`bs4Dash` que
usa la aplicación consumidora. El repositorio no declara actualmente una matriz
de versiones compatibles ni garantiza compatibilidad con todas sus versiones.

## Formas de consumir el repositorio

1. **Submódulo de Git:** fija una revisión y conserva su trazabilidad.
2. **Copia controlada durante build/deploy:** publica únicamente los assets
   requeridos dentro de `www/`.
3. **Ruta compartida + `addResourcePath()`:** evita copias, pero requiere que la
   ruta exista también en producción.

## Buenas prácticas para contribuir

- Mantener nombres descriptivos y estables.
- Evitar cambios disruptivos en clases CSS compartidas.
- Documentar nuevos recursos, dependencias o cambios de estructura.
- Optimizar imágenes antes de agregarlas.
- Probar CSS y JavaScript dentro de una aplicación consumidora que use las
  versiones objetivo de Bootstrap y Shiny.

## Versionado recomendado

Cuando haya cambios relevantes, usar tags (`vMAJOR.MINOR.PATCH`):

- **MAJOR:** cambios incompatibles.
- **MINOR:** nuevas capacidades compatibles.
- **PATCH:** correcciones menores.

## Mantenimiento

Responsable sugerido: el equipo de analítica/plataforma que gestione los assets
compartidos y revise cambios en estilos, scripts, imágenes y utilidades.
