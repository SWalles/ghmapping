ghmapping <- function(simdata, osm_cache, osm_data, out_dir, n_cores = 1, n_chunks = 1) {
  # Order data by destination
  simdata <- simdata[order(simdata$d.SA2),]
  
  # Split chunks
  # Trying to keep destinations together
  cum_dest_count <- cumsum(table(simdata$d.SA2))
  m <- sapply(seq_len(n_chunks), function(i) {
    which.min(abs(cum_dest_count - min(i * nrow(simdata) / n_chunks, nrow(simdata))))
  })
  splits <- rep(1:n_chunks, diff(c(0, cum_dest_count[m])))
  
  # Initiate router
  init_router <- function() {
    router(osm_data, osm_cache)
  }
  
  # Process all chunks
  init_router()
  statistics <- lapply(seq_len(n_chunks), function(i) {
    print(i)
    process_chunk(data = simdata[splits == i,], 
                  out.path = paste0(out_dir, "/chunk_", i, ".RDS"),
                  init.router = FALSE,
                  n_cores = n_cores,
                  stats = TRUE)
  })
  
  return(statistics)
}