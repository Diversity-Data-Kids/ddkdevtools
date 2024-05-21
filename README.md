# ddkdevtools

R-code to install devtools

```{r}
install.packages("devtools")
```

R-code to update if you have the package loaded

```{r}
detach("package:ddkdevtools", unload=TRUE)
remove.packages("ddkdevtools")
devtools::install_github("Diversity-Data-Kids/ddkdevtools")
```

R-code to update if you have the package loaded

```{r}
remove.packages("ddkdevtools")
devtools::install_github("Diversity-Data-Kids/ddkdevtools")
```
