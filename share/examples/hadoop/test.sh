HADOOP_EXAMPLE="/root/share/examples/hadoop"
mkdir -p "$HADOOP_EXAMPLE"

touch "$HADOOP_EXAMPLE/input.txt"
cat <<EOF > "$HADOOP_EXAMPLE/input.txt"
Hello Hadoop
Hello World
Hadoop is a framework
Hadoop MapReduce is powerful
MapReduce simplifies big data processing
EOF

hdfs dfs -mkdir -p /test/input
hdfs dfs -put -f "$HADOOP_EXAMPLE/input.txt" /test/input
hdfs dfs -rm -r -f /test/output

hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
    wordcount \
    /test/input \
    /test/output

hdfs dfs -cat /test/output/part-r-00000