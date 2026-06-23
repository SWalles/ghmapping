aggregate_routes <- function(
    routes, 
    weight = rep(1, length(unique(routes[,"index"]))),
    reduce = TRUE) {
  # routes: matrix returned by the route function
  # weight: a weight for each route - multiplied with aggregate counts
  # reduce: should non intersecting vertices be eliminated    
  
  n_routes <- length(unique(routes[,"index"]))
  if (!n_routes == length(weight)) stop("Length of weight must match the number of routes")
  
  # Label points as unique vertices
  points <- as.data.table(routes)
  points[, id := .GRP, by = .(lat, lon)]
  
  # Calculate edges between vertices
  point_counts <- tabulate(points[,index])
  point_counts <- point_counts[point_counts > 0]
  ind_last <- cumsum(point_counts)
  ind_first <- c(1, ind_last[-length(ind_last)] + 1)
  segments <- cbind(points[-ind_last, -3], points[-ind_first,])
  segments[,weight := rep(weight, point_counts - 1)][]
  colnames(segments) <- c("from_lat", "from_lon", "from", "to_lat", "to_lon", "trip", "to", "weight")
  segments[,dist := haversine_distance(from_lat, from_lon, to_lat, to_lon)][]
  
  # Create igraph
  V <- unique(points[,c("id", "lat", "lon")], by = "id")
  E <- segments[,c("from", "to", "weight", "dist")]
  G <- simplify(graph_from_data_frame(E, vertices = V, directed = TRUE),
                remove.multiple = TRUE,
                remove.loops = TRUE,
                edge.attr.comb = list(weight = "sum", dist = "first", "ignore"))
  
  if (!reduce) 
    return(G)
  else
    # Contract graph by removing vertices with degree > 2
    return(compress_chains(G))
}