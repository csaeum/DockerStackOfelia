# Dockerfile
FROM alpine:latest
RUN apk add --no-cache logrotate
CMD ["sh"]