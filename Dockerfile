FROM ubuntu:latest

RUN apt-get update && \
    apt-get install curl openssl git wget tar -y

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

RUN helm plugin install https://github.com/chartmuseum/helm-push.git

WORKDIR /aqua-helm

COPY . .

CMD [ "/bin/bash" ]
