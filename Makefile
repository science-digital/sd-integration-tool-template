SERVICE_TITLE=AI tool to check for prime numbers
SERVICE_NAME=is-prime-tool

TOOL_FILE=tool-service.py
IVCAP_SERVICE_FILE=service.json

PROJECT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PORT=8078
SERVICE_URL=http://localhost:${PORT}


include Makefile.common

run:
	env VERSION=$(VERSION) \
		python ${PROJECT_DIR}/tool-service.py --port ${PORT}

test-local:
	curl -i -X POST -H "content-type: application/json" --data "{\"number\": 997}" http://localhost:${PORT}

TEST_SERVER=http://ivcap.minikube
TEST_REQUEST=tests/echo.json
test-job:
	curl  -i  \
		-X POST \
		-H "Authorization: Bearer $(shell ivcap context get access-token --refresh-token)"  \
		-H "Content-Type: application/json" \
		-H "Timeout: 60" \
		--data "{\"number\": 997}" \
		${TEST_SERVER}/1/services2/${SERVICE_ID}/jobs

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
		-p ${PORT}:${PORT} \
		--platform=linux/${TARGET_ARCH} \
		--rm \
		${DOCKER_NAME}-${TARGET_ARCH} --port ${PORT}

docker-debug: #docker-build
	docker run -it \
		-p 8888:8080 \
		--user ${DOCKER_USER} \
		--platform=linux/${TARGET_ARCH} \
		--entrypoint bash \
		${DOCKER_NAME}-${TARGET_ARCH}


.PHONY: run
