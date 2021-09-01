resources:
  - "@type": "type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.Secret"
    name: "validation_context_sds"
    validation_context:
      trusted_ca:
        filename: /etc/aquasec/envoy/ca-certificates.crt