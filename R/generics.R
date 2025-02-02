#' @import methods

#' @title Make row and column layout summary data.frames for use during pagination
#' @name make_row_df
#'
#'
#' @param tt ANY. Object representing the table-like object to be summarized.
#' @param visible_only logical(1). Should only visible aspects of the table structure be reflected in this summary. Defaults to \code{TRUE}. May not be supported by all methods.
#' @param incontent logical(1). Internal detail do not set manually.
#' @param repr_ext integer(1). Internal detail do not set manually.
#' @param repr_inds integer. Internal detail do not set manually.
#' @param sibpos integer(1). Internal detail do not set manually.
#' @param nsibs integer(1). Internal detail do not set manually.
#' @param rownum numeric(1). Internal detail do not set manually.
#' @param indent integer(1). Internal detail do not set manually.

#' @param colwidths numeric. Internal detail do not set manually.
#' @param  path character.  Path  to  the (sub)table  represented  by
#'     \code{tt}. Defaults to \code{character()}
#'
#'  @details When  \code{visible_only} is  \code{TRUE} (the  default),
#'     methods should  return a  data.frame with  exactly one  row per
#'     visible  row in  the table-like  object.  This  is useful  when
#'     reasoning about  how a table  will print, but does  not reflect
#'     the full pathing space of the structure (though the paths which
#'     are given will all work as is).
#'
#' If  supported,  when  \code{visible_only}  is  \code{FALSE},  every
#' structural element of the table (in row-space) will be reflected in
#' the  returned data.frame,  meaning the  full pathing-space  will be
#' represented but some rows in  the layout summary will not represent
#' printed rows in the table as it is displayed.
#'
#' Most arguments beyond \code{tt} and \code{visible_only} are present so that
#' `make_row_df` methods can call `make_row_df` recursively and retain information,
#' and should not be set during a top-level call
#'
#' @note the technically present root tree node is excluded from the summary returne dby
#' both \code{make_row_df} and \code{make_col_df}, as it is simply the
#' row/column structure of \code{tt} and thus not useful for pathing or pagination.
#' @export
#' @return a data.frame of row/column-structure information used by the pagination machinery.
#' @rdname make_row_df
#'
## nocov start
setGeneric("make_row_df", function(tt, colwidths = NULL, visible_only = TRUE,
                                  rownum = 0,
                                  indent = 0L,
                                  path = character(),
                                  incontent = FALSE,
                                  repr_ext = 0L,
                                  repr_inds = integer(),
                                  sibpos = NA_integer_,
                                  nsibs = NA_integer_) standardGeneric("make_row_df"))
## nocov end


#' Transform rtable to a list of matrices which can be used for outputting
#'
#' Although rtables are represented as a tree data structure when outputting the table to ASCII or HTML it is useful to
#' map the rtable to an in between state with the formatted cells in a matrix form.
#'
#' @param obj ANY. Object to be transformed into a ready-to-render form (a MatrixPrintForm object)
#' @param indent_rownames logical(1), if TRUE the column with the row names in the `strings` matrix of has indented row
#'   names (strings pre-fixed)
#'
#' @export
#'
#' @details
#'
#' The strings in the return object are defined as follows: row labels are those determined by \code{summarize_rows} and cell values are determined using \code{get_formatted_cells}. (Column labels are calculated using a non-exported internal funciton.
#'
#'@return A `MatrixPrintForm` classed list with the following elements:
#' \describe{
#' \item{strings}{The content, as it should be printed, of the top-left material, column headers, row labels , and cell values of \code{tt}}
#' \item{spans}{The column-span information for each print-string in the strings matrix}
#' \item{aligns}{The text alignment for each print-string in the strings matrix}
#' \item{display}{Whether each print-string in the strings matrix should be printed or not}.
#' \item{row_info}{the data.frame generated by \code{summarize_rows(tt)}}
#' }
#'
#' With an additional \code{nrow_header} attribute indicating the number of pseudo "rows"  the
#' column structure defines.
setGeneric("matrix_form", function(obj, indent_rownames = FALSE) standardGeneric("matrix_form"))

#' @rdname matrix_form
#' @export
setMethod("matrix_form", "MatrixPrintForm", function(obj, indent_rownames = FALSE) obj)


## Generics for toString and helper functions


## this is where we will take wordwrapping
## into account when it is added
##
## ALL calculations of vertical space for pagination
## purposes must go through nlines and divider_height!!!!!!!!

## this will be customizable someday. I have foreseen it (spooky noises)
#' Divider Height
#'
#' @param obj ANY. Object.
#' @return The height, in lines of text, of the divider between
#' header and body. Currently returns \code{1L} for the default method.
#' @export
#' @examples
#' divider_height(mtcars)
setGeneric("divider_height", function(obj) standardGeneric("divider_height"))

#' @rdname divider_height
#' @export
setMethod("divider_height", "ANY",
          function(obj) 1L)

#' Number of lines required to print a value
#' @param x ANY. The object to be printed
#' @param colwidths numeric. Column widths (if necessary)
#' @return A scalar numeric indicating the number of lines needed
#' to render the object \code{x}.
#' @export
setGeneric("nlines",
           function(x, colwidths) standardGeneric("nlines"))

## XXX beware. I think it is dangerous
#' @export
#' @rdname nlines
setMethod("nlines", "list",
          function(x, colwidths) {
    if(length(x) == 0)
        0L
    else
        sum(unlist(vapply(x, nlines, NA_integer_, colwidths = colwidths)))
})

#' @export
#' @rdname nlines
setMethod("nlines", "NULL", function(x, colwidths) 0L)

#' @export
#' @rdname nlines
setMethod("nlines", "character", function(x, colwidths) max(vapply(strsplit(x, "\n", fixed = TRUE), length, 1L)))




#' @title toString
#'
#' Transform a complex object into a string representation ready
#' to be printed or written to a plain-text file
#'
#' @param x ANY. Object to be prepared for rendering.
#' @param ... Passed to individual methods.
#' @rdname tostring
#' @export
setGeneric("toString", function(x,...) standardGeneric("toString"))

## preserve S3 behavior
setMethod("toString", "ANY", base::toString) ## nocov

#' @title Print
#'
#' Print an R object. see \code{[base::print()]}
#' @inheritParams base::print
#' @rdname basemethods
setMethod("print", "ANY", base::print) ## nocov










## General/"universal" property getter and setter generics and stubs

#' @title Label, Name and Format accessor generics
#'
#' Getters and setters for basic, relatively universal attributes
#' of "table-like" objects"
#' @name lab_name
#' @param obj ANY. The object.
#' @param value character(1)/FormatSpec. The new value of the attribute.
#' @return the name, format or label of \code{obj} for getters, or \code{obj} after modification
#' for setters.
#' @aliases obj_name
#' @export
setGeneric("obj_name", function(obj) standardGeneric("obj_name"))


#' @rdname lab_name
#' @export
setGeneric("obj_name<-", function(obj, value) standardGeneric("obj_name<-"))


#' @seealso with_label
#' @rdname lab_name
#' @export
setGeneric("obj_label", function(obj) standardGeneric("obj_label"))

#' @rdname lab_name
#' @param value character(1). The new label
#' @export
setGeneric("obj_label<-", function(obj, value) standardGeneric("obj_label<-"))

#' @rdname lab_name
#' @exportMethod obj_label
setMethod("obj_label", "ANY", function(obj) attr(obj, "label"))

#' @rdname lab_name
#' @exportMethod obj_label<-
setMethod("obj_label<-", "ANY",
          function(obj, value){
    attr(obj, "label") = value
    obj
})

#' @rdname lab_name
#' @export
setGeneric("obj_format", function(obj) standardGeneric("obj_format"))
## this covers rcell, etc
#' @rdname lab_name
#' @exportMethod obj_format
setMethod("obj_format", "ANY", function(obj) attr(obj, "format"))


#' @export
#' @rdname lab_name
setGeneric("obj_format<-", function(obj, value) standardGeneric("obj_format<-"))
## this covers rcell, etc
#' @exportMethod obj_format<-
#' @rdname lab_name
setMethod("obj_format<-", "ANY", function(obj, value) {
    attr(obj, "format") = value
    obj
})



#' General title/footer accessors
#'
#' @param obj ANY. Object to extract information from.
#' @export
#' @rdname title_footer
#' @return a character scalar (`main_title`, `main_footer`), or
#' vector of length zero or more (`subtitles`, `page_titles`,
#' `prov_footer`) containing the relevant title/footer contents
setGeneric("main_title", function(obj) standardGeneric("main_title"))

#' @export
#' @rdname title_footer
setMethod("main_title", "MatrixPrintForm",
          function(obj) obj$main_title)

##' @rdname title_footer
##' @export
setGeneric("main_title<-", function(obj, value) standardGeneric("main_title<-"))


#' @export
#' @rdname title_footer
setGeneric("subtitles", function(obj) standardGeneric("subtitles")) ## nocov

#' @export
#' @rdname title_footer
setMethod("subtitles", "MatrixPrintForm",
          function(obj) obj$subtitles)

##' @rdname title_footer
##' @export
setGeneric("subtitles<-", function(obj, value) standardGeneric("subtitles<-")) ## nocov

#' @export
#' @rdname title_footer
setGeneric("page_titles", function(obj) standardGeneric("page_titles"))

#' @export
#' @rdname title_footer
setMethod("page_titles", "MatrixPrintForm",
          function(obj) obj$page_titles)
#' @rdname title_footer
#' @export
setMethod("page_titles", "ANY", function(obj) NULL)

##' @rdname title_footer
##' @export
setGeneric("page_titles<-", function(obj, value) standardGeneric("page_titles<-"))

#' @export
#' @rdname title_footer
setMethod("page_titles<-", "MatrixPrintForm",
          function(obj, value) {
    if(!is.character(value))
        stop("page titles must be in the form of a character vector, got object of class ", class(value))
    obj$page_titles <- value
    obj
})



#' @export
#' @rdname title_footer
setGeneric("main_footer", function(obj) standardGeneric("main_footer"))

#' @export
#' @rdname title_footer
setMethod("main_footer", "MatrixPrintForm",
          function(obj) obj$main_footer)

#' @rdname title_footer
#' @param value character. New value.
#' @export
setGeneric("main_footer<-", function(obj, value) standardGeneric("main_footer<-"))



#' @export
#' @rdname title_footer
setMethod("main_footer<-", "MatrixPrintForm",
          function(obj, value) {
    if(!is.character(value))
        stop("main footer must be a character vector. Got object of class ", class(value))
    obj$main_footer <- value
    obj
})


#' @export
#' @rdname title_footer
setGeneric("prov_footer", function(obj) standardGeneric("prov_footer"))

#' @export
#' @rdname title_footer
setMethod("prov_footer", "MatrixPrintForm",
          function(obj) obj$prov_footer)

#' @rdname title_footer
#' @export
setGeneric("prov_footer<-", function(obj, value) standardGeneric("prov_footer<-"))

#' @export
#' @rdname title_footer
setMethod("prov_footer<-", "MatrixPrintForm",
          function(obj, value) {
    if(!is.character(value))
        stop("provenance footer must be a character vector. Got object of class ", class(value))
    obj$prov_footer <- value
    obj
})




#' @rdname title_footer
#' @export
all_footers <- function(obj) c(main_footer(obj), prov_footer(obj))

#' @rdname title_footer
#' @export
all_titles <- function(obj) c(main_title(obj), subtitles(obj), page_titles(obj))
