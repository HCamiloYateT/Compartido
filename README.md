# Compartido

Repositorio de recursos compartidos para aplicaciones de analítica y prototipos de dashboards en **Shiny + bs4Dash**.

## Objetivo

Centralizar elementos reutilizables para acelerar el desarrollo y mantener una identidad visual consistente:

- estilos CSS comunes,
- imágenes institucionales,
- y una plantilla funcional de app `bs4Dash`.

## Estructura actual del repositorio

```text
Compartido/
├── README.md
├── Styles/
│   ├── README.md
│   └── style.css
├── img/
│   ├── Readme.md
│   ├── logo.png
│   └── logo2.png
└── bs4Dash/
    ├── AppPrueba.R
    ├── ValoresPrueba.R
    └── APP/
        ├── README.md
        ├── global.R
        ├── ui.R
        ├── server.R
        └── R/
            ├── functions/utils.R
            ├── misc/data_dummy.R
            ├── misc/values.R
            ├── modules/EjemploModulo.R
            └── ui/
                ├── header.R
                ├── sidebar.R
                ├── body.R
                ├── controlbar.R
                ├── footer.R
                └── preloader.R
```

## Contenido principal

### 1) Estilos compartidos

- **Archivo:** `Styles/style.css`
- **Documentación:** `Styles/README.md`

Incluye reglas globales para interfaz, tipografías, componentes UI y estilos para tablas `reactable`.

### 2) Recursos gráficos

- **Carpeta:** `img/`
- **Documentación:** `img/Readme.md`

Contiene logos reutilizables (`logo.png`, `logo2.png`) para encabezados, login/preloaders y branding de apps.

### 3) Plantilla base Shiny + bs4Dash

- **Carpeta principal:** `bs4Dash/APP/`
- **Documentación:** `bs4Dash/APP/README.md`

Incluye una app lista para ejecutar con estructura modular (`R/ui`, `R/modules`, `R/functions`, `R/misc`), datos dummy y componentes de interfaz separados por responsabilidad.

También se incluyen scripts de apoyo en `bs4Dash/AppPrueba.R` y `bs4Dash/ValoresPrueba.R` para pruebas rápidas.

## Uso sugerido

### Consumir este repositorio desde otro proyecto

Opciones habituales:

1. **Submódulo de Git** para mantener trazabilidad de versiones.
2. **Copia controlada** durante build/deploy.
3. **Referencia por ruta compartida** en infraestructura interna.

### Importar estilos en una app

**HTML**

```html
<link rel="stylesheet" href="Styles/style.css">
```

**Shiny (R)**

```r
tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "Styles/style.css"))
```

### Ejecutar plantilla bs4Dash

```r
shiny::runApp("bs4Dash/APP")
```

## Requisitos para la plantilla bs4Dash

```r
install.packages(c("shiny", "bs4Dash"))
```

## Buenas prácticas para contribuir

- Mantener nombres descriptivos y estables.
- Evitar cambios disruptivos en clases CSS compartidas.
- Documentar nuevos recursos o cambios de estructura en los README correspondientes.
- Optimizar imágenes antes de agregarlas.
- Validar ejecución básica de la plantilla (`runApp`) cuando se modifique `bs4Dash/APP`.

## Versionado recomendado

Cuando haya cambios relevantes, usar tags (`vMAJOR.MINOR.PATCH`):

- **MAJOR**: cambios incompatibles.
- **MINOR**: nuevas capacidades compatibles.
- **PATCH**: correcciones menores.

## Mantenimiento

Responsable sugerido: equipo de analítica/plataforma que gestione assets compartidos y revise cambios en estilo base y plantilla.
