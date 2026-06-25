library(ghmapping)

# This file can be used as a template to run an analysis using the ghmapping package for routes ending in Auckland City.

jtw_path <- "data/JTW/2023-census-main-means-of-travel-to-work-by-statistical-area.csv"
mb_path <- "data/meshblock/2023-census-electoral-population-at-meshblock-level-2025-mes.shp"
geo_areas_path <- "data/geographic-areas-table-2025.csv"
osm_cache <- "data/osm/cache"
osm_data <- "data/osm/new-zealand-latest.osm.pbf"
out_dir <- "out"

# Download files if necessary
if (any(!file.exists(c(jtw_path, mb_path, geo_areas_path, osm_data))) | any(!dir.exists(c(osm_cache, out_dir)))) {
  system("make")
}

# Load data from file and compile into a dataset to be routed
jtw <- load_JTW(jtw_path, redacted = function() {sample(1:6)}, min_trips = 10)
mb <- load_meshblocks(mb_path, geo_areas_path,
                      redacted = function() {sample(1:6)}
                      )
simdata <- setup_simulation(jtw, mb, min_weight = 2)

# Now we can restrict the destinations to our area of interest - in this case Auckland City
# Find Auckland SA2 Areas
geo_areas <- read.csv(geo_areas_path)
auck_sa2 <- unique(geo_areas[geo_areas$TA2025_name_ascii == "Auckland", "SA22023_code"])

# Filter simdata
simdata <- simdata[simdata$d.SA2 %in% auck_sa2,]

# Run the mapping function to calculate all  routes and aggregate them.
# For example we're using 6 cores and processing in 5 parts
# Assigning the function execution to a variable gives you run time statistics
stats <- ghmapping(simdata, sort_col = "d.SA2", osm_cache, osm_data, out_dir, n_cores = 6, n_chunks = 5)

# Now we combine the seven batch graphs into the final result
# Get graph chunk file names
chunk_files <- list.files(out_dir, "chunk")
graph_list <- as.list(paste0(out_dir, "/", chunk_files))

# Combine all chunks into a single graph
combined <- join_graphs_on_coordinates(graph_list, paths = TRUE) 
network <- combined$G

# you can optionally compress the network as follows
# Process has some efficiency issues with larger networks
# In this case can take around 37 minutes
# compressed <- compress_chains(network)

# Now the network can be plotted like below
# Requires snippets package (see help file)
library(snippets)
library(RColorBrewer)
library(igraph)

# Function top plot networks
plot_network <- function(G, ..., add = FALSE) {
  if (!add) {plot.new(); plot.window(xlim = range(V(G)$lon), ylim = range(V(G)$lat))}   
  
  # Calculate segment coordinates
  el <- ends(G, E(G)) 
  from_x <- V(G)[el[, 1]]$lon
  from_y <- V(G)[el[, 1]]$lat
  to_x   <- V(G)[el[, 2]]$lon
  to_y   <- V(G)[el[, 2]]$lat
  
  blue_scale <- function(x, power = 0.3) {
    scaled <- log1p(x - min(x, na.rm = TRUE))
    scaled <- (scaled / max(scaled, na.rm = TRUE)) ^ power
    rgb(scaled, scaled, 1)
  }
  
  #points(V(G)$lon, V(G)$lat, pch=19, cex=0.2, ...)
  segments(from_x, from_y, to_x, to_y, lwd = log(E(G)$weight, base = 2) / 3, col = blue_scale(E(G)$weight, power = 1.5), ...)
}

# Plot full network
tiles <- function() osmap(cache.dir=osm_cache)

par(mar=rep(0,4))
# Boundary box of coordinates to include in the plot
bb0 = c(175.078244, 174.530397, -37.046253, -36.725161)
plot(bb0[1:2], bb0[3:4], ty='n', axes=F, asp=1/cos(mean(bb0[3:4])/180*pi))
bb = par("usr")
tiles()
plot_network(network, add = TRUE)
# Destinations
points(simdata$d.lon, simdata$d.lat, pch = 19, col = "red", cex = 0.5)

