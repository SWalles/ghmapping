setup_simulation <-
function(jtw, mb, min_pop = 0.01, min_weight = 0.01) {
  # Calculate the starting coordinates and some simplification
  mb_coords <- mb |>
    mutate(centroids = st_centroid(geometry),
           s.lon = st_coordinates(centroids)[, 1],
           s.lat = st_coordinates (centroids)[, 2]) |>
    st_drop_geometry() |>
    select(MB2025_V1_, SA22023_code, general, maori, total, s.lon, s.lat) |>
    filter(total >= min_pop) |>
    group_by(SA22023_code) |>
    mutate(SA2_total = sum(total)) |>
    ungroup()
  
  # Calculate the destination coordinates
  wp_coords <- mb |> 
    group_by(SA22023_code) |>
    summarise(geometry = st_union(geometry)) |>
    mutate(centroids = st_centroid(geometry),
           d.lon = st_coordinates(centroids)[, 1],
           d.lat = st_coordinates (centroids)[, 2]) |>
    st_drop_geometry() |>
    select(SA22023_code, d.lon, d.lat)
  
  # combine all in simulation set
  simdata <- jtw |>
    left_join(mb_coords, by = join_by(s.SA2 == SA22023_code), relationship = "many-to-many") |>
    left_join(wp_coords, by = join_by(d.SA2 == SA22023_code)) |>
    # Calculate weights
    group_by(s.SA2) |>
    mutate(weight = round(total_trips * (total / SA2_total))) |>
    ungroup() |>
    filter(weight >= min_weight)
  
  simdata
}
