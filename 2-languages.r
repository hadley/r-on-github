library(ggplot2)
library(plyr)
library(reshape2)

repos <- llply(dir("cache-repo", full.names = TRUE), readRDS)
names(repos) <- vapply(repos, function(x) x$info$full_name, character(1))

lang <- lapply(repos, function(x) x$lang)
lang_collapse <- function(x) {
  x <- unlist(x)
  data.frame(t(prop.table(x)), total = sum(x), check.names = FALSE)
}

langs <- ldply(lang, lang_collapse)

# Explore total repo size ------------------------------------------------------
qplot(total, data = langs, binwidth = 0.05) + scale_x_log10()

# Only look at repos with at least 5k of code
mean(langs$total > 5e3)
langs$.id[langs$total < 5e3][1:10]
langs <- subset(langs, total > 5e3)

qplot(total, data = langs, binwidth = 0.05) + scale_x_log10()

# Big repos: over a megabyte of R code
big <- subset(langs, langs$total * langs$R > 1e6)
big <- big[(vapply(big, function(x) !all(is.na(x)), logical(1)))]
big$.id

# Look at distribution of other languages --------------------------------------

qplot(R, data = langs, binwidth = 0.01)
mean(langs$R == 1)
# ~70% are only R

langm <- melt(langs, id = c(".id", "total", "R"), na.rm = TRUE)
other_lang <- count(langm, "variable")
pop_lang <- match_df(langm, subset(other_lang, freq >= 20))

qplot(value, data = pop_lang, binwidth = 0.05) + facet_wrap(~ variable)
qplot(value, ..density.., data = pop_lang, binwidth = 0.05, geom = "histogram") + 
  facet_wrap(~ variable)
