compress_chains <- function(G) {
  interior <- which(degree(G, mode="in") == 1 & degree(G, mode="out") == 1)
  interior_set <- logical(vcount(G))
  interior_set[interior] <- TRUE
  
  visited <- logical(vcount(G))
  new_edges <- integer(0)
  new_weights <- numeric(0)
  new_dists <- numeric(0)
  to_delete <- integer(0)
  
  total <- 0
  
  for (V in interior) {
    if (visited[V]) next
    
    count <- 1
    
    # walk backwards to chain head
    interior_head <- V
    while (interior_set[as.integer(neighbors(G, interior_head, mode="in"))]) {
      interior_head <- as.integer(neighbors(G, interior_head, mode="in"))
      
      count <- count + 1
    }
    head <- as.integer(neighbors(G, interior_head, mode="in"))
    
    # walk forwards to chain tail
    tail <- interior_head
    chain <- integer(0)
    while (interior_set[tail]) {
      visited[tail] <- TRUE
      chain <- c(chain, tail)
      tail <- as.integer(neighbors(G, tail, mode="out"))
      
      count <- count + 1
    }
    
    # Aggregate edge attributes
    old_edges <- get_edge_ids(G, data.frame(c(head, chain), c(chain, tail)))
    new_weights <- c(new_weights, E(G)[old_edges[1]]$weight)
    new_dists <- c(new_dists, sum(E(G)[old_edges]$dist))
    
    new_edges <- c(new_edges, head, tail)
    to_delete <- c(to_delete, chain)
    
    total <- total + count
    cat(total, "/", length(interior), "\n")
  }
  
  # Remove chains
  G <- add_edges(G, new_edges, attr = list(weight = new_weights, dist = new_dists))
  G <- delete_vertices(G, to_delete)
  return(G)
}
