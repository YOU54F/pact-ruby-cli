#!/bin/sh

set -euo >/dev/null

# Enable when we bump the major version to 1 (which we should)
# if [ -n "${MAJOR_TAG}" ]; then
#   docker tag ${DOCKER_IMAGE_ORG_AND_NAME}:latest ${DOCKER_IMAGE_ORG_AND_NAME}:${MAJOR_TAG}
#   docker push ${DOCKER_IMAGE_ORG_AND_NAME}:${MAJOR_TAG}
#   docker push ${DOCKER_IMAGE_ORG_AND_NAME}:latest
# fi


docker buildx build --platform=linux/amd64 \
    --output=type=image,push=true \
    -t ${DOCKER_IMAGE_ORG_AND_NAME}:latest \
    -t ${DOCKER_IMAGE_ORG_AND_NAME}:${TAG} .
 ## We will temporarily publish a multi manifest built as $TAG-multi
 ## To avoid any issues with existing users. We can ask users for 
 ## Feedback and then promote to a multi-manifest build
docker buildx build --platform=linux/amd64,linux/arm64,linux/arm \
    --output=type=image,push=true \
    -t ${DOCKER_IMAGE_ORG_AND_NAME}:latest-multi \
    -t ${DOCKER_IMAGE_ORG_AND_NAME}:${TAG}-multi .