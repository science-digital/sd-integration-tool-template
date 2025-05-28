SERVICE_TITLE=AI tool to check for prime numbers

PROJECT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PORT=8078
SERVICE_URL=http://localhost:${PORT}


#include Makefile.common

run:
	poetry ivcap run -- --port ${PORT}


test-local:
	curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:${PORT}

test-job: IVCAP_API=https://develop.ivcap.net
test-job:
	TOKEN=$(shell ivcap context get access-token --refresh-token); \
	curl \
	-X POST \
	-H "content-type: application/json" \
	-H "Timeout: 20" \
	-H "Authorization: Bearer $$TOKEN" \
	--data "{\"number\": 997}" \
	${IVCAP_API}/1/services2/$(shell poetry ivcap --silent get-service-id)/jobs?with-result-content=true | jq

service-id:
	@echo ${SERVICE_ID}

docker-build:
	poetry ivcap docker-build

docker-run:
	poetry ivcap docker-run -- --port ${PORT}

docker-debug: #docker-build
	docker run -it \
		-p 8888:8080 \
		--user ${DOCKER_USER} \
		--platform=linux/${TARGET_ARCH} \
		--entrypoint bash \
		${DOCKER_NAME}_${TARGET_ARCH}

.PHONY: run
