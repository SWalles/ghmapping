\name{aggregate_routes}
\alias{aggregate_routes}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Aggregates routes from a matrix
}
\description{
Aggregates routes from the `ghroute::route` function's matrix output into a graph. Vertices represent points along a route and edges the bits of road between. Also calculates an aggregate weight value form a user specified weight.
}
\usage{
aggregate_routes(routes, weight = rep(1, length(unique(routes[, "index"]))), reduce = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{routes}{
A matrix from produced by the `ghroute::route` function. Matrix should have three columns: "lat", "lon", "index" with the latitude and longitude of points along a route as well as the route number that the point is a part of. Routes following the same road should have identical coordinates points along that road.
}
  \item{weight}{
A numeric vector the same length as the number of unique "index" values in `routes`.
}
  \item{reduce}{
A boolean value indicating whether the fucntion \code{\link{compress_chains}} should be called before the result is returned.
}
}
\value{
Returns an igraph graph object containing the result traffic network with coordinate values on the vertices and weight and distance values on the edges.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
## routes_matrix <- ghroute::route(<arguements>) # See ghroute::route documentation
## weights <- rep(1, length(unique(routes_matrix[,"index"])))

## traffic <- aggregate_routes(routes_matrix, weight = weights, reduce = FALSE)

## The function is currently defined as
function (routes, weight = rep(1, length(unique(routes[, "index"]))), 
    reduce = TRUE) 
{
    n_routes <- length(unique(routes[, "index"]))
    if (!n_routes == length(weight)) 
        stop("Length of weight must match the number of routes")
    points <- as.data.table(routes)
    points[, `:=`(id, .GRP), by = .(lat, lon)]
    point_counts <- tabulate(points[, index])
    point_counts <- point_counts[point_counts > 0]
    ind_last <- cumsum(point_counts)
    ind_first <- c(1, ind_last[-length(ind_last)] + 1)
    segments <- cbind(points[-ind_last, -3], points[-ind_first, 
        ])
    segments[, `:=`(weight, rep(weight, point_counts - 1))][]
    colnames(segments) <- c("from_lat", "from_lon", "from", "to_lat", 
        "to_lon", "trip", "to", "weight")
    segments[, `:=`(dist, haversine_distance(from_lat, from_lon, 
        to_lat, to_lon))][]
    V <- unique(points[, c("id", "lat", "lon")], by = "id")
    E <- segments[, c("from", "to", "weight", "dist")]
    G <- simplify(graph_from_data_frame(E, vertices = V, directed = TRUE), 
        remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb = list(weight = "sum", 
            dist = "first", "ignore"))
    if (!reduce) 
        return(G)
    else return(compress_chains(G))
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
