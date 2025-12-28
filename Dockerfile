# Dockerfile
FROM alpine:latest

RUN apk add --no-cache logrotate

CMD ["tail", "-f", "/dev/null"]
