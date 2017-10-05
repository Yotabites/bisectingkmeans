#bisectingkmeans

###Installation:




### Usage:

```
library(bisectingkmeans)
library(sparklyr)
library(dplyr)
sc <- spark_connect(master = "local", app_name = "sparklyr")

sdf <- spark_read_csv(sc,path = "Data.csv", name = "SampleData")
count_(sdf)

df<-impute(sdf,"mode")

bkm <- df  %>%  ml_bisectingkmeans(centers=5L)

compute_costs <- c(compute_costs, bkm$cost)

pred_df<-sdf_predict(bkm,df)%>%select(prediction)

print(compute_costs)
```