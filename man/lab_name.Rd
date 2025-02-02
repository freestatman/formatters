% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generics.R
\name{lab_name}
\alias{lab_name}
\alias{obj_name}
\alias{obj_name<-}
\alias{obj_label}
\alias{obj_label<-}
\alias{obj_label,ANY-method}
\alias{obj_label<-,ANY-method}
\alias{obj_format}
\alias{obj_format,ANY-method}
\alias{obj_format<-}
\alias{obj_format<-,ANY-method}
\title{Label, Name and Format accessor generics

Getters and setters for basic, relatively universal attributes
of "table-like" objects"}
\usage{
obj_name(obj)

obj_name(obj) <- value

obj_label(obj)

obj_label(obj) <- value

\S4method{obj_label}{ANY}(obj)

\S4method{obj_label}{ANY}(obj) <- value

obj_format(obj)

\S4method{obj_format}{ANY}(obj)

obj_format(obj) <- value

\S4method{obj_format}{ANY}(obj) <- value
}
\arguments{
\item{obj}{ANY. The object.}

\item{value}{character(1). The new label}
}
\value{
the name, format or label of \code{obj} for getters, or \code{obj} after modification
for setters.
}
\description{
Label, Name and Format accessor generics

Getters and setters for basic, relatively universal attributes
of "table-like" objects"
}
\seealso{
with_label
}
