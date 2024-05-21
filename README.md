# ddkdevtools

### To install and update

To install devtools

```{r}
install.packages("devtools")
```

To update if you have the package loaded

```{r}
detach("package:ddkdevtools", unload=TRUE)
remove.packages("ddkdevtools")
devtools::install_github("Diversity-Data-Kids/ddkdevtools")
```

To update if you [don't]{.underline} have the package loaded

```{r}
remove.packages("ddkdevtools")
devtools::install_github("Diversity-Data-Kids/ddkdevtools")
```

### For development

To update documentation

```{r}
devtools::document()
```
