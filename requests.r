library(httr)

user <- Sys.getenv("GITHUB_USER")
pwd <- Sys.getenv("GITHUB_PASS")
if (user == "" || pwd == "") {
  stop("Set GITHUB_USER and GITHUB_PASS env vars", call. = FALSE)
}

# install_github("rgithub", "cscheid")
base <- "https://api.github.com"
config <- c(
  authenticate(user, pwd, type = "basic"), 
  add_headers(Accept = "application/vnd.github.preview"))

rate_limit <- function() {
  content(GET("https://api.github.com/rate_limit", config))  
}

github_get <- function(...) {
  req <- GET(..., config = config)
  
  c <- content(req)
  if (req$status_code != 200) {
    if (length(c) == 0) {
      stop(req$status)
    } else {
      stop(c$message, call. = FALSE)
    }
  }
  c  
}