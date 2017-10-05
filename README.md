#bisectingkmeans

This is a Sparklyr extension for bisectinkmeans algorithm in Spark MLlib

###Installation:

* Clone this repository using git clone
* Install it as
```
library(devtools)
install_github("Yotabites/bisectingkmeans")
```


### Usage:

Following code sample gives the usage of the library

* Import libraries
```
library(bisectingkmeans)
library(sparklyr)
library(dplyr)
```

* connect to Spark
```
sc <- spark_connect(master = "local", app_name = "sparklyr")
```
* load dataf
```
sdf <- spark_read_csv(sc,path = "Data.csv", name = "SampleData")
```
* test data load
```
count_(sdf)
```
* impute null values with mean
```
df<-impute(sdf,"mean")
```
* run Bisecting Kmeans algorithm
```
bkm <- df  %>%  ml_bisectingkmeans(centers=5L)

```

* get compute costs
```
compute_costs <- c(compute_costs, bkm$cost)
print(compute_costs)
```
* perform prediction
```
pred_df<-sdf_predict(bkm,df)%>%select(prediction)

```