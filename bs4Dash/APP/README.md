# Plantilla bs4Dash (lista para usar)

Aplicación base en **Shiny + bs4Dash** pensada para múltiples usuarios y ejecutable al descargar el proyecto.

## Objetivo

- Estructura clara por carpetas (`misc`, `functions`, `modules`, `ui`).
- Datos dummy simples para pruebas rápidas.
- Módulo de prueba que imprime datos en sidebar y body.
- Recursos visuales desde rutas compartidas públicas.

## Recursos compartidos utilizados

- Logo app: `https://raw.githubusercontent.com/HCamiloYateT/Compartido/refs/heads/main/img/logo2.png`
- Logo Racafe: `https://raw.githubusercontent.com/HCamiloYateT/Compartido/main/img/logo.png`
- CSS base: `https://raw.githubusercontent.com/HCamiloYateT/Compartido/refs/heads/main/Styles/style.css`

## Estructura incluida

```text
bs4Dash/APP/
├── global.R
├── ui.R
├── server.R
├── README.md
└── R/
    ├── misc/
    │   ├── data_dummy.R
    │   └── values.R
    ├── functions/
    │   └── utils.R
    ├── modules/
    │   └── EjemploModulo.R
    └── ui/
        ├── header.R
        ├── sidebar.R
        ├── body.R
        ├── controlbar.R
        ├── footer.R
        └── preloader.R
```

## Requisitos

```r
install.packages(c("shiny", "bs4Dash"))
```

## Ejecución

```r
shiny::runApp("bs4Dash/APP")
```
