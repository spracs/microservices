dpl ?= .env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

default: build publish
build:
#	@echo 'building ${REPO_USERNAME}/${APP_NAME}'
	@for appname in $(APP_NAME); do \
	echo 'building ${REPO_USERNAME}/'$$appname; \
	docker build -t ${REPO_USERNAME}/$$appname ./$$appname; \
	done
#	docker build -t ${REPO_USERNAME}/${APP_NAME} ./${APP_NAME}
publish:
	@for appname in $(APP_NAME); do \
	echo 'publish latest to ${REPO_USERNAME}'; \
	docker push ${REPO_USERNAME}/$$appname:latest; \
	done
#	docker push ${REPO_USERNAME}/${APP_NAME}:latest
