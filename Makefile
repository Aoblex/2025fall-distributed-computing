# ======================================================
# Hadoop Docker Images Build & Run Makefile
# ======================================================

# Docker commands
DOCKER := docker
BUILDX := $(DOCKER) buildx build
COMPOSE := docker compose

# Common build options
NETWORK := --network host
LOAD := --load
COMMON_OPTS := $(LOAD) $(NETWORK)

# Dockerfile directory
DOCKERFILES_DIR := docker/Dockerfiles

# Base image prefix
IMAGE_PREFIX := hadoop
CONTAINER_PREFIX := hadoop

# Compose project name
COMPOSE_PROJECT := hadoop-cluster
COMPOSE_FILE := docker-compose.yml

# ======================================================
# Dockerfile paths
# ======================================================
BASE_DOCKERFILE := $(DOCKERFILES_DIR)/Dockerfile.base
DATANODE_DOCKERFILE := $(DOCKERFILES_DIR)/Dockerfile.datanode
JOBHISTORYSERVER_DOCKERFILE := $(DOCKERFILES_DIR)/Dockerfile.jobhistoryserver
NAMENODE_DOCKERFILE := $(DOCKERFILES_DIR)/Dockerfile.namenode
RESOURCEMANAGER_DOCKERFILE := $(DOCKERFILES_DIR)/Dockerfile.resourcemanager

# ======================================================
# Targets
# ======================================================

.PHONY: all base datanode jobhistoryserver namenode resourcemanager \
        run-base run-datanode run-jobhistoryserver run-namenode run-resourcemanager \
        run-cluster stop-cluster stop-all clean

# ------------------------------------------------------
# Build targets
# ------------------------------------------------------

# 默认：构建所有镜像
all: base datanode jobhistoryserver namenode resourcemanager

base:
	$(BUILDX) $(COMMON_OPTS) -t $(IMAGE_PREFIX):base -f $(BASE_DOCKERFILE) .

datanode: base
	$(BUILDX) $(COMMON_OPTS) -t $(IMAGE_PREFIX):datanode -f $(DATANODE_DOCKERFILE) .

jobhistoryserver: base
	$(BUILDX) $(COMMON_OPTS) -t $(IMAGE_PREFIX):jobhistoryserver -f $(JOBHISTORYSERVER_DOCKERFILE) .

namenode: base
	$(BUILDX) $(COMMON_OPTS) -t $(IMAGE_PREFIX):namenode -f $(NAMENODE_DOCKERFILE) .

resourcemanager: base
	$(BUILDX) $(COMMON_OPTS) -t $(IMAGE_PREFIX):resourcemanager -f $(RESOURCEMANAGER_DOCKERFILE) .

# ------------------------------------------------------
# Run individual containers (auto-build dependency)
# ------------------------------------------------------

run-base: base
	$(DOCKER) run -it --rm --name $(CONTAINER_PREFIX)-base $(IMAGE_PREFIX):base bash

run-datanode: datanode
	$(DOCKER) run -d --name $(CONTAINER_PREFIX)-datanode $(NETWORK) $(IMAGE_PREFIX):datanode

run-jobhistoryserver: jobhistoryserver
	$(DOCKER) run -d --name $(CONTAINER_PREFIX)-jobhistoryserver $(NETWORK) $(IMAGE_PREFIX):jobhistoryserver

run-namenode: namenode
	$(DOCKER) run -d --name $(CONTAINER_PREFIX)-namenode $(NETWORK) -p 9870:9870 $(IMAGE_PREFIX):namenode

run-resourcemanager: resourcemanager
	$(DOCKER) run -d --name $(CONTAINER_PREFIX)-resourcemanager $(NETWORK) -p 8088:8088 $(IMAGE_PREFIX):resourcemanager

# ------------------------------------------------------
# Run Hadoop cluster using docker-compose
# ------------------------------------------------------

# 运行整个 Hadoop 集群（基于 docker-compose.yml）
run-cluster: all
	$(COMPOSE) -p $(COMPOSE_PROJECT) -f $(COMPOSE_FILE) up -d

# 停止整个集群
stop-cluster:
	$(COMPOSE) -p $(COMPOSE_PROJECT) -f $(COMPOSE_FILE) down

# ------------------------------------------------------
# Utility targets
# ------------------------------------------------------

# 停止并删除所有单容器运行实例
stop-all:
	-$(DOCKER) stop $$(docker ps -q --filter "name=$(CONTAINER_PREFIX)-")
	-$(DOCKER) rm $$(docker ps -aq --filter "name=$(CONTAINER_PREFIX)-")

# 清理构建缓存
clean:
	$(DOCKER) builder prune -f
