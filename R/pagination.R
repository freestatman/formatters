#' Create row of pagination data frame
#' @param nm character(1). Name
#' @param lab character(1). Label
#' @param rnum numeric(1). Absolute rownumber
#' @param pth character or NULL. Path within larger table
#' @param sibpos integer(1). Position amongst sibling rows
#' @param nsibs integer(1). Number of siblings
#' @param extent numberic(1). Number of lines required to print the row
#' @param colwidths numeric. Column widths
#' @param repext integer(1). Number of lines required to reprint all context for this row if it appears directly after pagination.
#' @param repind integer. Vector of row numbers to be reprinted if this row appears directly after pagination.
#' @param indent integer. Indent
#' @param rclass character(1). Class of row object.
#' @param nrowrefs integer(1). Number of row referential footnotes for this row
#' @param ncellrefs integer(1). Number of cell referential footnotes for the cells in this row
#' @param nreflines integer(1). Total number of lines required by all referential footnotes
#' @param force_page logical(1). Currently Ignored.
#' @param page_title logical(1). Currently Ignored.
#' @param row ANY. Object representing the row, which is used for default values of \code{nm}, \code{lab},
#' \code{extent} and \code{rclass} if provided. Must have methods for \code{obj_name}, \code{obj_label},
#' and \code{nlines}, respectively, for default values of \code{nm}, \code{lab} and \code{extent} to
#' be retrieved, respectively.
#'
#' @return a single row data.frame with the columns appropriate for a pagination info data frame.
#' @export
pagdfrow = function(row,
                    nm = obj_name(row),
                    lab = obj_label(row),
                    rnum,
                    pth ,
                    sibpos = NA_integer_,
                    nsibs = NA_integer_,
                    extent = nlines(row, colwidths),
                    colwidths = NULL,
                    repext = 0L,
                    repind = integer(),
                    indent = 0L,
                    rclass = class(row),
                    nrowrefs = 0L,
                    ncellrefs = 0L,
                    nreflines = 0L,
                    force_page = FALSE,
                    page_title = NA_character_
                    ) {
    data.frame(label = lab,
               name = nm,
               abs_rownumber = rnum,
               path = I(list(pth)),
               pos_in_siblings = sibpos,
               n_siblings = nsibs,
               self_extent = extent,
               par_extent = repext,
               reprint_inds = I(rep(list(unlist(repind)), length.out = length(nm))),
               node_class = rclass,
               indent = max(0L, indent),
               nrowrefs = nrowrefs,
               ncellrefs = ncellrefs,
               nreflines = nreflines,
               force_page = force_page,
               page_title = page_title,
               stringsAsFactors = FALSE,
               row.names = NULL)
}


valid_pag = function(pagdf,
                     guess,
                     start,
                     rlpp,
                     min_sibs,
                     nosplit = NULL,
                     verbose = FALSE) {
    rw <- pagdf[guess,]


    if(verbose)
        message("Checking pagination after row ", guess)
    rowlines <- sum(pagdf[start:guess, "self_extent"])
    reflines <-  sum(pagdf[start:guess, "nreflines"])
    rowlines <- sum(pagdf[start:guess, "self_extent"]) - reflines ## self extent includes reflines

    if(reflines > 0) reflines <- reflines + 2 ## divider plus empty line
    lines <- rowlines + reflines  # guess - start + 1 because inclusive of start
    if(rowlines > rlpp) {
        if(verbose)
            message("\t....................... FAIL: Rows take up too much space (", rowlines, " lines)")
        return(FALSE)
    }
    if(lines > rlpp) {
        if(verbose)
            message("\t....................... FAIL: Referential footnotes take up too much space (", reflines, " lines)")
        return(FALSE)
    }
    if(rw[["node_class"]] %in% c("LabelRow", "ContentRow")) {
        if(verbose)
            message("\t....................... FAIL: last row is a label or content row")
        return(FALSE)
    }

    sibpos <- rw[["pos_in_siblings"]]
    nsib <- rw[["n_siblings"]]
    okpos <- min(min_sibs + 1, rw[["n_siblings"]])
    if( sibpos != nsib){
        retfalse <- FALSE
        if(sibpos < min_sibs + 1) {
            retfalse <- TRUE
            if(verbose)
                message("\t....................... FAIL: last row had only ", sibpos - 1, " preceeding siblings, needed ", min_sibs)
        } else if (nsib - sibpos < min_sibs + 1) {
            retfalse <- TRUE
            if(verbose)
                message("\t....................... FAIL: last row had only ", nsib - sibpos - 1, " following siblings, needed ", min_sibs)
        }
        if(retfalse)
            return(FALSE)
    }
    if(guess < nrow(pagdf)) {
        curpth <- unlist(rw$path)
        nxtpth <- unlist(pagdf$path[[guess+1]])
        inplay <- nosplit[(nosplit %in% intersect(curpth, nxtpth))]
        if(length(inplay) > 0) {
            curvals <- curpth[match(inplay, curpth) + 1]
            nxtvals <- nxtpth[match(inplay, nxtpth) + 1]
            if(identical(curvals, nxtvals)) {
                if(verbose)
                    message("\t....................... FAIL: values of unsplitable vars before [", curvals, "] and after [", nxtvals, "] match")
                return(FALSE)
            }
        }
    }
    if(verbose)
        message("\t....................... OK")
    TRUE
}


find_pag = function(pagdf,
                    start,
                    guess,
                    rlpp,
                    min_siblings,
                    nosplitin = character(),
                    verbose = FALSE) {
    origuess = guess
    while(guess >= start && !valid_pag(pagdf, guess, start = start, rlpp  = rlpp, min_sibs = min_siblings, nosplit = nosplitin, verbose)) {
        guess = guess - 1
    }
    if(guess < start)
        stop("Unable to find any valid pagination between ", start, " and ", origuess)
    guess
}


#' Find Pagination Indices From Pagination Info Dataframe
#'
#' Pagination methods should typically call the `make_row_df` method
#' for their object and then call this function on the resulting
#' pagination info data.frame.
#'
#' @param pagdf data.frame. A pagination info data.frame as created by
#' either `make_rows_df` or `make_cols_df`.
#' @param rlpp numeric. Maximum number of \emph{row} lines per page (not including header materials), including (re)printed header and context rows
#' @param min_siblings  numeric. Minimum sibling rows which must appear on either side of pagination row for a
#'   mid-subtable split to be valid. Defaults to 2.
#' @param nosplitin character. List of names of sub-tables where page-breaks are not allowed, regardless of other
#'   considerations. Defaults to none.
#' @param verbose logical(1). Should additional informative messages about the search for
#' pagination breaks be shown. Defaults to \code{FALSE}.
#' @return A list containing the vector of row numbers, broken up by page
#'
#' @examples
#' mypgdf <- basic_pagdf(row.names(mtcars))
#'
#' paginds <- pag_indices_inner(mypgdf, rlpp = 15, min_siblings = 0)
#' lapply(paginds, function(x) mtcars[x,])
#'
#' @export
pag_indices_inner <- function(pagdf, rlpp,
                                 min_siblings,
                                 nosplitin = character(),
                                 verbose = FALSE) {

    start = 1
    nr = nrow(pagdf)
    ret = list()
    force_pags <- which(pagdf$force_pag)
    while(start <= nr) {
        adjrlpp = rlpp - pagdf$par_extent[start]
        stopifnot(adjrlpp > 0)
        guess = min(nr, start + adjrlpp - 1)
        end = find_pag(pagdf, start, guess,
                       rlpp = adjrlpp,
                       min_siblings = min_siblings,
                       nosplitin = nosplitin,
                       verbose = verbose)
        ret = c(ret, list(c(pagdf$reprint_inds[[start]],
                            start:end)))
        start = end + 1
    }
    ret
}

#' Find Column Indicies for Vertical Pagination
#' @param obj ANY. object to be paginated. Must have a \code{\link{matrix_form}} method.
#' @param cpp numeric(1). Number of columns per page
#' @inheritParams pag_indices_inner
#'
#' @return A list partitioning the vector of column indices
#' into subsets for 1 or more vertically paginated pages.
#'
#' @examples
#' mf <- basic_matrix_form(df = mtcars)
#' colpaginds <- vert_pag_indices(mf)
#' lapply(colpaginds, function(j) mtcars[,j, drop = FALSE])
#' @export
vert_pag_indices <- function(obj, cpp = 40, verbose = FALSE) {

    strm <- matrix_form(obj, TRUE)

    nhl <- attr(strm, "nlines_header")

    clwds <- propose_column_widths(strm)


    pdfrows <- lapply(2:ncol(strm),
                      function(i) {pagdfrow(row = NA,
                                            nm = i-1,
                                            lab = i-1,
                                            rnum = i-1,
                                            pth = NA,
                                            extent = clwds[i],
                                            rclass = "stuff",
                                            sibpos = 1-1,
                                            nsibs = 1-1)
    })

    pdf <- do.call(rbind, pdfrows)
    res <- pag_indices_inner(pdf, rlpp = cpp - clwds[1], verbose = verbose, min_siblings = 1)
    res
}


#' Basic/spoof pagination info dataframe
#'
#' Returns a minimal pagination info data.frame (with no sibling/footnote/etc info).
#'
#' @param rnames character. Vector of row names
#' @param labs character. Vector of row labels (defaults to names)
#' @param rnums integer. Vector of row numbers. Defaults to `seq_along(rnames)`.
#' @param extents integer. Number of lines each row will take to print,d efaults to 1 for all rows
#' @param rclass character. Class(es) for the rows. Defaults to "NA"
#'
#' @return A data.frame suitable for use in both the `matrix_print_form` constructor and the pagination machinery
#'
#' @examples
#'
#' basic_pagdf(c("hi", "there"))
#' @export
basic_pagdf <- function(rnames, labs = rnames, rnums = seq_along(rnames),
                        extents = 1L,
                        rclass = "NA") {

    rws <- mapply(pagdfrow, nm = rnames, lab = labs, extent = extents,
                  rclass = rclass, rnum = rnums, pth = rnames,
                  SIMPLIFY = FALSE, nsibs = 1, sibpos = 1)
    do.call(rbind.data.frame, rws)

}
