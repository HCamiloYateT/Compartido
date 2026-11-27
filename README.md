# Compartido

Repositorio de **recursos compartidos** para aplicaciones de analítica y
prototipos de dashboards, especialmente aplicaciones Shiny.

> **Alcance actual:** este repositorio proporciona assets y utilidades para aplicaciones
> existentes. La raíz no es una aplicación Shiny. Incluye una app mínima de regresión
> en `tests/styles-regression/`, sin servicios externos ni datos empresariales.

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
│   ├── tokens.css
│   ├── racafe-forms.css
│   ├── components.css
│   ├── racafe-modal-sizes.css
│   ├── application.css
│   └── style.css (generado)
├── img/
│   ├── Readme.md
│   ├── logo.png
│   └── logo2.png
└── utils/
    ├── build_styles.R
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

### Opción B: servir solo los directorios de recursos con `addResourcePath()`

Si `Compartido` está disponible en el entorno donde se ejecuta la aplicación,
se pueden registrar únicamente los tres directorios de recursos antes de construir la UI:

```r
compartido_dir <- normalizePath("ruta/a/Compartido", mustWork = TRUE)
shiny::addResourcePath("compartido-styles", file.path(compartido_dir, "Styles"))
shiny::addResourcePath("compartido-scripts", file.path(compartido_dir, "Scripts"))
shiny::addResourcePath("compartido-img", file.path(compartido_dir, "img"))

ui <- shiny::fluidPage(
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet",
      href = "compartido-styles/style.css"
    ),
    shiny::tags$script(src = "compartido-scripts/scripts")
  ),
  shiny::tags$img(src = "compartido-img/logo.png", alt = "Logo")
)
```

Estos prefijos son URL públicas, no carpetas que deban existir dentro de la app. Esta alternativa evita copiar archivos, pero exige que la ruta esté
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

## Integración versionada con racafeForms 0.3.0

La fuente de verdad de los nuevos componentes es Compartido. El paquete R aporta
constructores y mensajes Shiny; los estilos e interacciones nuevos están aquí:

- `ASSETS_VERSION`: versión del contrato de recursos, actualmente `1.0.0`.
- `Styles/style.css`: punto de entrada autocontenido, generado con tokens, componentes y reglas generales.
- `Scripts/scripts`: tooltips delegados e idempotentes para Bootstrap 3/4.
- `Scripts/clipboard.js`: copia real de texto/PNG y resultado asíncrono a Shiny.
- `Scripts/forms.js`: activación optativa de tarjetas y reset por binding Shiny.
- `img/logo.png` y `img/logo2.png`: imágenes existentes, sin duplicarlas en el paquete R.

Ejemplo de carga local, sin GitHub Raw durante la ejecución:

```r
assets <- racafeForms::racafeSharedAssets("vendor/Compartido", version = "1.1.0")
ui <- shiny::fluidPage(
  assets,
  shiny::tags$img(src = paste0(attr(assets, "image_url"), "/logo.png"), alt = "Racafé"),
  racafeForms::racafePanel("Información", racafeForms::racafeInfoItem("Estado", "Disponible"))
)
```

El cargador publica **solo** Styles, Scripts e img con prefijos versionados; nunca
publica la raíz, `.git` o utils. El cargador automatiza el registro acotado de directorios y versiona sus URL. También admite `RACAFE_SHARED_PATH` o la
opción R `racafeForms.shared_path`. `css = FALSE`, `javascript = FALSE` e
`images = FALSE` permiten desactivar cada grupo de recursos compartidos.

Fije el commit o tag de Compartido durante el despliegue y solicite explícitamente
la versión de `ASSETS_VERSION`. La función verifica la versión declarada; no verifica
firmas Git ni descarga o actualiza archivos. Pruebe una revisión nueva antes de
reemplazar la copia controlada en OEAPP. No se han modificado rutas de ese servidor.

### Compatibilidad

| Compartido | racafeForms | Uso |
|---|---|---|
| Revisión anterior sin ASSETS_VERSION | 0.2.1 o anterior | Integración manual anterior. |
| 1.0.0 | 0.3.0 | Cargador local y componentes nuevos. |
| No cargado | 0.3.0 | API previa y estilos base conservados. |

El portapapeles requiere HTTPS o localhost, permisos del navegador y soporte de
ClipboardItem para PNG. El resultado real llega a Shiny; una denegación no se informa
como éxito. El sistema no registra texto, imágenes ni datos personales en consola.

### Validación de integración

La demo y las pruebas de navegador se mantienen en
`Libreria-Racafe/racafeForms/inst/examples/corporate-components.R` y
`Libreria-Racafe/racafeForms/tests/browser/test-corporate-components.cjs`.
Permiten probar Shiny, bs4Dash, módulos simultáneos, UI dinámica, los siete tamaños
de modal, descarga nativa, copia de texto/PNG, errores de permisos, móvil y ausencia
de peticiones externas. El informe de resultados se guarda junto a la documentación
de racafeForms; no se modifica Firma Digital.

## Correo corporativo

[`email/`](email/) contiene las cuatro plantillas y la configuración R de `racafeMail` 0.1.0.
El motor vive exclusivamente en `Libreria-Racafe/racafeMail`; no se publica esta carpeta
como recursos web ni se envían correos al instalarla. Su contrato tiene versión propia
en `email/VERSION`, independiente de los recursos de formularios.

## Componentes visuales racafeForms 0.4.0

`ASSETS_VERSION` 1.1.0 añade el badge semántico, densidades de tarjeta/indicador,
altura por contenido y uniformidad de campos. Use la copia local fijada a un commit
aprobado y `racafeSharedAssets(version = "1.1.0")`. El cargador y los scripts existentes
se reutilizan; no registre JavaScript adicional por módulo.

Los colores `--color-success`, `--color-warning`, `--color-info` y los colores rojos/grises
existentes alimentan los badges. Los badges de entorno anteriores conservan sus colores.
La paleta inicial de estados tiene contraste de texto >= 4,5:1; compruébelo de nuevo si
personaliza los tokens. Las dimensiones y fuentes de componentes permanecen en
`Styles/racafe-forms.css`, usando la identidad corporativa de `Styles/style.css`.
Los siete tamaños de modal y los recursos de racafeMail no cambian.

## Componentes sin estilos globales

`Styles/components.css` carga únicamente `tokens.css` y `racafe-forms.css`. Permite
usar componentes corporativos en bs4Dash sin alterar el layout, los títulos o los
errores de Shiny de la aplicación. `style.css` conserva sus reglas generales y
reutiliza la misma fuente de variables. El rojo principal se fija en `#DA291C`.
La galería de racafeForms incluye una instantánea de estos recursos para funcionar localmente.

## CSS autocontenido para includeCSS

`Styles/style.css` es un archivo generado y autocontenido. Las aplicaciones existentes
pueden conservar exactamente su llamada actual, sin modificar body.R ni ui.R:

```r
shiny::includeCSS(
  "https://raw.githubusercontent.com/HCamiloYateT/Compartido/refs/heads/main/Styles/style.css"
)
```

Para obtener este comportamiento en producción debe integrarse primero la corrección en
main. En pruebas utilice `shiny::includeCSS("/ruta/a/Compartido/Styles/style.css")`.
No depende de que el navegador pueda resolver imports relativos desde una etiqueta style.

Edite únicamente las fuentes: `tokens.css`, `racafe-forms.css`, `racafe-modal-sizes.css`
y `application.css`.
Después reconstruya y compruebe el archivo generado, que también se incluye en Git:

```sh
Rscript utils/build_styles.R
Rscript utils/build_styles.R --check
Rscript tests/test-build-styles.R
```

El script funciona desde cualquier directorio, no requiere paquetes adicionales y produce
UTF-8 con finales LF. Conserva el orden indicado, comentarios y selectores, y no reescribe
un resultado idéntico. Rechaza imports no consolidados y fuentes ausentes; nunca lee
style.css como fuente. CI comprueba que el resultado no esté desactualizado.

`components.css` conserva su función independiente para consumidores que cargan CSS como
recurso URL con rutas relativas disponibles. **No es la alternativa a style.css para
includeCSS()**: su estructura de imports es intencional. El CSS de componentes sigue acotado
a clases rf- y variables corporativas. No se cambian los selectores de navegación existentes
ni las reglas de AdminLTE/Bootstrap.

Consulte la [guía de construcción y regresión](Styles/README.md#construcción-y-regresión).
La app mínima incluye sidebar con submenús, navbar, footer, tarjetas y formularios modulares.
No se ha modificado CRM Nacional ni ninguna aplicación consumidora.

## Tamaños de modal compartidos

`Styles/racafe-modal-sizes.css` es la fuente única de dimensiones de modales RF. El bundle
style.css incluye esas reglas antes de application.css; sigue siendo compatible con
includeCSS() sin imports relativos. Los selectores generales antiguos conservan sus valores
mediante las variables canónicas. components.css también importa el archivo para recursos URL.
La misma fuente se distribuye con racafeForms y se precarga con racafeFormsDependencies().
Las copias del paquete deben mantenerse idénticas: no mantenga otra tabla de anchos.
No se modifican sidebar, navbar o clases de Bootstrap ajenas; las reglas nuevas usan rf-.
Esta revisión se entrega mediante PR; no incrementa ASSETS_VERSION ni publica una versión de recursos.

## Controlbar bs4Dash: interacciones compartidas

`Scripts/controlbar.js` mantiene abierto el controlbar al usar sus controles y los emergentes
asociados. No fija el panel ni modifica `data-pin`. Conserva los botones del navbar, el cierre
por clic fuera y los handlers de Shiny, Bootstrap y AdminLTE en el propio documento.
No requiere IDs de una aplicación y no hace nada con los clics si no hay un panel abierto.

La referencia URL solicitada, disponible después de integrar estos cambios en main, es:

```r
shiny::tags$head(
  shiny::tags$script(
    src = paste0(
      "https://raw.githubusercontent.com/HCamiloYateT/",
      "Compartido/refs/heads/main/Scripts/controlbar.js"
    )
  )
)
```

GitHub Raw responde con `Content-Type: text/plain` y `X-Content-Type-Options: nosniff`,
por lo que el navegador puede bloquear ese `src`. Para ejecutar el script de forma fiable,
use una copia local (la opción utilizada por la demo):

```r
shiny::tags$head(shiny::includeScript("/ruta/Compartido/Scripts/controlbar.js"))
```

También puede servirlo mediante `addResourcePath()` con MIME JavaScript, o leer la URL desde
R con `shiny::includeScript(URL)`. La inclusión es explícita: no se cambia `Scripts/scripts`
ni se incorpora automáticamente el recurso en las aplicaciones existentes.

### Alcance de la protección

El controlador se registra una vez por página. La fase de captura registra el origen sin bloquear
eventos. En fase bubble de `document`, solo
detiene la subida a `window` de clics internos o de popups asociados; nunca utiliza
`preventDefault()` ni `stopImmediatePropagation()`. Así conserva los handlers del documento,
incluidos la selección del picker, el cierre de modales y los bindings reactivos de Shiny.
Los clics externos continúan hasta el cierre nativo de bs4Dash.

La procedencia se reconoce al abrir el emergente desde el panel y, cuando existe, mediante
`aria-controls`, `aria-owns` o el identificador del select original. No se protege indiscriminadamente
cualquier modal abierto. Un modal ajeno sigue siendo externo al controlbar. Los botones nativos
`controlbar-toggle` y `controlbarPin` se reconocen como controles de bs4Dash; no son IDs de negocio.

Además de los selectores iniciales de modales/calendarios, la inspección de racafeForms identificó:

- `.air-datepicker`: calendario de `racafeInputDate()` y fecha/hora de shinyWidgets.
- `.bs-container`: menú de `pickerInput(container = "body")` fuera del panel.
- `.rf-select-menu`: menú corporativo en portal, con referencia `data-rf-select-id` al select original.

Los rangos actuales de racafeForms utilizan el datepicker Bootstrap, ya cubierto por
`.datepicker` y `.datepicker-dropdown`. La protección admite también las familias Select2,
Flatpickr, jQuery UI, daterangepicker, datetimepicker, clockpicker y SweetAlert indicadas
por sus clases específicas. Los controles incorporados con `renderUI()` se reconocen sin
registrar listeners por input ni repetir el controlador.

### Demo y pruebas locales

Requiere `shiny`, `bs4Dash` y `shinyWidgets`; `racafeForms` es opcional para `?rf=1`.
Desde la raíz de Compartido:

```r
shiny::runApp("tests/controlbar", port = 4061)
```

- `/`: controles nativos, picker simple/múltiple con búsqueda y portal, texto y número,
  Air Datepicker, rango, confirmación, tabs y selector reconstruido con `renderUI()`.
- `/?rf=1`: los mismos casos con componentes de racafeForms y confirmación SweetAlert.
- `/?bar=0`: aplicación sin controlbar.
- `/?script=0`: comparación sin el controlador para reproducir el cierre al editar un modal asociado.

La demo carga `Styles/style.css` mediante `includeCSS()` y el script local mediante
`includeScript()`. No tiene persistencia ni conexiones empresariales.

Instale Playwright en un entorno de pruebas (`npm install --no-save playwright@1.62.1` y
`npx playwright install chromium`) y, con la app abierta, ejecute:

```sh
node tests/browser/test-controlbar.cjs
Rscript tests/test-build-styles.R
Rscript utils/build_styles.R --check
```

Se admiten `COMPARTIDO_CONTROLBAR_URL` y `CHROMIUM_PATH` para una URL o Chromium ya instalado.
La prueba de navegador comprueba bindings, selector dinámico, tabs, confirmación, cierres nativos,
repetición del script, popups asociados/ajenos, ausencia de controlbar y alcance del CSS del Cotizador.

## Estilos del Cotizador

Las clases `.cotizador-producto-grid`, `.cot-product-total` y `.cot-resumen-modal` se conservan
en `Styles/application.css`, con sus valores originales. El bundle `Styles/style.css` se genera
con `Rscript utils/build_styles.R`; no debe editarse manualmente. Las reglas de tablas están
limitadas a `.cot-resumen-modal .cot-resumen-tabla`, sin afectar otras tablas ni añadir `!important`.
No se ha modificado CRM Nacional ni retirado CSS de sus archivos.

Una revisión posterior puede evaluar el espaciado como `racafeStack()`, el total como
`racafeMoneyTotal()` y la tabla como `racafeSummaryTable()`. La altura máxima de 55vh del resumen
necesitaría un contenedor general desplazable. Esta tarea conserva el comportamiento y no realiza
esas sustituciones ni modifica racafeForms.

Validación local de esta revisión: 51 comprobaciones de interacciones/bindings/popups/Cotizador,
28 de construcción determinista y 69 de regresión CSS/bs4Dash. Se verificó la inclusión con
`includeCSS()` y se conservaron las reglas anteriores y la apariencia del sidebar.
