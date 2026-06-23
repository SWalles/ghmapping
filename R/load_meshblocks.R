load_meshblocks <-
function(mb_path, geo_areas_path, ... , redacted = function() {0}) {
  
  geo_areas <- read.csv(geo_areas_path, fileEncoding="UTF-8-BOM")
  mb <- st_read(mb_path)
  
  redact <- sapply(1:nrow(mb), function(x) {redacted()})
  
  mb <- mb |> 
    st_transform(crs = 4326) |> 
    mutate(MB2025_V1_ = as.integer(MB2025_V1_)) |> 
    left_join(geo_areas, by = join_by(MB2025_V1_ == MB2025_code)) |> 
    filter(...) |> 
    # Handle -999 values by substitution with 0 (might do something else)
    mutate(general = ifelse(General_El == -999, redact, General_El),
           maori = ifelse(Maori_Elec == -999, redact, Maori_Elec),
           total = general + maori)
  
  return(mb)
}
