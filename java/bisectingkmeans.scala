package bisectingkmeans

import java.util.HashMap

import org.apache.spark.sql.DataFrame
import org.apache.spark.ml.feature.Imputer
import org.apache.spark.sql.functions._

/**
  * Created by yesh on 9/18/17.
  */
object Utils {

  /**
    *
    * Util method for imputing null values in Dataframe
    *
    * @param impute_strategy takes values mean,median,mode
    * @param df
    * @return imputed dataframe
    */
  def impute(impute_strategy: String, df: DataFrame): DataFrame = {

    val imputer = new Imputer().setInputCols(df.columns).setOutputCols(df.columns.map(c => s"${c}"))
    if (impute_strategy.equalsIgnoreCase("mean")) {
      imputer.setStrategy("mean")
      imputer.fit(df).transform(df)
    } else if (impute_strategy.equalsIgnoreCase("median")) {
      imputer.setStrategy("median")
      imputer.fit(df).transform(df)
    } else if (impute_strategy.equalsIgnoreCase("mode")) {
      val valueMap = new HashMap[String, Any]()
      for (col <- df.columns) {
        valueMap.put(col, df.filter(s"$col is not null").groupBy(s"$col").count.first.get(0))
      }
      df.na.fill(valueMap)
    } else df
  }
}
