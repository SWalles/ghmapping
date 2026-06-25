\name{ghmapping}
\alias{ghmapping}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Maps routes and aggregates weights into a graph 
}
\description{
Recieves a data frame as produced by \code{\link{setup_simulation}} and calculates each route and aggregates them into a graph saved to the disk as an RDS file. Supports parallel route computation. Option to process in batches when memory is limited. You can use the \code{\link{join_graphs_on_coordinates}} function to join the graphs from each batch back together into a single result.
}
\usage{
ghmapping(simdata, sort_col, osm_cache, osm_data, out_dir, n_cores = 1, n_chunks = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{simdata}{
A data frame as produced by the \code{\link{setup_simulation}} function. Or a custom data frame with columns named: "s.lat", "s.lon", "d.lat", "d.lon", "weight" representing origin latitude, origin longitude, destination latitude, destination longitude, and route weight respectively.
}
\item{sort_col}{
A single string value that specifies the name of the column of simdata that specifies groups that should be batched together. Any value that is not a valid column name in simdata will result in an equal split with a warning.
}
  \item{osm_cache}{
A string value containing the path to a directory to be used for Open Street Maps caching.
}
  \item{osm_data}{
A string value containing the path to a Open Street Maps .pbf file.
}
  \item{out_dir}{
A string value containing the path to an output directory where the function saves its results as RDS files. Path should NOT have a trailing "/".
}
  \item{n_cores}{
Number of cores that should be used for calculating routes.
}
  \item{n_chunks}{
Number of chunks to break the simulation into during batched processing. Set n_chunks = 1 for no batch processing.
}
}
\value{
Returns a list containing performance statistics about the task. The resulting traffic graphs are saved in the output directory as RDS files.
}
\references{
Open Street Map data can be downloaded \href{https://download.geofabrik.de/australia-oceania/new-zealand.html}{HERE}.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
## simdata <- readRDS(simdata.RDS")[1:1000,]
## osm_cache <- "./osm"
## osm_data <- "./osm/new-zealand-latest.osm.pbf"
## out_dir <- "./out"

## stats <- ghmapping(simdata, osm_cache, osm_data, out_dir, n_cores = 6, n_chunks = 2)

## The function is currently defined as
function (simdata, osm_cache, osm_data, out_dir, n_cores = 1, 
    n_chunks = 1) 
{
    simdata <- simdata[order(simdata$d.SA2), ]
    cum_dest_count <- cumsum(table(simdata$d.SA2))
    m <- sapply(seq_len(n_chunks), function(i) {
        which.min(abs(cum_dest_count - min(i * nrow(simdata)/n_chunks, 
            nrow(simdata))))
    })
    splits <- rep(1:n_chunks, diff(c(0, cum_dest_count[m])))
    init_router <- function() {
        router(osm_data, osm_cache)
    }
    init_router()
    statistics <- lapply(seq_len(n_chunks), function(i) {
        print(i)
        process_chunk(data = simdata[splits == i, ], out.path = paste0(out_dir, 
            "/chunk_", i, ".RDS"), init.router = FALSE, n_cores = n_cores, 
            stats = TRUE)
    })
    return(statistics)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
