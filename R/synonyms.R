#' Retrieve synonyms from various sources given input taxonomic
#' names or identifiers
#'
#' @param x Vector of taxa names (character) or IDs (character or numeric) to
#' query.
#' @param db character; database to query. either \code{itis}, \code{tropicos},
#' \code{col}, \code{nbn}, or \code{worms}. Note that each taxonomic data
#' source has their own identifiers, so that if you provide the wrong
#' \code{db} value for the identifier you could get a result, but it will
#' likely be wrong (not what you were expecting). If using tropicos, we 
#' recommend getting an API key; see \code{\link{taxize-authentication}}
#' @param id character; identifiers, returned by \code{\link[taxize]{get_tsn}},
#' \code{\link[taxize]{get_tpsid}}, \code{\link[taxize]{get_nbnid}},
#' \code{\link[taxize]{get_colid}}, \code{\link[taxize]{get_wormsid}}
#' @param rows (numeric) Any number from 1 to infinity. If the default NA, all
#' rows are considered. Note that this parameter is ignored if you pass in a
#' taxonomic id of any of the acceptable classes: tsn, tpsid, nbnid, ids.
#' @param ... Other passed arguments to internal functions \code{get_*()} and
#' functions to gather synonyms.
#'
#' @return A named list of data.frames with the synonyms of every supplied taxa.
#' @details If IDs are supplied directly (not from the \code{get_*} functions)
#' you must specify the type of ID.
#'
#' For \code{db = "itis"} you can pass in a parameter \code{accepted} to
#' toggle whether only accepted names are used \code{accepted = TRUE}, or if
#' all are used \code{accepted = FALSE}. The default is \code{accepted = FALSE}
#'
#' Note that IUCN requires an API key. See
#' \code{\link[rredlist]{rredlist-package}} for help on authentiating with
#' IUCN Redlist
#'
#' @seealso \code{\link[taxize]{get_tsn}}, \code{\link[taxize]{get_tpsid}},
#' \code{\link[taxize]{get_nbnid}}, \code{\link[taxize]{get_colid}},
#' \code{\link[taxize]{get_wormsid}}, \code{\link[taxize]{get_iucn}}
#'
#' @export
#' @examples \dontrun{
#' # Plug in taxon IDs
#' synonyms(183327, db="itis")
#' synonyms("25509881", db="tropicos")
#' synonyms("NBNSYS0000004629", db='nbn')
#' # synonyms("87e986b0873f648711900866fa8abde7", db='col') # FIXME
#' synonyms(105706, db='worms')
#' synonyms(12392, db='iucn')
#'
#' # Plug in taxon names directly
#' synonyms("Pinus contorta", db="itis")
#' synonyms("Puma concolor", db="itis")
#' synonyms(c("Poa annua",'Pinus contorta','Puma concolor'), db="itis")
#' synonyms("Poa annua", db="tropicos")
#' synonyms("Pinus contorta", db="tropicos")
#' synonyms(c("Poa annua",'Pinus contorta'), db="tropicos")
#' synonyms("Pinus sylvestris", db='nbn')
#' synonyms("Puma concolor", db='col')
#' synonyms("Ursus americanus", db='col')
#' synonyms("Amblyomma rotundatum", db='col')
#' synonyms('Pomatomus', db='worms')
#' synonyms('Pomatomus saltatrix', db='worms')
#'
#' # not accepted names, with ITIS
#' ## looks for whether the name given is an accepted name,
#' ## and if not, uses the accepted name to look for synonyms
#' synonyms("Acer drummondii", db="itis")
#' synonyms("Spinus pinus", db="itis")
#'
#' # Use get_* methods
#' synonyms(get_tsn("Poa annua"))
#' synonyms(get_tpsid("Poa annua"))
#' synonyms(get_nbnid("Carcharodon carcharias"))
#' synonyms(get_colid("Ornithodoros lagophilus"))
#' synonyms(get_iucn('Loxodonta africana'))
#'
#' # Pass many ids from class "ids"
#' out <- get_ids(names="Poa annua", db = c('itis','tropicos'))
#' synonyms(out)
#'
#' # Use the rows parameter to select certain rows
#' synonyms("Poa annua", db='tropicos', rows=1)
#' synonyms("Poa annua", db='tropicos', rows=1:3)
#' synonyms("Pinus sylvestris", db='nbn', rows=1:3)
#' synonyms("Amblyomma rotundatum", db='col', rows=2)
#' synonyms("Amblyomma rotundatum", db='col', rows=2:3)
#'
#' # Use curl options
#' synonyms("Poa annua", db='tropicos', rows=1, verbose = TRUE)
#' synonyms("Poa annua", db='itis', rows=1, verbose = TRUE)
#' synonyms("Poa annua", db='col', rows=1, verbose = TRUE)
#'
#'
#' # combine many outputs together
#' x <- synonyms(c("Osmia bicornis", "Osmia rufa", "Osmia"), db = "itis")
#' synonyms_df(x)
#'
#' ## note here how Pinus contorta is dropped due to no synonyms found
#' x <- synonyms(c("Poa annua",'Pinus contorta','Puma concolor'), db="col")
#' synonyms_df(x)
#'
#' ## note here that ids are taxon identifiers b/c you start with them
#' x <- synonyms(c(25509881, 13100094), db="tropicos")
#' synonyms_df(x)
#'
#' ## NBN
#' x <- synonyms(c('Aglais io', 'Usnea hirta', 'Arctostaphylos uva-ursi'),
#'   db="nbn")
#' synonyms_df(x)
#' }

synonyms <- function(...) {
  UseMethod("synonyms")
}

#' @export
#' @rdname synonyms
synonyms.default <- function(x, db = NULL, rows = NA, ...) {
  nstop(db)
  switch(
    db,
    itis = {
      id <- process_syn_ids(x, db, get_tsn, rows = rows, ...)
      structure(stats::setNames(synonyms(id, ...), x),
                class = "synonyms", db = "itis")
    },
    tropicos = {
      id <- process_syn_ids(x, db, get_tpsid, rows = rows, ...)
      structure(stats::setNames(synonyms(id, ...), x),
                class = "synonyms", db = "tropicos")
    },
    nbn = {
      id <- process_syn_ids(x, db, get_nbnid, rows = rows, ...)
      structure(stats::setNames(synonyms(id, ...), x),
                class = "synonyms", db = "nbn")
    },
    col = {
      id <- process_syn_ids(x, db, get_colid, rows = rows, ...)
      structure(stats::setNames(synonyms(id, ...), x),
                class = "synonyms", db = "col")
    },
    worms = {
      id <- process_syn_ids(x, db, get_wormsid, rows = rows, ...)
      structure(stats::setNames(synonyms(id, ...), x),
                class = "synonyms", db = "worms")
    },
    iucn = {
      id <- process_syn_ids(x, db, get_iucn, ...)
      structure(stats::setNames(synonyms(id, ...), x),
                class = "synonyms", db = "iucn")
    },
    stop("the provided db value was not recognised", call. = FALSE)
  )
}

process_syn_ids <- function(input, db, fxn, ...){
  g <- tryCatch(as.numeric(as.character(input)), warning = function(e) e)
  if (
    inherits(g,"numeric") || is.character(input) && grepl("N[HB]", input) ||
      is.character(input) && grepl("[[:digit:]]", input)
  ) {
    as_fxn <- switch(db,
                     itis = as.tsn,
                     tropicos = as.tpsid,
                     nbn = as.nbnid,
                     col = as.colid,
                     worms = as.wormsid,
                     iucn = as.iucn)
    if (db == "iucn") return(as_fxn(input, check = TRUE))
    return(as_fxn(input, check = FALSE))
  } else {
    eval(fxn)(input, ...)
  }
}

#' @export
#' @rdname synonyms
synonyms.tsn <- function(id, ...) {
  fun <- function(x){
    if (is.na(x)) { NA } else {
      is_acc <- rit_acc_name(x, ...)
      if (all(!is.na(is_acc$acceptedName))) {
        accdf <- stats::setNames(
          data.frame(x[1], is_acc, stringsAsFactors = FALSE),
          c("sub_tsn", "acc_name", "acc_tsn", "acc_author")
        )
        x <- is_acc$acceptedTsn
        message("Accepted name(s) is/are '",
                paste0(is_acc$acceptedName, collapse = "/"), "'")
        message("Using tsn(s) ", paste0(is_acc$acceptedTsn, collapse = "/"),
                "\n")
      } else {
        accdf <- data.frame(sub_tsn = x[1], acc_tsn = x[1],
                            stringsAsFactors = FALSE)
      }

      res <- Map(function(z, w) {
        tmp <- ritis::synonym_names(z)
        if (NROW(tmp) == 0) {
          tmp <- data.frame(syn_name = "nomatch", syn_tsn = x[1],
                            stringsAsFactors = FALSE)
        } else {
          tmp <- stats::setNames(tmp, c('syn_author', 'syn_name', 'syn_tsn'))
        }
        if (as.character(tmp[1,1]) == 'nomatch') {
          tmp <- data.frame(message = "no syns found", stringsAsFactors = FALSE)
        }

        cbind(w, tmp, row.names = NULL)
      }, x, split(accdf, seq_len(NROW(accdf))))
      do.call("rbind", unname(res))
    }
  }
  stats::setNames(lapply(id, fun), id)
}

rit_acc_name <- function(x, ...) {
  tmp <- ritis::accepted_names(x, ...)
  if (NROW(tmp) == 0) {
    data.frame(submittedtsn = x[1], acceptedName = NA, acceptedTsn = x[1],
               stringsAsFactors = FALSE)
  } else {
    tmp
  }
}

#' @export
#' @rdname synonyms
synonyms.colid <- function(id, ...) {
  fun <- function(x) {
    if (is.na(x)) {
      NA
    } else {
      col_synonyms(x, ...)
    }
  }
  stats::setNames(lapply(id, fun), id)
}

col_synonyms <- function(x, ...) {
  base <- "http://www.catalogueoflife.org/col/webservice"
  args <- list(id = x[1], response = "full", format = "json")
  cli <- crul::HttpClient$new(base)
  res <- cli$get(query = args)
  res$raise_for_status()
  out <- jsonlite::fromJSON(res$parse("UTF-8"), FALSE)
  tmp <- out$results[[1]]
  if ("synonyms" %in% names(tmp)) {
    df <- taxize_ldfast(lapply(tmp$synonyms, function(w) {
      w[sapply(w, length) == 0] <- NA
      w$references <- NULL
      data.frame(w, stringsAsFactors = FALSE)
    }))
    df$rank <- tolower(df$rank)

    df
  } else {
    NULL
  }
}

#' @export
#' @rdname synonyms
synonyms.tpsid <- function(id, ...) {
  fun <- function(x) {
    if (is.na(x)) {
      NA
    } else {
      tp_synonyms(x, ...)$synonyms
    }
  }
  stats::setNames(lapply(id, fun), id)
}

#' @export
#' @rdname synonyms
synonyms.nbnid <- function(id, ...) {
  fun <- function(x){
    if (is.na(x)) {
      NA
    } else {
      nbn_synonyms(x, ...)
    }
  }
  stats::setNames(lapply(id, fun), id)
}

#' @export
#' @rdname synonyms
synonyms.wormsid <- function(id, ...) {
  fun <- function(x) {
    if (is.na(x)) {
      NA
    } else {
      worrms::wm_synonyms(as.numeric(x), ...)
    }
  }
  stats::setNames(lapply(id, fun), id)
}

#' @export
#' @rdname synonyms
synonyms.iucn <- function(id, ...) {
  out <- vector(mode = "list", length = length(id))
  for (i in seq_along(id)) {
    if (is.na(id[[i]])) {
      out[[i]] <- NA
    } else {
      out[[i]] <- rredlist::rl_synonyms(attr(id, "name")[i], ...)$result
    }
  }
  stats::setNames(out, id)
}






#' @export
#' @rdname synonyms
synonyms.ids <- function(id, ...) {
  fun <- function(x){
    if (is.na(x)) {
      out <- NA
    } else {
      out <- synonyms(x, ...)
    }
    return( out )
  }
  lapply(id, fun)
}

### Combine synonyms output into single data.frame -----------
#' @export
#' @rdname synonyms
synonyms_df <- function(x) {
  UseMethod("synonyms_df")
}

#' @export
synonyms_df.default <- function(x) {
  stop("no 'synonyms_df' method for ", class(x), call. = FALSE)
}

#' @export
synonyms_df.synonyms <- function(x) {
  x <- Filter(function(z) inherits(z[1], "data.frame"), x)
  (data.table::setDF(
    data.table::rbindlist(x, use.names = TRUE, fill = TRUE, idcol = TRUE)
  ))
}
