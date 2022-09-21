resources:
  - "@type": type.googleapis.com/envoy.config.cluster.v3.Cluster
    name: aqua-kube-enforcer
    connect_timeout: 180s
    type: STRICT_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: ROUND_ROBIN
    http2_protocol_options:
      hpack_table_size: 4294967
      max_concurrent_streams: 2147483647
    circuit_breakers:
      thresholds:
        max_pending_requests: 2147483647
        max_requests: 2147483647
    load_assignment:
      cluster_name: aqua-kube-enforcer
      endpoints:
        - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: localhost
                    port_value: 8442
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: aqua-kube-enforcer
  - "@type": type.googleapis.com/envoy.config.cluster.v3.Cluster
    name: aqua-kube-enforcer-k8s
    connect_timeout: 180s
    type: STRICT_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: ROUND_ROBIN
    circuit_breakers:
      thresholds:
        max_pending_requests: 2147483647
        max_requests: 2147483647
    load_assignment:
      cluster_name: aqua-kube-enforcer-k8s
      endpoints:
        - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: localhost
                    port_value: 8449
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: aqua-kube-enforcer-k8s
  - "@type": type.googleapis.com/envoy.config.cluster.v3.Cluster
    name: aqua-gateway
    connect_timeout: 180s
    type: STRICT_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: ROUND_ROBIN
    http2_protocol_options:
      hpack_table_size: 4294967
      max_concurrent_streams: 2147483647
    circuit_breakers:
      thresholds:
        max_pending_requests: 2147483647
        max_requests: 2147483647
    load_assignment:
      cluster_name: aqua-gateway
      endpoints:
        - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: {{ .Values.global.gateway.address }}
                    port_value: {{ .Values.global.gateway.port }}
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: aqua-gateway
