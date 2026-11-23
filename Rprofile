if (interactive() && nzchar(system.file(package = "colorout")))
    library(colorout)

## p3m Linux binaries need the distro codename; elsewhere (e.g., macOS)
## use CRAN, which serves binaries for the platform
cran_repo <- if (nzchar(Sys.which("lsb_release"))) {
    codename <- system2("lsb_release", "-cs", stdout = TRUE)
    paste0("https://p3m.dev/cran/__linux__/", codename, "/latest")
} else {
    "https://cloud.r-project.org/"
}

options(
    useFancyQuotes = FALSE,
    repos = c(CRAN = cran_repo),
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
