source("requests.r")

repos <- sort(unique(readRDS("repos.rds")))

repo_info <- function(repo) {
  cache_path <- paste0("cache-repo/", gsub("/", "-", repo), ".rds")
  if (file.exists(cache_path)) return(readRDS(cache_path))
  
  message("Fetching repo info for ", repo)
  
  Sys.sleep(0.72)
  info <- github_get(paste0(base, "/repos/", repo))
  
  Sys.sleep(0.72)
  lng <- github_get(paste0(base, "/repos/", repo, "/languages"))
  
  Sys.sleep(0.72)
  dir <- github_get(paste0(base, "/repos/", repo, "/contents/"))
  paths <- vapply(dir, function(x) x$path, character(1))
  
  if ("DESCRIPTION" %in% paths) {
    Sys.sleep(0.72)
    desc_raw <- github_get(paste0(base, "/repos/", repo, "/contents/DESCRIPTION"))
    desc_string <- rawToChar(base64enc::base64decode(desc_raw$content))
  
    desc <- "Failed to parse"
    try(desc <- as.list(as.data.frame(read.dcf(textConnection(desc_string)), 
      stringsAsFactors = FALSE)))
  } else {
    desc <- NULL
  }
  
  Sys.sleep(0.72)
  tag <- github_get(paste0(base, "/repos/", repo, "/tags"))
  tag_names <- vapply(tag, function(x) x$name, character(1))
  
  out <- list(info = info, languages = lng, dir = paths, desc = desc, tags = tag_names)
  saveRDS(out, cache_path)
  out
}

info <- lapply(repos, function(x) try(repo_info(x)))