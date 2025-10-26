# Lab1：MapReduce for NYC Taxi Dataset

## Background
随着大数据应用的普及，如何在分布式环境下处理和分析海量数据成为一个核心问题。Hadoop 提供的 HDFS（分布式文件系统） 与 MapReduce（分布式计算模型） 是早期大数据处理的典型框架，尽管现在 Spark 等系统已经广泛应用，但理解 Hadoop 的思想仍是学习分布式数据处理的重要基础

NYC Taxi 数据集 是一个公开、真实的大规模出行数据集，包含纽约市出租车的行程信息，例如上下车时间与地点、行程距离、乘客数量和费用等。它具有以下特点:
  - 规模大：单月数据就数百万条记录，全年数据可达数十 GB
  - 字段丰富：包含时间、空间、金额等多维信息，适合多种分析任务
  - 真实性：来源于实际出行记录，结果更具参考价值。

本次作业要求大家在钜池云上的3-节点 Hadoop 集群中，利用 HDFS 存储与 MapReduce 编程模式，对 NYC Taxi 数据进行统计分析。通过实践，大家将体验：
  - 如何上传和管理大规模数据集
  - 如何编写 MapReduce 程序完成统计任务
  - 如何调整 HDFS 分块、副本数、Reducer 个数等配置，探索其对性能的影响

## 必做
1. 在钜池云上配置 **3 节点 Hadoop**（1 NameNode + 2 DataNodes），保证 HDFS/YARN 能正常运行
2. **本地将 NYC Taxi Parquet 文件转换为 CSV**，再上传到 HDFS：  
   ```bash
   
   ## example
   
   hdfs dfs -mkdir -p /user/<id>/nyctaxi/input
   
   hdfs dfs -put yellow_tripdata_2019-01.csv /user/<id>/nyctaxi/input/
   
   ```
3. 使用 **Python + Hadoop Streaming（MapReduce）** 完成：  
   - **任务1**：按小时统计 `trips, avg_trip_distance, avg_total_amount`  
     - 输出示例：`YYYY-MM-DD HH   trips,avg_dist,avg_total`  
   - **任务2**：统计热门上车点 `PULocationID\tcount`，输出 TopN（默认 20）  
     - TopN 可用本地排序或二次 MR，自行选择实现  
4. 提交 **代码 + 运行脚本 + 实验报告（截图与分析）**。

---
## 数据集介绍
[下载地址](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

NYC Taxi Trips 数据集由纽约市出租车与豪华车管理委员会（NYC TLC）提供，公开发布，覆盖了多年的出租车行程记录。每条记录代表一次出行，包含以下关键信息：
  - tpep_pickup_datetime：上车时间
  - tpep_dropoff_datetime：下车时间
  - passenger_count：乘客数量
  - trip_distance：行程距离（英里）
  - PULocationID：上车地点 ID（区域编码）
  - DOLocationID：下车地点 ID（区域编码）
  - fare_amount：车费
  - tip_amount：小费
  - total_amount：总金额（包含车费、附加费、小费等）

其中 **Yellow Taxi Trip Records** 就是我们本次作业使用的数据。每个月一个 Parquet 文件，例如：
  - 2019-01 月份数据：yellow_tripdata_2019-01.parquet
  - 2019-02 月份数据：yellow_tripdata_2019-02.parquet
……以此类推。

**考虑到数据量大小，要求至少选择3个月的数据。**

数据最初以 Parquet 格式存储（列式存储，体积小、压缩率高），但本次作业要求大家将其转换为 CSV 以便 MapReduce 处理。

## Parquet → CSV 转换（提示，任选其一）
- **PyArrow/pandas（本地机）**  
  仅抽取所需列，分批写出，避免内存爆：
  ```python
  import pyarrow.parquet as pq, pyarrow.csv as pv, pyarrow as pa
  COLUMNS = ["tpep_pickup_datetime","passenger_count","trip_distance","total_amount","PULocationID"]
  t = pq.read_table("yellow_tripdata_2019-01.parquet", columns=COLUMNS)
  with pv.CSVWriter("yellow_tripdata_2019-01.csv", t.schema) as w:
      for b in t.to_batches(max_chunksize=100_000):
          w.write_table(pa.Table.from_batches([b]))
  ```

- **parquet-tools（命令行）**  
  ```bash
  parquet-tools csv yellow_tripdata_2019-01.parquet > yellow_tripdata_2019-01.csv
  ```

上传 CSV 到 HDFS：
```bash
hdfs dfs -put yellow_tripdata_2019-01.csv /user/<id>/nyctaxi/input/
```

---

## MapReduce 实现要点（Python Streaming）
- **任务1**：Mapper 读 CSV 表头，输出 `hour\tdist,total,1`；Reducer 聚合成 `trips, avg_dist, avg_total`。  
- **任务2**：Mapper 输出 `PULocationID\t1`；Reducer 累加计数；TopN 可通过本地 `sort -k2,2nr | head -n 20` 或二次 MR 完成。  

> CSV 必须至少包含列：`tpep_pickup_datetime, passenger_count, trip_distance, total_amount, PULocationID`。

---

## 可探索方向（至少选择 1个）
- **是否清洗数据**：如 `0 < trip_distance ≤ 100`、`1 ≤ passenger_count ≤ 6`、`total_amount > 0`。比较清洗前/后结果差异。  
- **数据体量**：季度 （3个月） vs 年度 （12个月）；Parquet 与 CSV 体积差异，HDFS 占用与块数。  
- **HDFS 分块大小**：64MB vs 128MB；比较 Map 数量、调度开销、耗时。  
- **副本数（replication）**：1 vs 3；观察 Data Locality 与执行时间。  
- **TopN 实现方式**：本地排序 vs 二次 MR，比较优缺点。  
- **Reducer 个数**：不同 `-D mapreduce.job.reduces` 对吞吐与负载均衡的影响。  
- **小文件问题**：大量小 CSV 对 NameNode 与任务调度的影响，以及如何规避。

---

## 提交要求
- **代码**：`mapper_hourly.py`、`reducer_hourly.py`、`mapper_puloc.py`、`reducer_sum.py`
- **运行脚本**：`run_hourly.sh`、`run_puloc.sh`（或统一 `run.sh`，参数化输入输出路径） 
- **实验报告 (建议不超过3页）**：  
    - 名单（个人or小组）
    - 集群环境说明与关键命令截图
    - 任务1与任务2的结果样例与解释
    - 至少选择 1 个探索方向，展示对比结果与分析
    - GenAI工具使用说明

**目录结构建议**

```
Assignment1_<id>/
  ├─ run_hourly.sh
  ├─ run_puloc.sh
  ├─ mapper_hourly.py
  ├─ reducer_hourly.py
  ├─ mapper_puloc.py
  ├─ reducer_sum.py
  └─ report.pdf
```

---

## 小贴士
- 时间解析：`YYYY-MM-DD HH:MM:SS` 或带 `T`、毫秒的时间 → 可先 `replace("T"," ")` 并截断小数秒。  
- CSV 表头需保留；不同月份字段名或类型可能略有差异，要容错。  
- 避免生成大量小文件；使用整月 CSV 即可，HDFS 会自动切块。  
- 资源不足时可调整：`-D mapreduce.map.memory.mb`、`-D mapreduce.reduce.memory.mb`。
