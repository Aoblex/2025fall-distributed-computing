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
COMMON_OPTS := $(LOAD) $(NETWORK) --platform linux/amd64

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
# Run Hadoop cluster using docker-compose
# ------------------------------------------------------

run-cluster: all
	$(COMPOSE) -p $(COMPOSE_PROJECT) -f $(COMPOSE_FILE) up -d

stop-cluster:
	$(COMPOSE) -p $(COMPOSE_PROJECT) -f $(COMPOSE_FILE) down

# -------------------------------------------------------
# Cleanup targets
# -------------------------------------------------------

clean:
	$(DOCKER) builder prune -f
