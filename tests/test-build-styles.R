# Pruebas de construcción sin dependencias adicionales ----
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[[1]])
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
builder <- new.env(parent = baseenv())
sys.source(file.path(root, "utils", "build_styles.R"), envir = builder)
checks <- 0L
.assert <- function(condition, label) {
  if (!isTRUE(condition)) stop(label, call. = FALSE)
  checks <<- checks + 1L
}
.throws <- function(expr) inherits(tryCatch(force(expr), error = identity), "error")
.read <- function(path) readBin(path, "raw", n = file.info(path)$size)
fixture <- tempfile("styles con espacios ")
dir.create(file.path(fixture, "Styles"), recursive = TRUE)
sources <- c("tokens.css", "racafe-forms.css", "application.css")
invisible(file.copy(file.path(root, "Styles", sources), file.path(fixture, "Styles")))

# Determinismo, precedencia y conservación literal de fuentes ----
builder$.build_styles(root, check = TRUE)
.assert(TRUE, "El archivo del repositorio debe estar actualizado")
builder$.build_styles(fixture)
output <- file.path(fixture, "Styles", "style.css")
first <- .read(output)
mtime <- file.info(output)$mtime
for (i in 1:3) builder$.build_styles(fixture)
.assert(identical(.read(output), first), "Las reconstrucciones no deben acumular reglas")
.assert(identical(file.info(output)$mtime, mtime), "No reescribir un resultado idéntico")
text <- rawToChar(first)
.assert(!grepl("@import", text, fixed = TRUE), "No debe quedar ningún import en el CSS generado")
markers <- vapply(sources, function(name) regexpr(paste0("/* INICIO Styles/", name, " */"), text, fixed = TRUE)[1], 1L)
.assert(all(markers > 0) && all(diff(markers) > 0), "Orden: tokens, componentes, aplicación")
for (name in sources) {
  source <- builder$.styles_read(file.path(fixture, "Styles", name))
  .assert(grepl(sub("\n*$", "", source), text, fixed = TRUE), paste("Conservar comentarios y selectores:", name))
}
.assert(grepl("#DA291C", text, fixed = TRUE), "Conservar el rojo corporativo")
.assert(!.throws(builder$.build_styles(fixture, check = TRUE)), "--check acepta un resultado idéntico")
writeBin(charToRaw("/* desactualizado */"), output)
.assert(.throws(builder$.build_styles(fixture, check = TRUE)), "--check rechaza un resultado desactualizado")
.assert(identical(rawToChar(.read(output)), "/* desactualizado */"), "--check no modifica archivos")
builder$.build_styles(fixture)
.assert(identical(.read(output), first), "Reconstruir devuelve exactamente el resultado original")

# UTF-8 y finales de línea reproducibles ----
tokens <- file.path(fixture, "Styles", "tokens.css")
normalized <- builder$.styles_read(tokens)
writeBin(c(as.raw(c(0xef, 0xbb, 0xbf)), charToRaw(gsub("\n", "\r\n", normalized, fixed = TRUE))), tokens)
builder$.build_styles(fixture)
.assert(identical(.read(output), first), "BOM y CRLF deben producir el mismo UTF-8/LF")
writeBin(charToRaw(normalized), tokens)
invalid <- tempfile("invalid-css-")
writeBin(as.raw(c(0xff, 0xfe)), invalid)
.assert(.throws(builder$.styles_read(invalid)), "Rechazar bytes UTF-8 inválidos")
unlink(invalid)

# Imports redundantes, comentarios y literales ----
imports <- paste0("@import url(\"tokens.css\");\n@IMPORT './racafe-forms.css';\n",
                  "@import url(application.css); /* conservar este comentario */\n",
                  '/* @import url("tokens.css"); comentario */\n',
                  '.ejemplo::before { content: "@import url(tokens.css);"; }\n')
clean <- builder$.styles_without_imports(imports, "fixture")
.assert(!grepl("@IMPORT", clean, fixed = TRUE), "Eliminar imports redundantes sin distinguir mayúsculas")
.assert(grepl("/* conservar este comentario */", clean, fixed = TRUE), "Conservar comentarios junto a imports")
.assert(grepl('/* @import url("tokens.css"); comentario */', clean, fixed = TRUE), "No modificar imports comentados")
.assert(grepl('content: "@import url(tokens.css);"', clean, fixed = TRUE), "No modificar literales CSS")
.assert(.throws(builder$.styles_without_imports('@import "externo.css";', "fixture")), "Rechazar imports desconocidos")
.assert(.throws(builder$.styles_without_imports('@import url(tokens.css) screen;', "fixture")),
        "No suprimir imports condicionales silenciosamente")
.assert(.throws(builder$.styles_without_imports('/* sin cerrar', "fixture")), "Detectar comentarios incompletos")

# Fuentes ausentes o destino utilizado como fuente ----
previous <- .read(output)
unlink(file.path(fixture, "Styles", "tokens.css"))
.assert(.throws(builder$.build_styles(fixture)), "Validar fuentes antes de escribir")
.assert(identical(.read(output), previous), "Un fallo no debe truncar el archivo existente")
invisible(file.copy(file.path(root, "Styles", "tokens.css"), file.path(fixture, "Styles", "tokens.css")))
if (.Platform$OS.type == "unix") {
  unlink(file.path(fixture, "Styles", "application.css"))
  file.symlink(output, file.path(fixture, "Styles", "application.css"))
  .assert(.throws(builder$.build_styles(fixture)), "No permitir una fuente enlazada al destino")
}

# CLI invocada desde otro directorio ----
cli <- normalizePath(file.path(root, "utils", "build_styles.R"))
old_wd <- getwd()
setwd(tempdir())
status <- system2(file.path(R.home("bin"), "Rscript"), c(shQuote(cli), "--check"), stdout = FALSE, stderr = FALSE)
setwd(old_wd)
.assert(identical(status, 0L), "La CLI debe resolver el repositorio fuera del directorio actual")
unlink(fixture, recursive = TRUE)

# Referencia visual congelada de main anterior a la construcción ----
args <- commandArgs(trailingOnly = TRUE)
reference <- sub("^--reference=", "", grep("^--reference=", args, value = TRUE))
if (length(reference)) {
  ref <- "38b65d4"
  blobs <- lapply(c("tokens.css", "racafe-forms.css", "style.css"), function(name) {
    value <- system2("git", c("-C", shQuote(root), "show", paste0(ref, ":Styles/", name)), stdout = TRUE)
    if (!is.null(attr(value, "status"))) stop("No se encontró el commit de referencia ", ref)
    value
  })
  blobs[[3]] <- blobs[[3]][!grepl('^@import url\\("(tokens|racafe-forms)[.]css"\\);$', blobs[[3]])]
  writeLines(unlist(blobs, use.names = FALSE), reference[[1]], useBytes = TRUE)
}
cat(checks, "comprobaciones de construcción superadas.\n")
