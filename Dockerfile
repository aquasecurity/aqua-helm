FROM alpine:latest

#RUN apt-get update && \
#    apt-get install curl openssl git wget tar -y

RUN apk add --no-cache ca-certificates git tar

RUN wget  https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz && tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm

#RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
#    chmod 700 get_helm.sh && \
#    ./get_helm.sh

#RUN helm plugin install https://github.com/chartmuseum/helm-push.git

#WORKDIR /aqua-helm

COPY . .

CMD [ "/bin/sh" ]
