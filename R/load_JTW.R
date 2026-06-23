load_JTW <- 
  function(jtw_path, redacted = function() {0}, min_trips = 0.01) {
  
  jtw <- read.csv(jtw_path, fileEncoding="UTF-8-BOM")
  
  redact <- sapply(1:nrow(jtw), function(x) {redacted()})
  
  jtw  |> 
    rename(s.SA2 = SA22023_V1_00_usual_residence_address,
           d.SA2 = SA22023_V1_00_workplace_address,
           private = X2023_Drive_a_private_car_truck_or_van,
           work = X2023_Drive_a_company_car_truck_or_van) |>
    mutate(private = ifelse(private == -999, redact, private),
           work = ifelse(work == -999, redact, work),
           total_trips = private + work) |>
    select(s.SA2, d.SA2, private, work, total_trips) |>
    filter(total_trips >= min_trips)
}
