# Utilidades para descarga y procesamiento de capas GeoJSON del DANE (MGN 2025)
#
# Este archivo define URLs de descarga para departamentos y municipios,
# además de una función utilitaria que:
# 1) descarga el ZIP del DANE,
# 2) extrae el archivo GeoJSON/JSON,
# 3) lo lee como objeto `sf`,
# 4) transforma el CRS a EPSG:4326, y
# 5) guarda el resultado en formato RDS.

# URL del conjunto de departamentos (límite político).
url_dpto <- paste0(
  "https://geoportal.dane.gov.co/descargas/mgn_2025/",
  "MGN2025_ADM_DPTO_POLITICO_(geojson).zip"
)

# URL del conjunto de municipios (representación gráfica).
url_mun <- paste0(
  "https://geoportal.dane.gov.co/descargas/mgn_2025/",
  "MGN2025_ADM_MPIO_GRAFICO_(geojson).zip"
)

#' Descargar, leer y guardar como RDS un GeoJSON del DANE dentro de un ZIP
#'
#' @description
#' Descarga un archivo ZIP desde una URL del DANE, busca el primer archivo
#' `.json` o `.geojson` dentro del comprimido (incluyendo subcarpetas),
#' lo lee con `sf::st_read()`, lo transforma a coordenadas geográficas
#' (`EPSG:4326`) y guarda el objeto resultante con `saveRDS()`.
#'
#' @param url `character(1)`. URL del archivo ZIP a descargar.
#' @param rds_path `character(1)`. Ruta de salida para guardar el archivo `.rds`.
#'
#' @return Invisiblemente, devuelve la ruta `rds_path` donde se guardó el RDS.
#'
#' @details
#' - Crea archivos/carpetas temporales y los elimina al salir de la función.
#' - Si no encuentra un archivo `.json`/`.geojson` en el ZIP, detiene la ejecución
#'   con un mensaje de error.
#'
#' @examples
#' \dontrun{
#' dane_leer_geojson(url_dpto, "data/dpto_2025.rds")
#' dane_leer_geojson(url_mun, "data/mun_2025.rds")
#' }
dane_leer_geojson <- function(url, rds_path) {
  tmp_zip <- tempfile(fileext = ".zip")
  tmp_dir <- tempfile()
  dir.create(tmp_dir)

  on.exit(unlink(c(tmp_zip, tmp_dir), recursive = TRUE), add = TRUE)

  download.file(url, destfile = tmp_zip, mode = "wb", quiet = TRUE)
  unzip(tmp_zip, exdir = tmp_dir)

  geojson_file <- list.files(
    tmp_dir,
    pattern = "\\.(json|geojson)$",
    full.names = TRUE,
    recursive = TRUE
  )[1]

  if (is.na(geojson_file) || !nzchar(geojson_file)) {
    stop("No se encontró archivo .json o .geojson dentro del ZIP descargado.")
  }

  sf::st_read(geojson_file, quiet = TRUE) |>
    sf::st_transform(crs = 4326) |>
    saveRDS(file = rds_path)

  invisible(rds_path)
}
