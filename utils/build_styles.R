# Construcción determinista del CSS compatible con includeCSS ----
.styles_read <- function(path) {
  raw <- readBin(path, what = "raw", n = file.info(path)$size)
  text <- rawToChar(raw)
  if (is.na(iconv(text, from = "UTF-8", to = "UTF-8", sub = NA_character_))) {
    stop("El archivo no contiene UTF-8 válido: ", path, call. = FALSE)
  }
  Encoding(text) <- "UTF-8"
  text <- sub("^\ufeff", "", text)
  gsub("\r\n?", "\n", text, perl = TRUE)
}

# Quitar solo imports de fuentes consolidadas, sin tocar comentarios ni literales ----
.styles_without_imports <- function(text, source) {
  chars <- strsplit(text, "", fixed = TRUE)[[1]]
  total <- length(chars)
  i <- 1L
  comment <- FALSE
  quote <- ""
  escaped <- FALSE
  ranges <- list()
  while (i <= total) {
    char <- chars[[i]]
    next_char <- if (i < total) chars[[i + 1L]] else ""
    if (comment) {
      if (char == "*" && next_char == "/") { comment <- FALSE; i <- i + 1L }
    } else if (nzchar(quote)) {
      if (escaped) escaped <- FALSE
      else if (char == "\\") escaped <- TRUE
      else if (char == quote) quote <- ""
    } else if (char == "/" && next_char == "*") {
      comment <- TRUE
      i <- i + 1L
    } else if (char %in% c("'", '"')) {
      quote <- char
    } else if (char == "@") {
      remaining <- paste(chars[i:total], collapse = "")
      pattern <- paste0("(?is)^@import\\s+(?:url\\(\\s*['\"]?([^'\"()[:space:]]+)['\"]?\\s*\\)",
                        "|['\"]([^'\"]+)['\"])\\s*;")
      match <- regmatches(remaining, regexec(pattern, remaining, perl = TRUE))[[1]]
      if (length(match)) {
        target <- sub("^[.]/", "", paste0(match[[2]], match[[3]]))
        if (!target %in% c("tokens.css", "racafe-forms.css", "racafe-modal-sizes.css", "racafe-controls.css", "application.css")) {
          stop("Import no autocontenido en ", source, ": ", target, call. = FALSE)
        }
        end <- i + nchar(match[[1]]) - 1L
        ranges[[length(ranges) + 1L]] <- seq.int(i, end)
        i <- end
      } else if (grepl("(?i)^@import\\b", remaining, perl = TRUE)) {
        stop("Import no admitido en ", source, "; consolide su fuente explícitamente.", call. = FALSE)
      }
    }
    i <- i + 1L
  }
  if (comment || nzchar(quote)) stop("Comentario o literal CSS sin cerrar en ", source, call. = FALSE)
  if (length(ranges)) chars <- chars[-unlist(ranges, use.names = FALSE)]
  paste(chars, collapse = "")
}

# Las fuentes nunca incluyen el archivo de destino ----
.build_styles <- function(root, check = FALSE) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  sources <- file.path("Styles", c("tokens.css", "racafe-forms.css", "racafe-modal-sizes.css", "racafe-controls.css", "application.css"))
  paths <- file.path(root, sources)
  missing <- sources[!file.exists(paths) | dir.exists(paths)]
  if (length(missing)) stop("Faltan fuentes CSS: ", paste(missing, collapse = ", "), call. = FALSE)
  destination <- file.path(root, "Styles", "style.css")
  canonical <- normalizePath(paths, winslash = "/", mustWork = TRUE)
  if (anyDuplicated(canonical) || normalizePath(destination, winslash = "/", mustWork = FALSE) %in% canonical) {
    stop("style.css no puede ser fuente de construcción; las fuentes deben ser distintas.", call. = FALSE)
  }
  sections <- vapply(seq_along(paths), function(i) {
    text <- .styles_without_imports(.styles_read(paths[[i]]), sources[[i]])
    text <- sub("\n*$", "", text)
    paste0("/* INICIO ", sources[[i]], " */\n", text, "\n/* FIN ", sources[[i]], " */\n")
  }, character(1))
  header <- paste0("/* ARCHIVO GENERADO: no editar. Fuentes: tokens.css, racafe-forms.css, ",
                   "racafe-modal-sizes.css, racafe-controls.css, application.css.\n",
                   "   Reconstruir: Rscript utils/build_styles.R\n",
                   "   Compatible con includeCSS(): no depende de imports relativos. */\n\n")
  bytes <- charToRaw(enc2utf8(paste0(header, paste(sections, collapse = "\n"))))
  current <- if (file.exists(destination)) readBin(destination, "raw", n = file.info(destination)$size) else raw()
  if (check && !identical(current, bytes)) {
    stop("Styles/style.css está desactualizado. Ejecute Rscript utils/build_styles.R", call. = FALSE)
  }
  if (!check && !identical(current, bytes)) writeBin(bytes, destination)
  invisible(destination)
}

# Ejecución desde cualquier directorio, sin dependencias adicionales ----
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  check <- "--check" %in% args
  args <- args[args != "--check"]
  if (length(args) > 1L || any(startsWith(args, "--"))) {
    stop("Uso: Rscript utils/build_styles.R [--check] [raíz del repositorio]", call. = FALSE)
  }
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[[1]])
  root <- if (length(args)) args[[1]] else file.path(dirname(normalizePath(script)), "..")
  destination <- .build_styles(root, check)
  cat(if (check) "CSS actualizado:" else "CSS construido:", destination, "\n")
}
