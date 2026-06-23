haversine_distance <- function(lat1, lon1, lat2, lon2) {
  R <- 6371000  # Earth's radius in metres
  to_rad <- function(deg) deg * pi / 180
  
  dlat <- to_rad(lat2 - lat1)
  dlon <- to_rad(lon2 - lon1)
  
  a <- sin(dlat/2)^2 +
    cos(to_rad(lat1)) * cos(to_rad(lat2)) * sin(dlon/2)^2
  
  R * 2 * atan2(sqrt(a), sqrt(1 - a))
}