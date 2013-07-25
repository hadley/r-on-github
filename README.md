# R on github

This project uses githubs code and repository api to collect information about 
all github repositories that use R.

## Getting the data

Getting all repo data is a two step process:

* `1a-search.r` runs searches to find all R language repos. Searches are done by
  month to overcome the current search API limits, and are cached in the 
  `cache/` directory

* `1b-repos.r` takes each repo found by the search and creates a list with 5 
   components:

  * `info`: general information about the repository. 
    http://developer.github.com/v3/repos/#get
  
  * `lng`: languages used in the repo. 
    http://developer.github.com/v3/repos/#list-languages
    
  * `dir`: a directory listing of all files and directories in the repo root.
    http://developer.github.com/v3/repos/contents/#get-contents
  
  * `desc`: if a `DESCRIPTION` file is found, the result of parsing that
    file with `read.dcf` and converting into a list
    
  * `tags`: any tags used by the repo. 
     http://developer.github.com/v3/repos/#list-tags
  
  The data on each repo is cached in `cache-repo/`.
  
To update repos for the current month, `source("1a-search.r")`, then 
`source("1b-repos.r")`. You'll need to set your github user name and password
into environment variables `GITHUB_USER` and `GITHUB_PASS`. All requests are
appropriately throttled to stay within github's rate limits - this means that 
downloading all repo info from scratch will take a number of hours.

## Exploring the data

If you just want to use the already cached data, see `2-languages.r` and 
`2-packages.r` for example exploratory analyses.
