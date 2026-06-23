process_chunk <- function(data, out.path, init.router = TRUE, n_cores = 1, stats = TRUE) {
  # Initialize router if required
  if (init.router) init_router()
  
  # List to store statistics
  st <- list()
  
  # Calculate routes
  st$route_time <- system.time({ 
    sim_routes <- route(as.matrix(data[,c("s.lat", "s.lon", "d.lat", "d.lon")]), threads = n_cores) 
  })
  
  # Remove weights of failed routes
  failed <- which(tabulate(sim_routes[,"index"], nbins = nrow(data)) == 0)
  if (length(failed) > 0) 
    weights <- data$weight[-failed] 
  else 
    weights <- data$weight
  
  # Aggregate in graph
  st$agg_time <- system.time({
    chunk_graph <- aggregate_routes(sim_routes, weight = weights, reduce = FALSE)
  })
  
  saveRDS(chunk_graph, out.path)
  
  # Calculate statistics
  if (stats) {
    # Route matrix statistics
    st$route_mat_size <- object.size(sim_routes)
    st$n_routes <- nrow(data)
    st$route_point_counts <- tabulate(sim_routes[,"index"])
    st$failed <- length(failed)
    
    # Graph statistics
    st$graph_size <- object.size(chunk_graph)
    st$n_edges <- ecount(chunk_graph)
    st$n_verices <- vcount(chunk_graph)
    
    return(st)
  }
}