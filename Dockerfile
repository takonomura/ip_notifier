FROM alpine:latest
MAINTAINER takonomura

RUN apk add --no-cache curl

COPY ip_notifier.sh /ip-notifier.sh
ENTRYPOINT /ip_notifier.sh
