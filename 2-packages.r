library(ggplot2)
library(plyr)
library(reshape2)

repos <- llply(dir("cache-repo", full.names = TRUE), readRDS)
names(repos) <- vapply(repos, function(x) x$info$full_name, character(1))

has_desc <- vapply(repos, function(x) !is.null(x$desc) && is.list(x$desc), logical(1))
pkgs <- repos[has_desc]

"%||%" <- function(a, b) if (length(a) == 0) b else a
lapply(pkgs, function(x) x$desc$Title %||% "")

names <- unname(vapply(pkgs, function(x) x$desc$Package %||% "", character(1)))
available <- available.packages()
on_cran <- names %in% rownames(available)
sum(on_cran)

deps <- lapply(pkgs, function(x) {
  deps <- NULL
  try({
    deps <- c(
      parse_deps(x$desc$Depends)$name, 
      parse_deps(x$desc$Imports)$name,
      parse_deps(x$desc$Linkingto)$name
    )
  })
})

head(arrange(count(unlist(deps)), desc(freq)), 20)

rcpp <- vapply(deps, function(x) "Rcpp" %in% x, logical(1))
names(pkgs)[rcpp]



lapply(pkgs, function(x) parse_deps(x$Imports))