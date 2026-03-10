# Compartido

Repositorio de recursos compartidos para aplicaciones del área de analítica.

## Objetivo

Centralizar elementos visuales reutilizables (estilos e imágenes) para mantener una identidad consistente entre aplicaciones.

## Estructura del repositorio

```text
Compartido/
├── README.md
├── Styles/
│   └── style.css
└── img/
    ├── Readme.md
    ├── logo.png
    └── logo2.png
```

## Contenido

### 1) Hoja de estilos globales

Archivo: `Styles/style.css`

Incluye estilos compartidos para aplicaciones web (especialmente dashboards), entre ellos:

- ajustes globales de interfaz,
- tipografías de títulos y texto,
- estilos de tabs,
- clases de apoyo para modales,
- estilos de tablas `reactable`.

> Recomendación: importar este CSS como base y extenderlo en cada proyecto solo cuando sea necesario.

### 2) Recursos gráficos

Carpeta: `img/`

Contiene logos institucionales para uso en interfaces, encabezados o pantallas de inicio.

Ver detalle en `img/Readme.md`.

## Uso sugerido

### Consumir este repositorio desde otro proyecto

Opciones habituales:

1. **Submódulo de Git** (recomendado cuando se desea trazabilidad de versiones).
2. **Copia controlada** en la etapa de build/deploy.
3. **Referencia por ruta compartida** dentro de la infraestructura interna.

### Importar estilos

Ejemplo HTML:

```html
<link rel="stylesheet" href="Styles/style.css">
```

Ejemplo en Shiny (R):

```r
tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "Styles/style.css"))
```

## Buenas prácticas para contribuir

- Mantener nombres de archivos descriptivos y estables.
- Evitar cambios disruptivos en clases CSS compartidas; preferir extender antes que romper.
- Documentar cualquier nuevo recurso en el README correspondiente.
- Optimizar imágenes antes de agregarlas al repositorio.

## Versionado recomendado

Cuando haya cambios relevantes, considerar versionar con tags (`vMAJOR.MINOR.PATCH`):

- **MAJOR**: cambios incompatibles en estilos/clases,
- **MINOR**: nuevas clases o recursos compatibles,
- **PATCH**: correcciones menores sin impacto funcional.

## Contacto de mantenimiento

Definir aquí el equipo o persona responsable de aprobar cambios en recursos compartidos.
