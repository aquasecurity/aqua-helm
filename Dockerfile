FROM alpine/helm:3.7.2

RUN apk add --update --no-cache curl openssl git && \
    helm plugin install https://github.com/chartmuseum/helm-push.git

COPY . .

ENTRYPOINT [ "/bin/sh" ]
