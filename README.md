# ddkdevtools

### **Important**

SQL_load saves every table to HOME/data/source_data/sql/. It therefore needs the HOME vector to exist and to point to the Git root directory. If you initialize your global environment with COMMON/startup_COMMON.R, this is automatically the case.

### Example function calls

Load entire table

```{r}
ADI_HIED <- SQL_load(table = "ADI_HIED", database = "ACS")
```

Load only a subset of columns

```{r}
METRICS_10 <- SQL_load(table    = "METRICS_10",
                       database = "DDK",
                       columns  = c("geoid", "year", "coi30_met"))
```

Load only a subset of columns and filter by variable

```{r}
METRICS_10 <- SQL_load(table    = "METRICS_10",
                       database = "DDK",
                       columns  = c("geoid", "year", "coi30_met"),
                       filter   = c("year = 2010"))
```

Load only a subset of columns and filter by variable and string match (this will subset geoid to only those that start with "01")

```{r}
METRICS_10 <- SQL_load(table    = "METRICS_10",
                       database = "DDK",
                       columns  = c("geoid", "year", "coi30_met"),
                       filter   = c("geoid LIKE '01%'", "year = 2010"))
```

### To install and update

To install devtools

```{r}
install.packages("devtools")
```

To update, if you have the package loaded

```{r}
detach("package:ddkdevtools", unload=TRUE)
remove.packages("ddkdevtools")
devtools::install_github("Diversity-Data-Kids/ddkdevtools")
```

To update, if you don't have the package loaded

```{r}
remove.packages("ddkdevtools")
devtools::install_github("Diversity-Data-Kids/ddkdevtools")
```

### For development

To update documentation

```{r}
devtools::document()
```
