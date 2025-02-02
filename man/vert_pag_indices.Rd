% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pagination.R
\name{vert_pag_indices}
\alias{vert_pag_indices}
\title{Find Column Indicies for Vertical Pagination}
\usage{
vert_pag_indices(obj, cpp = 40, verbose = FALSE)
}
\arguments{
\item{obj}{ANY. object to be paginated. Must have a \code{\link{matrix_form}} method.}

\item{cpp}{numeric(1). Number of columns per page}

\item{verbose}{logical(1). Should additional informative messages about the search for
pagination breaks be shown. Defaults to \code{FALSE}.}
}
\value{
A list partitioning the vector of column indices
into subsets for 1 or more vertically paginated pages.
}
\description{
Find Column Indicies for Vertical Pagination
}
\examples{
mf <- basic_matrix_form(df = mtcars)
colpaginds <- vert_pag_indices(mf)
lapply(colpaginds, function(j) mtcars[,j, drop = FALSE])
}
