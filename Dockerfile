FROM alpine:latest

USER root

RUN apk add --update --no-cache curl git openssl && \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    sh get_helm.sh

WORKDIR /aqua

ENTRYPOINT [ "/bin/sh" ]