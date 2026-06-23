\name{load_meshblocks}
\alias{load_meshblocks}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Load meshblock data from .shp file.
}
\description{
Function loads data from NZ-Stats meshblock population data and joins it with the geographic areas table to allow cross-referencing with SA2 area.
}
\usage{
load_meshblocks(mb_path, geo_areas_path, ..., redacted = function() { 0 })
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{mb_path}{
String that describes the file path to a meshblocks .shp file.
}
  \item{geo_areas_path}{
String that describes the path to a geographic areas .csv file.
}
  \item{\dots}{
Arguements for a dplyr filter function that can be used to restrict the data to certain areas accoring to the geographic areas data.
}
  \item{redacted}{
A function with no arguments that calculates a value to replace -999 redacted values in the dataset. Called for each row so can be something like function() {sample(1:6)}.
}
}

\value{
Returns a sf object with meshblock information, population counts, and corresponding area code information from the geographic areas data. Also contains the calculated fields:
\describe{
\item{general}{the general population counts with redacted values replaced}
\item{maori}{the Maori population counts with redated -999 values replaced}
\item{total}{total population count (general + maori)}
}

The resulting object can be passed to \code{\link{setup_simulation}} as the mb arguement.
}
\references{
Find the 2023 meshblock population data \href{https://datafinder.stats.govt.nz/layer/121975-2023-census-electoral-population-at-meshblock-level-2025-meshblock/}{HERE}!

Find the 2023 geographic areas table \href{https://datafinder.stats.govt.nz/table/111243-geographic-areas-table-2023/}{HERE}!

}

\examples{
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

## The function is currently defined as
function(mb_path, geo_areas_path, ... , redacted = function() {0}) {
  
  geo_areas <- read.csv(geo_areas_path, fileEncoding="UTF-8-BOM")
  mb <- st_read(mb_path)
  
  redact <- sapply(1:nrow(mb), function(x) {redacted()})
  
  mb <- mb |> 
    st_transform(crs = 4326) |> 
    mutate(MB2025_V1_ = as.integer(MB2025_V1_)) |> 
    left_join(geo_areas, by = join_by(MB2025_V1_ == MB2025_code)) |> 
    filter(...) |> 
    # Handle -999 values by substitution with 0 (might do something else)
    mutate(general = ifelse(General_El == -999, redact, General_El),
           maori = ifelse(Maori_Elec == -999, redact, Maori_Elec),
           total = general + maori)
  
  return(mb)
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
