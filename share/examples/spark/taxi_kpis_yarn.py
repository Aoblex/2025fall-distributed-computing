from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum as _sum, avg, hour, to_timestamp

# Spark on YARN job — hourly KPIs for NYC Taxi (2019-01, Parquet)
# Submit:
# spark-submit --master yarn --deploy-mode cluster --name lec7-taxi-kpis \\
#   --num-executors 6 --executor-cores 3 --executor-memory 4g \\
#   taxi_kpis_yarn.py

spark = SparkSession.builder.appName("Lec7-M4-YARN-NYC-Parquet").getOrCreate()

src = "hdfs:///nyctaxi/input/yellow_tripdata_2019-01.parquet"
df = spark.read.parquet(src)

base = (df
  .withColumn("pickup_ts", to_timestamp(col("tpep_pickup_datetime")))
  .withColumn("trip_distance", col("trip_distance").cast("double"))
  .withColumn("total_amount", col("total_amount").cast("double"))
  .filter((col("trip_distance")>0)&(col("total_amount")>0))
  .select("pickup_ts","PULocationID","trip_distance","total_amount"))

hourly = (base.withColumn("hour", hour("pickup_ts"))
  .groupBy("hour")
  .agg(_sum("total_amount").alias("sum_total"),
       avg("total_amount").alias("avg_total"),
       _sum("trip_distance").alias("sum_dist"))
  .orderBy("hour"))

hourly.show()
hourly.write.mode("overwrite").parquet("hdfs:///nyctaxi/kpi/hourly_gmv_2019-01")
spark.stop()
