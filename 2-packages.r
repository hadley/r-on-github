library(ggplot2)
library(plyr)
library(reshape2)
library(lubridate)
"%||%" <- function(a, b) if (length(a) == 0) b else a

# Load repo data
repos <- llply(dir("cache-repo", full.names = TRUE), readRDS)
names(repos) <- vapply(repos, function(x) x$info$full_name, character(1))

created <- vapply(repos, function(x) x$info$created_at, character(1), USE.NAMES = FALSE)
created <- as.Date(created)

# Focus on repos with valid DESCRIPTION - i.e. packages
has_desc <- vapply(repos, function(x) !is.null(x$desc) && is.list(x$desc), logical(1))

pkgs <- repos[has_desc]

# Look at all the titles
lapply(pkgs, function(x) x$desc$Title %||% "")

# Find which ones are on cran already
names <- unname(vapply(pkgs, function(x) x$desc$Package %||% "", character(1)))
available <- available.packages()
on_cran <- names %in% rownames(available)
sum(on_cran)

# Explore over time ---------------------------------------------------------

repo_df <- data.frame(
  name = names(repos), 
  created = created, 
  type = ifelse(has_desc, "pkg", "repo")
)
counts <- count(repo_df, c("type", "created"))
counts <- ddply(counts, "type", mutate, csum = cumsum(freq))
qplot(created, csum, data = counts, geom = "line", colour = type) + 
  labs(x = NULL, y = "Cumulative count")
ggsave("github-repos.pdf", width = 8, height = 6)
last_plot() + scale_y_log10()
ggsave("github-repos-log.pdf", width = 8, height = 6)


# Explore dependencies ---------------------------------------------------------

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

# Most common dependencies
head(arrange(count(unlist(deps)), desc(freq)), 20)

# Which use Rcpp
rcpp <- vapply(deps, function(x) "Rcpp" %in% x, logical(1))
names(pkgs)[rcpp]
