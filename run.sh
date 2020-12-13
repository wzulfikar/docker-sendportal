#!/bin/bash

source .env

# Build docker image for sendportal
docker build -t ${CONTAINER_NAME} docker

# Run redis
docker run -d --name ${CONTAINER_NAME}_redis --rm redis

# Run app
docker run --rm -d --name ${CONTAINER_NAME} \
    --link ${CONTAINER_NAME}_redis:redis \
    --env-file $(pwd)/.env \
    -v /app \
    -v $(pwd)/.env:/app/.env \
    -v $(pwd)/docker/supervisord.conf:/etc/supervisord.conf \
    ${CONTAINER_NAME}

# Run nginx container
docker run -d --rm --name ${CONTAINER_NAME}_nginx \
    -p 9000:80 \
    -v $(pwd)/docker/nginx.conf:/etc/nginx/conf.d/default.conf \
    -e VIRTUAL_HOST=${VIRTUAL_HOST} \
    -e LETSENCRYPT_HOST=${VIRTUAL_HOST} \
    --volumes-from ${CONTAINER_NAME} \
    --link ${CONTAINER_NAME}:sendportal \
    nginx

# Run sendportal setup
docker exec -it sendportal /app/artisan sp:setup
