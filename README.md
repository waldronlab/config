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
