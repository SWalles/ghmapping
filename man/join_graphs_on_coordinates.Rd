\name{join_graphs_on_coordinates}
\alias{join_graphs_on_coordinates}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Join multiple traffic graphs into one
}
\description{
Function to join multiple graphs from created through this package by merging vertices with the same coordinates and aggregating weight values on the edges.
}
\usage{
join_graphs_on_coordinates(g_list, paths = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{g_list}{
Either a list of appropriate igraph graph objects OR a list of filenames pointing to RDS files that stores appropriate igraph graph objects.
}
  \item{paths}{
A boolean value where TRUE indicates that the 'g_list' arguement passed is a list of file paths. FALSE indicates a list of  appropriate igraph graph objects.
}
}
\value{
Returns a list with two named values:
  \describe{
    \item{G}{The igraph graph object obtained after unification.}
    \item{stats}{A list containg statistics about the running efficiency of the task}
  }
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
## # Get graph chunk file names
## chunk_dir <- "./out"
## chunk_files <- list.files(chunk_dir, "chunk")

## # Combine all chunks into a single graph
## graph_list <- as.list(paste0(chunk_dir, "/", chunk_files))
## combined <- join_graphs_on_coordinates(graph_list, paths = TRUE)

## The function is currently defined as
function (g_list, paths = FALSE) 
{
    st <- list()
    st$join_time <- list()
    if (paths) {
        temp <- readRDS(g_list[[1]])
    }
    else {
        temp <- g_list[[1]]
    }
    st$chunk_sizes <- list(object.size(temp))
    g1v <- as_data_frame(temp, "vertices")
    g1e <- as_data_frame(temp, "edges")
    for (i in 2:length(g_list)) {
        if (paths) {
            temp <- readRDS(g_list[[i]])
        }
        else {
            temp <- g_list[[i]]
        }
        st$chunk_sizes[[i]] <- object.size(temp)
        g2v <- as_data_frame(temp, "vertices")
        g2e <- as_data_frame(temp, "edges")
        st$join_time[[i - 1]] <- system.time({
            joined <- join_graph_tables(g1v, g2v, g1e, g2e)
        })
        g1v <- joined$V
        g1e <- joined$E
        cat(i, " graphs have been joined\n")
    }
    combined_graph <- graph_from_data_frame(d = g1e, directed = TRUE, 
        vertices = g1v)
    st$combined_size <- object.size(combined_graph)
    return(list(G = combined_graph, stats = st))
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
