.PHONY: dataset

dataset:
	./download.sh 2019 01

put-file:
	hdfs dfs -mkdir -p /nyctaxi/input/
	hdfs dfs -put -f ./datasets/yellow_tripdata_2019-01.parquet /nyctaxi/input/
	hdfs dfs -rm -r -f /nyctaxi/kpi/hourly_gmv_2019-01/

submit: dataset put-file
	spark-submit \
	--master yarn \
	--deploy-mode cluster \
	--name lec7-taxi-kpis \
	--num-executors 6 \
	--executor-cores 3 \
	--executor-memory 4g \
	taxi_kpis_yarn.py

show:
	hdfs dfs -ls /nyctaxi/kpi/hourly_gmv_2019-01/

all: submit show