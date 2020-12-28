dpl ?= .env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

default: build publish
build:
	@echo 'building ${REPO_USERNAME}/${APP_NAME}'
	docker build -t ${REPO_USERNAME}/${APP_NAME} .
publish:
	@echo 'publish latest to ${REPO_USERNAME}'
	docker push ${REPO_USERNAME}/${APP_NAME}:latest
