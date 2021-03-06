#' @title Details on \code{get_*()} functions
#' @description Including outputs from \code{get_*()} functions, as well as
#' their attributes, and all exception behaviors.
#'
#' @name get_id_details
#'
#' @details This document applies to the following functions:
#' \itemize{
#'  \item \code{\link{get_boldid}}
#'  \item \code{\link{get_colid}}
#'  \item \code{\link{get_eolid}}
#'  \item \code{\link{get_gbifid}}
#'  \item \code{\link{get_ids}}
#'  \item \code{\link{get_iucn}}
#'  \item \code{\link{get_natservid}}
#'  \item \code{\link{get_nbnid}}
#'  \item \code{\link{get_tolid}}
#'  \item \code{\link{get_tpsid}}
#'  \item \code{\link{get_tsn}}
#'  \item \code{\link{get_ubioid}}
#'  \item \code{\link{get_uid}}
#'  \item \code{\link{get_wiki}}
#'  \item \code{\link{get_wormsid}}
#' }
#'
#' @section attributes:
#' Each output from \code{get_*()} functions have the following attributes:
#'
#' \itemize{
#'  \item \emph{match} (character) - the reason for NA, either 'not found',
#'  'found' or if \code{ask = FALSE} then 'NA due to ask=FALSE')
#'  \item \emph{multiple_matches} (logical) - Whether multiple matches were
#'  returned by the data source. This can be \code{TRUE}, even if you get 1
#'  name back because we try to pattern match the name to see if there's any
#'  direct matches. So sometimes this attribute is \code{TRUE}, as well as
#'  \code{pattern_match}, which then returns 1 resulting name without user
#'  prompt.
#'  \item \emph{pattern_match} (logical) - Whether a pattern match was made.
#'  If \code{TRUE} then \code{multiple_matches} must be \code{TRUE}, and we
#'  found a perfect match to your name, ignoring case. If \code{FALSE},
#'  there wasn't a direct match, and likely you need to pick from many choices
#'  or further parameters can be used to limit results
#'  \item \emph{uri} (character) - The URI where more information can be
#'  read on the taxon - includes the taxonomic identifier in the URL somewhere.
#'  This may be missing if the value returned is \code{NA}
#' }
#'
#' @section exceptions:
#' The following are the various ways in which \code{get_*()} functions
#' behave:
#'
#' \itemize{
#'  \item success - the value returned is a character string or numeric
#'  \item no matches found - you'll get an NA, refine your search or
#'  possible the taxon searched for does not exist in the database you're
#'  using
#'  \item more than on match and ask = FALSE - if there's more than one
#'  matching result, and you have set \code{ask = FALSE}, then we can't
#'  determine the single match to return, so we give back \code{NA}.
#'  However, in this case we do set the \code{match} attribute to say
#'  \code{NA due to ask=FALSE & > 1 result} so it's very clear what
#'  happened - and you can even programatically check this as well
#'  \item NA due to some other reason - some \code{get_*()} functions
#'  have additional parameters for filtering taxa. It's possible that even
#'  though there's results (that is, \code{found} will say \code{TRUE}),
#'  you can get back an NA. This is most likely if the parameter filters
#'  taxa after they are returned from the data provider and the value passed
#'  to the parameter leads to no matches.
#' }
NULL
