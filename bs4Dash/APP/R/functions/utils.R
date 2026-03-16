# Paleta corporativa Racafe ----
paleta_racafe <- function(n = 5) {
  cols <- c("#c0392b", "#e74c3c", "#922b21", "#f1948a", "#fadbd8",
            "#e67e22", "#d35400", "#f0b27a", "#2c3e50", "#85929e")
  cols[seq_len(min(n, length(cols)))]
}
