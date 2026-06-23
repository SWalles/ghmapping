\name{ghmapping-package}
\alias{ghmapping-package}
\docType{package}
\title{
\packageTitle{ghmapping}
}
\description{
\packageDescription{ghmapping}
}
\details{
Welcome to the ghmapping package!

This package was developed as part of my Master's degree at the University of Auckland. It is designed to extend Simon Urabnek's \href{https://rforge.net/ghroute/}{ghroute} package by offering higher level functions that can be used to aggregate many routes calculated by the 'ghroute::route' function as well as supporting a simple traffic simulation based on New Zealand Census data.

Main functions:
\describe{
  \item{\code{\link{load_JTW}}}{Load Journey-to-Work Census Data}
  \item{\code{\link{load_meshblocks}}}{Load meshblock data from .shp file}
  \item{\code{\link{setup_simulation}}}{Organise data into routes to calculate}
  \item{\code{\link{ghmapping}}}{Maps routes and aggregates weights into a graph}
  \item{\code{\link{join_graphs_on_coordinates}}}{Join multiple traffic graphs into one}
}

Other useful functions:
\describe{
  \item{\code{\link{aggregate_routes}}}{Aggregates routes from a matrix}
  \item{\code{\link{compress_chains}}}{Eliminates chains from a graph}
  \item{\code{\link{copy_template}}}{Takes one arguent called 'path' and copies a template file to given path. Defaults to current working directory.}
}

}
\author{
\packageAuthor{ghmapping}

Maintainer: \packageMaintainer{ghmapping}
}
\references{
This package's functionality depends on some outside resources that can be aquired by following these links:
\itemize{
  \item \href{https://rforge.net/ghroute/}{ghroute} package - Required as a package dependancy for functions in this package.
  \item \href{https://rforge.net/snippets/}{snippets} package - Required for the plotting method in the template code.
  \item \href{https://datafinder.stats.govt.nz/table/121988-2023-census-main-means-of-travel-to-work-by-statistical-area-2/}{Journey-to-Work} data from Stats NZ.
  \item \href{https://datafinder.stats.govt.nz/layer/121975-2023-census-electoral-population-at-meshblock-level-2025-meshblock/}{Mesh block} level population data from Stats NZ.
  \item \href{https://datafinder.stats.govt.nz/table/120975-geographic-areas-table-2025/}{Geographic Areas} description table from Stats NZ.
  \item \href{https://download.geofabrik.de/australia-oceania/new-zealand.html}{Open Street Map} data for New Zealand.
}
 
}
\keyword{package}

%% Uncomment below to imitate parts of library(help = ghmapping)
%\section{The \file{DESCRIPTION} File}{\packageDESCRIPTION{ghmapping}}
%\section{Documentation Index}{\packageIndices{ghmapping}}
