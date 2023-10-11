#!/bin/bash

rm -r dist
parcel build index.html
docker rm -f nginx
docker run --name nginx --rm -v /$(pwd)/dist:/data/www:ro -v /$(pwd)/default.conf:/etc/nginx/conf.d/default.conf:ro -d -p 80:80 --network=simple-auth-app nginx