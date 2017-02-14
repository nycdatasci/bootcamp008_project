library(dplyr)

windowed.bar.chart <- function(df, filter.col, filter.val, size.left, size.right) {
  idx <- which(df[, filter.col] == filter.val)
  # range will be 4 above and below
  idx.a <- idx - size.left
  idx.b <- idx + size.right
  # but if we go out of range on one side, we want more on the other so we keep the same total
  num.rows <- nrow(df)
  if (idx.a < 1) {
    idx.b <- idx.b + (1 - idx.a)
    idx.a <- 1
  } else if (idx.b > num.rows) {
    idx.a <- idx.a - (idx.b - num.rows)
    idx.b <- num.rows
  }
  df <- df[idx.a:idx.b, ]
  df <- df %>% mutate(damage.style = "blue")
  df[idx - idx.a + 1, "damage.style"] <- "gold"
  return(df)
}

length.check <- function(slat, slon, elat, elon, len) {
  d <- distm(as.matrix(cbind(slon, slat)), as.matrix(cbind(elon, elat)), fun = distHaversine) / 1000 * 0.621
  d <- diag(d)
  dd <- abs(d - len)
  return( (dd / len) < 0.2 )
}
