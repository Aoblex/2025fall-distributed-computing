FROM ubuntu:22.04

USER root

ENV HADOOP_VERSION=3.3.6 \
    HADOOP_HOME=/opt/hadoop \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt-get update && \
    apt-get install -y curl wget tar openssh-server ssh pdsh vim net-tools python3 openjdk-8-jdk && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ && \
    mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys

# create sshd run dir
RUN mkdir -p /var/run/sshd

# copy user provided hadoop configs into the hadoop config directory
COPY config/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
COPY config/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
COPY config/worker ${HADOOP_HOME}/etc/hadoop/workers
COPY config/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
COPY config/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml

# add entrypoint
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /opt/hadoop
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
