join_graphs_on_coordinates <- function(g_list, paths = FALSE) {
  st <- list() # list to record statistics
  st$join_time <- list()
  # Convert 1st graph to tables as current graph
  if (paths) {
    temp <- readRDS(g_list[[1]])
  } else {
    temp <- g_list[[1]]
  }
  st$chunk_sizes <- list(object.size(temp))
  g1v <- as_data_frame(temp, "vertices")
  g1e <- as_data_frame(temp, "edges")
  
  for (i in 2:length(g_list)) {
    # Convert next graph to tables
    if (paths) {
      temp <- readRDS(g_list[[i]])
    } else {
      temp <- g_list[[i]]
    }
    st$chunk_sizes[[i]] <- object.size(temp)
    g2v <- as_data_frame(temp, "vertices")
    g2e <- as_data_frame(temp, "edges")
    
    # Join with current graph tables
    st$join_time[[i-1]] <- system.time({
      joined <- join_graph_tables(g1v, g2v, g1e, g2e)
    })
    
    # Update current graph tables
    g1v <- joined$V
    g1e <- joined$E
    
    cat(i, " graphs have been joined\n")
  }
  
  # Return final graph as igraph
  combined_graph <- graph_from_data_frame(d = g1e, directed = TRUE, vertices = g1v)
  st$combined_size <- object.size(combined_graph)
  
  return(list(G = combined_graph, stats = st))
}
