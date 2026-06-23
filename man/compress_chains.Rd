\name{compress_chains}
\alias{compress_chains}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Eliminates chains from a graph
}
\description{
Reduces an igraph graph object by eliminating chains of vertices that have exactly one in degree and one out degree and connects their parent and child vertices. 
}
\usage{
compress_chains(G)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{G}{
An igraph graph object to be reduced.
}
}
\value{
Returns an igraph graph object that has been reduced as described above.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
## G <- <graph definition>
##G_reduced <- compress_chains(G)

## The function is currently defined as
function (G) 
{
    interior <- which(degree(G, mode = "in") == 1 & degree(G, 
        mode = "out") == 1)
    interior_set <- logical(vcount(G))
    interior_set[interior] <- TRUE
    visited <- logical(vcount(G))
    new_edges <- integer(0)
    new_weights <- numeric(0)
    new_dists <- numeric(0)
    to_delete <- integer(0)
    for (V in interior) {
        if (visited[V]) 
            next
        interior_head <- V
        while (interior_set[as.integer(neighbors(G, interior_head, 
            mode = "in"))]) {
            interior_head <- as.integer(neighbors(G, interior_head, 
                mode = "in"))
        }
        head <- as.integer(neighbors(G, interior_head, mode = "in"))
        tail <- interior_head
        chain <- integer(0)
        while (interior_set[tail]) {
            visited[tail] <- TRUE
            chain <- c(chain, tail)
            tail <- as.integer(neighbors(G, tail, mode = "out"))
        }
        old_edges <- get_edge_ids(G, data.frame(c(head, chain), 
            c(chain, tail)))
        new_weights <- c(new_weights, E(G)[old_edges[1]]$weight)
        new_dists <- c(new_dists, sum(E(G)[old_edges]$dist))
        new_edges <- c(new_edges, head, tail)
        to_delete <- c(to_delete, chain)
    }
    G <- add_edges(G, new_edges, attr = list(weight = new_weights, 
        dist = new_dists))
    G <- delete_vertices(G, to_delete)
    return(G)
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
