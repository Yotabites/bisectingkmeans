# bisectingkmeans

This is a Sparklyr extension for bisectinkmeans algorithm in Spark MLlib
<br>


> ####Note: Inorder to use impute you need to have spark 2.2.0


<br>
### Installation:

* Clone this repository using git clone
* Install it as
```
library(devtools)
install_github("Yotabites/bisectingkmeans")
```
<br>

### Usage:

Following code sample gives the usage of the library

* Import libraries

```
library(sparklyr)
library(dplyr)
library(bisectingkmeans)
```

* Set Environment variables

```
Sys.setenv("SPARK_HOME"="$SPARK_HOME")
Sys.setenv("SPARK_HOME_VERSION"="2.2.0")
```

* To connect to the local Spark instance you pass “local” as the value of the Spark master node to spark_connect:
```
sc <- spark_connect(master = "local", app_name = "sparklyr")
```

* For a Hadoop YARN cluster, you can connect using the YARN master, for example:
```
sc <- spark_connect(master = "yar-client", app_name = "sparklyr")
```

<br>
##### Note data should have only float values for computation
<br>

* Load DataFrame
```
sdf <- spark_read_csv(sc,path = "Data.csv", name = "SampleData")
```
* Test Data Load
```
count(sdf)
```
* Impute Null values with Mean
> ######Note: Inorder to use impute you need to have spark 2.2.0
```
df<-impute(sdf,"mean")
```
* Run Bisecting Kmeans Algorithm
```
bkm <- df  %>%  ml_bisectingkmeans(centers=5L)
```

* Get Compute Costs
```
print("The Compute Cost is  ",bkm$cost)
```
* Perform Prediction
```
pred_df<-sdf_predict(bkm,df)%>%select(prediction)
```
