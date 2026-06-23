join_graph_tables <- function(g1v, g2v, g1e, g2e) {
  # Combine vertices
  vertices <- rbindlist(list(
    as.data.table(g1v)[, original_id := paste0("g1_", name)],
    as.data.table(g2v)[, original_id := paste0("g2_", name)]
  ))
  
  # Merge vertices at the same coordinates and assign new ids
  unique_vertices <- unique(vertices, by = c("lat", "lon"))
  unique_vertices[, id := .I]
  
  # Map original ids to new unique ids
  vertices[unique_vertices, on = .(lat, lon), merged_id := i.id]
  
  # Combine edges with prefixed vertex references
  g1_edges <- as.data.table(g1e)[, `:=`(from = paste0("g1_", from), to = paste0("g1_", to))]
  g2_edges <- as.data.table(g2e)[, `:=`(from = paste0("g2_", from), to = paste0("g2_", to))]
  edges <- rbindlist(list(g1_edges, g2_edges))
  
  # Joins with merged vertex references
  edges[vertices, on = .(from = original_id), from_merged := i.merged_id]
  edges[vertices, on = .(to = original_id), to_merged := i.merged_id]
  
  # Aggregate weight and distance over edges
  edges <- edges[, .(weight = sum(weight), dist = first(dist)), by = .(from_merged, to_merged)]
  
  # Cleanup
  setnames(edges, old = c("from_merged", "to_merged"), new = c("from", "to"))
  unique_vertices[,`:=`(name = id, original_id = NULL, id = NULL)]
  
  # Return edge and vertex data.tables
  return(list(V = unique_vertices, E = edges))
}