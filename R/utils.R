impute<-function(x,impute_strategy){
  sdf<-spark_dataframe(x)
  df<-invoke_static(sc,"bisectingkmeans.Utils","impute",impute_strategy,sdf)
}
