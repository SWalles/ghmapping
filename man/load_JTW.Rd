\name{load_JTW}
\alias{load_JTW}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Load Journey-to-Work Census Data
}
\description{
Loads New Zealand Census Journey-to-Work (or equivalant) data from a csv file. It renames data fields, handles redacted counts, and filters for a minimum number of trips if required. Returns an object that can be directly passed to \code{\link{setup_simulation}}.
}
\usage{
load_JTW(jtw_path, redacted = function() { 0 }, min_trips = 0.01)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{jtw_path}{
A single string value with the path to the Journey-to-Work csv file.
}
  \item{redacted}{
A function with no arguments that calculates a value to replace -999 redacted values in the dataset. Called for each row so can be something like function() {sample(1:6)}.
}
  \item{min_trips}{
Filter trips by providing a numerical value st. all rows with less than min_trips trips will be removed.
}
}

\value{
Returns a data frame that can be passed to \code{\link{setup_simulation}} as its `jtw` arguement. Has the following columns:
  \itemize{
  \item{s.SA2}{: origin statistical area}
  \item{d.SA2}{: destination statistical area}
  \item{private}{: number of trips using using private vehicles}
  \item{work}{: number of trips made using work vechiles}
  \item{total_trips}{: total number of trips made with non-public transport motor vehicles (private + work) }
  }
}
\references{
Find the 2023 Journey-to-Work data \href{https://datafinder.stats.govt.nz/table/121988-2023-census-main-means-of-travel-to-work-by-statistical-area-2/}{HERE}!  
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\examples{
## jtw <- load_JTW(jtw_path = "journey-to-work.csv", 
##                  redacted = function() {sample(1:6)},
##                  min_trips = 10)

## The function is currently defined as
function (jtw_path, redacted = function() { 0 }, min_trips = 0.01) 
{
  jtw <- read.csv(jtw_path, fileEncoding="UTF-8-BOM")
  
  redact <- sapply(1:nrow(jtw), function(x) {redacted()})
  
  jtw  |> 
    rename(s.SA2 = SA22023_V1_00_usual_residence_address,
           d.SA2 = SA22023_V1_00_workplace_address,
           private = X2023_Drive_a_private_car_truck_or_van,
           work = X2023_Drive_a_company_car_truck_or_van) |>
    mutate(private = ifelse(private == -999, redact, private),
           work = ifelse(work == -999, redact, work),
           total_trips = private + work) |>
    select(s.SA2, d.SA2, private, work, total_trips) |>
    filter(total_trips >= min_trips)
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
