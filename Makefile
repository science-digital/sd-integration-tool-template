SERVICE_TITLE=AI tool to check for prime numbers
SERVICE_NAME=is-prime-tool

TOOL_FILE=tool-service.py
TOOL_SCHEMA_FILE=is-prime.tool.json
IVCAP_SERVICE_FILE=service.json

GIT_COMMIT := $(shell git rev-parse --short HEAD)
GIT_TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
VERSION="${GIT_TAG}|${GIT_COMMIT}|$(shell date -Iminutes)"

DOCKER_USER="$(shell id -u):$(shell id -g)"
DOCKER_DOMAIN=$(shell echo ${PROVIDER_NAME} | sed -E 's/[-:]/_/g')
DOCKER_NAME=$(shell echo ${SERVICE_NAME} | sed -E 's/-/_/g')
DOCKER_VERSION=${GIT_COMMIT}
TARGET_ARCH := $(shell uname -m)
DEPLOY_ARCH=amd64

PROJECT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PORT=8094
SERVICE_URL=http://localhost:${PORT}

run:
	env VERSION=$(VERSION) \
		python ${PROJECT_DIR}/tool-service.py

test-local:
	curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:${PORT}

submit-agent-query:
	curl -i -X POST \
		-H "Content-Type: application/json" \
		-H "X-Job-UUID: 00000000-0000-0000-0000-000000000000" \
		-H "X-Job-URL: ${SERVICE_URL}/00000000-0000-0000-0000-000000000000" \
		-d @${PROJECT_DIR}/test_query.json ${SERVICE_URL}
	curl -i --no-buffer -N ${SERVICE_URL}/00000000-0000-0000-0000-000000000000

install:
	pip install -r requirements.txt

docker-run: docker-build
	docker run -it \
		-p ${PORT}:80 \
		--platform=linux/${TARGET_ARCH} \
		--rm \
		${DOCKER_NAME}-${TARGET_ARCH}

docker-debug: #docker-build
	docker run -it \
		-p 8888:8080 \
		--user ${DOCKER_USER} \
		--platform=linux/${TARGET_ARCH} \
		--entrypoint bash \
		${DOCKER_NAME}-${TARGET_ARCH}

docker-build:
	$(eval tag:=${DOCKER_NAME}-${TARGET_ARCH})
	@echo "Building docker image '${tag}'"
	docker build \
		-t ${tag} \
		--platform=linux/${TARGET_ARCH} \
		--build-arg VERSION=${VERSION} \
		-f ${PROJECT_DIR}/Dockerfile \
		${PROJECT_DIR} ${DOCKER_BILD_ARGS}
	@echo "\nFinished building docker image ${tag}\n"

SERVICE_IMG := ${DOCKER_DEPLOY}
PUSH_FROM := ""

service-register: tool-register docker-publish
	$(eval tag:=${DOCKER_NAME}-${DEPLOY_ARCH})
	$(eval account_id=$(shell ivcap context get account-id))
	@if [[ ${account_id} != urn:ivcap:account:* ]]; then echo "ERROR: No IVCAP account found"; exit -1; fi
	@$(eval service_id:=urn:ivcap:service:$(shell python3 -c 'import uuid; print(uuid.uuid5(uuid.NAMESPACE_DNS, \
        "${SERVICE_NAME}" + "${account_id}"));'))
	@$(eval image:=$(shell ivcap package list ${tag}))
	@if [[ -z "${image}" ]]; then echo "ERROR: No uploaded docker image '${tag}' found"; exit -1; fi
	@echo "ServiceID: ${service_id}"
	cat ${PROJECT_DIR}/${IVCAP_SERVICE_FILE} \
	| sed 's|#DOCKER_IMG#|${image}|' \
	| sed 's|#SERVICE_ID#|${service_id}|' \
  | ivcap aspect update ${service_id} -f - --timeout 600

tool-register: docker-publish
	$(eval account_id=$(shell ivcap context get account-id))
	@if [[ ${account_id} != urn:ivcap:account:* ]]; then echo "ERROR: No IVCAP account found"; exit -1; fi
	$(eval service_id:=urn:ivcap:service:$(shell python3 -c 'import uuid; print(uuid.uuid5(uuid.NAMESPACE_DNS, \
        "${SERVICE_NAME}" + "${account_id}"));'))
	$(eval tool_id:=$(shell docker run --rm ${DOCKER_NAME}-${DEPLOY_ARCH} --print-tool-description  2>/dev/null | grep "\"id\":" | cut -d\" -f 4 ))
	@echo "DEBUG: ToolID: ${tool_id} ServiceID: ${service_id}"
	@if [[ -z "${tool_id}" ]]; then echo "ERROR: No Tool ID found"; exit -1; fi
	docker run --rm ${DOCKER_NAME}-${DEPLOY_ARCH} --print-tool-description  2>/dev/null \
	| sed 's|#SERVICE_ID#|${service_id}|' \
	| ivcap aspect update ${service_id} -f - --timeout 600

docker-publish: TARGET_ARCH=${DEPLOY_ARCH}
docker-publish: docker-build
	$(eval tag:=${DOCKER_NAME}-${TARGET_ARCH})
	@echo "INFO: Publishing docker image '${tag}'"
	docker tag ${tag} ${tag}:${DOCKER_VERSION}
	$(eval size:=$(shell docker inspect ${DOCKER_NAME} --format='{{.Size}}' | tr -cd '0-9'))
	$(eval imageSize:=$(shell expr ${size} + 0 ))
	@echo "... imageSize is ${imageSize}"
	@$(MAKE) PUSH_FROM="--local " TARGET_ARCH=${TARGET_ARCH} docker-publish-common

docker-publish-common:
	$(eval vtag:=${DOCKER_NAME}-${TARGET_ARCH}:${DOCKER_VERSION})
	$(eval log:=$(shell ivcap package push --force ${PUSH_FROM}${vtag} | tee /dev/tty))
	$(eval SERVICE_IMG := $(shell echo ${log} | sed -E "s/.*([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}.*) pushed/\1/"))
	@if [ "${SERVICE_IMG}" == "" ] || [ "${SERVICE_IMG}" == "${vtag}" ]; then \
		echo "service package push failed"; \
		exit 1; \
	fi
	@echo "INFO: Successfully published '${vtag}' as '${SERVICE_IMG}'"


.PHONY: run
