# config

A repository for common configuration scripts

Use the `copyCONFIG.sh` script to copy a configuration script
such as "ssh-slash-config" to the home directory (`$HOME`).

```
./copyCONFIG.sh ssh-slash-config
> 'ssh-slash-config' -> '/home/username/.ssh/config'
```

The possible arguments to the `copyCONFIG.sh` script are the
name of the files in the repository.

* See the utils repository for other helper scripts

## Rpackages.txt

To install all the packages listed in Rpackages.txt:

```
BiocManager::install(setdiff(read.csv("https://raw.githubusercontent.com/waldronlab/config/master/Rpackages.txt", as.is=TRUE)[, 1], rownames(installed.packages())))
```

## RStudio launchers

`rstudio-launchers.sh` creates one launcher per R / Bioconductor setup
("RStudio Rel", "RStudio Dev", "RStudio Old"). Each one starts RStudio with
`RSTUDIO_WHICH_R` pointing to an R build in `~/src/svn` (see `buildr/`) and
`R_BIOC_LIB` pointing to a library in `~/R`.

* Linux: app-menu entries in `~/.local/share/applications`
* macOS: small apps (`RStudio Rel.app`, ...) in `~/Applications`, found by
  Spotlight and Launchpad; drag them to the Dock to pin them. They run
  `open -n -a RStudio --env ...`, so each one starts a separate RStudio.

```
./rstudio-launchers.sh           # create or refresh the launchers
./rstudio-launchers.sh --remove  # delete them (restores the system RStudio launcher)
```

Edit the `SETUPS` list at the top of the script when R or Bioconductor
versions change, then re-run it. On Linux, `DEFAULT` picks the setup used when opening
`.R`/`.Rproj` files; the script writes a user copy of the system
`rstudio.desktop` with that setup and hides it from the app menu, so only the
Rel/Dev/Old launchers are shown. Set `DEFAULT` to `""` to restore the system
"RStudio" launcher.

For `R_BIOC_LIB` to take effect, `~/.Renviron` must set the library from it
instead of hard-coding it:

```
R_LIBS_USER=${R_BIOC_LIB-/home/username/R/bioc-release}
```
