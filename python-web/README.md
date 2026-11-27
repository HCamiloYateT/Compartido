# Plantillas web para Python

Recursos base para páginas corporativas construidas con Jinja2. Son compatibles con
FastAPI y Flask porque no dependen de funciones específicas del framework, Bootstrap,
jQuery ni recursos externos.

## Contenido

```text
python-web/
├── VERSION
├── templates/
│   ├── base.html
│   ├── page.html
│   └── form.html
└── static/
    └── css/
        └── racafe-web.css
```

- `base.html`: encabezado, logos, contenedor principal, footer y bloques extensibles.
- `page.html`: título, descripción y área general de contenido.
- `form.html`: formulario corporativo de dos columnas con mensajes y acciones.
- `racafe-web.css`: tokens, tipografía, tarjetas, formularios, botones, estados, modales y diseño responsivo.

Las clases usan el prefijo `rfw-` para no interferir con estilos propios de una aplicación.
Roboto se usa para texto general y Source Serif Pro para títulos. El CSS no descarga fuentes;
la aplicación o el sistema debe proporcionarlas si se requiere evitar las alternativas locales.

## Copia recomendada

Desde la raíz de `Compartido`:

```sh
mkdir -p mi_app/templates mi_app/static/css mi_app/static/img
cp python-web/templates/*.html mi_app/templates/
cp python-web/static/css/racafe-web.css mi_app/static/css/
cp img/logo.png img/logo2.png mi_app/static/img/
```

No publique el repositorio completo como directorio estático. Exponga únicamente `static/`.

## Variables de plantilla

| Variable | Uso | Valor predeterminado |
|---|---|---|
| `static_prefix` | Prefijo público para CSS e imágenes | `/static` |
| `home_url` | Enlace del logo | `/` |
| `application_name` | Nombre mostrado en el encabezado | `Aplicación corporativa` |
| `page_title` | Título de ventana y página | `Aplicación Racafé` |
| `page_description` | Introducción opcional | vacío |
| `eyebrow` | Categoría superior opcional | vacío |
| `footer_text` | Texto derecho del footer | vacío |

## FastAPI

```python
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

@app.get("/")
def inicio(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="page.html",
        context={
            "page_title": "Gestión de terceros",
            "application_name": "Gestión documental",
            "eyebrow": "CONTROL INTERNO",
        },
    )
```

## Flask

```python
from flask import Flask, render_template

app = Flask(__name__, template_folder="templates", static_folder="static")

@app.get("/")
def inicio():
    return render_template(
        "page.html",
        page_title="Gestión de terceros",
        application_name="Gestión documental",
        eyebrow="CONTROL INTERNO",
    )
```

## Extensión

Una página específica debe extender `page.html` o `form.html`:

```html
{% extends "form.html" %}

{% block form_fields %}
  <div class="rfw-form-grid">
    <!-- Campos propios de la aplicación -->
  </div>
{% endblock %}
```

Mantenga las reglas particulares fuera de `racafe-web.css`. Si un componente resulta
reutilizable en varias aplicaciones, agréguelo con una clase `rfw-` y documente su contrato.
