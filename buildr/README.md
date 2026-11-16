## Build R From Source (Linux / Mac)

* These scripts install R from the svn sources, one version per folder
  under `~/src/svn/r-<version>/inst`, so several versions can be used
  side by side
* Provide the R branch version (e.g., '4-6') or 'devel' to the script;
  an optional second argument checks out a specific svn revision

```
./setup.sh           # install build dependencies (once)
./buildr.sh 4-6      # R-4-6-branch
./buildr.sh devel    # R-devel (trunk)
```

### macOS

The macOS setup follows the Bioconductor build machines
([BBS macOS HOWTO](https://github.com/Bioconductor/BBS/blob/devel/Doc/Prepare-macOS-Big-Sur-HOWTO.md))
and CRAN's own R builds:

* `setup.sh` installs the Xcode Command Line Tools, XQuartz, CRAN's
  gfortran (`/opt/gfortran`), and Simon Urbanek's library binaries from
  <https://mac.r-project.org/bin> into `/opt/R/<arch>` (uses `sudo`)
* `buildr.sh` builds against `/opt/R/<arch>` only (no Homebrew libraries)
  with CRAN's compiler settings and a deployment target that matches the
  library binaries (macOS 14 on Apple Silicon)
* Add the tools to your `PATH`:

  ```
  export PATH="/opt/gfortran/bin:/opt/R/arm64/bin:$PATH"
  ```

* Optional: Tcl/Tk comes from a CRAN R installer (`.pkg`, "Customize");
  `pdflatex` (MacTeX or TinyTeX) is needed for PDF manuals and vignettes,
  and a JDK for rJava (then run `R CMD javareconf`)

Adaptation from [this guide](https://www.r-bloggers.com/installing-the-development-version-of-r-on-ubuntu-alongside-the-current-version-of-r/)
