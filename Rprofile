if (interactive() && nzchar(system.file(package = "colorout")))
    library(colorout)

codename <- system2("lsb_release", "-cs", stdout = TRUE)

options(
    useFancyQuotes = FALSE,
    # repos = c(CRAN = "https://cloud.r-project.org/"),
    ## repos for Ubuntu releases
    repos =
        c(CRAN = paste0("https://p3m.dev/cran/__linux__/", codename, "/latest")),
    BiocManager.check_repositories = FALSE,
    Ncpus = 8,
    max.print = 100,

    # https://kevinushey.github.io/blog/2015/02/02/rprofile-essentials/
    # warn on partial matches
    warnPartialMatchAttr = TRUE,
    warnPartialMatchDollar = TRUE,
    warnPartialMatchArgs = TRUE
)

# enable autocompletions for package names in
# `require()`, `library()`
utils::rc.settings(ipck = TRUE)
