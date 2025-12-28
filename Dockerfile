# Dockerfile
FROM alpine:3.19

RUN apk add --no-cache logrotate=3.21.0-r1

CMD ["tail", "-f", "/dev/null"]
