\name{setup_simulation}
\alias{setup_simulation}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Organise data into routes to calculate
}
\description{
Combines meshblock, Journey-to-Work, and geographic areas table data into a data frame with everything neccesary to run a simulation.
}
\usage{
setup_simulation(jtw, mb, min_pop = 0.01, min_weight = 0.01)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{jtw}{
A data frame as produced by \code{\link{load_JTW}}.
}
  \item{mb}{
A sf object as produced by \code{\link{load_meshblocks}}.
}
  \item{min_pop}{
Minimum population count for meshblocks to consider. Removes any meshblocks with lower population.
}
  \item{min_weight}{
Minimum final weight to include. Removes rows with lower weight values.
}
}
\value{
Returns a data frame with the coordinates needed for the routing step in the simulation. Also has a weight field that is calculated by distributing the number of journeys from a statistical area to the meshblocks that make it up, proportionally  to the meshblock populations. The data frame also contains the original SA2 area code, trip count and meshblock populations to allow the user to calculate their own weights if required.
}

\examples{
## jtw <- load_JTW(jtw_path = "journey-to-work.csv", 
##                  redacted = function() {sample(1:6)},
##                  min_trips = 10)

## mb <- load_meshblocks(
##  mb_path = "meshblocks.shp",
##  geo_areas_path = "geo_areas.csv",
##  WARD2025_name %in% c(
##          "Waitematā and Gulf Ward"#, 
##          "Albert-Eden-Puketāpapa Ward", 
##          "Ōrākei Ward", 
##          "Maungakiekie-Tāmaki Ward"
##          ),
##  redacted = function() {sample(1:6)}
##)

## simdata <- setup_simulation(jtw, mb, min_pop = 10, min_weight = 5)

## The function is currently defined as
function (jtw, mb, min_pop = 0.01, min_weight = 0.01) 
{
    mb_coords <- ungroup(mutate(group_by(filter(select(st_drop_geometry(mutate(mb, 
        centroids = st_centroid(geometry), s.lon = st_coordinates(centroids)[, 
            1], s.lat = st_coordinates(centroids)[, 2])), MB2025_V1_, 
        SA22023_code, general, maori, total, s.lon, s.lat), total >= 
        min_pop), SA22023_code), SA2_total = sum(total)))
    wp_coords <- select(st_drop_geometry(mutate(summarise(group_by(mb, 
        SA22023_code), geometry = st_union(geometry)), centroids = st_centroid(geometry), 
        d.lon = st_coordinates(centroids)[, 1], d.lat = st_coordinates(centroids)[, 
            2])), SA22023_code, d.lon, d.lat)
    simdata <- filter(ungroup(mutate(group_by(left_join(left_join(jtw, 
        mb_coords, by = join_by(s.SA2 == SA22023_code), relationship = "many-to-many"), 
        wp_coords, by = join_by(d.SA2 == SA22023_code)), s.SA2), 
        weight = round(total_trips * (total/SA2_total)))), weight >= 
        min_weight)
    simdata
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
