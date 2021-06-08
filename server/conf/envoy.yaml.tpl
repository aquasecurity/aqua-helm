static_resources:
  listeners:
  - address:
      socket_address:
        address: 0.0.0.0
        port_value: 8443
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stream_idle_timeout: 0s
          drain_timeout: 20s
          access_log:
          - name: envoy.access_loggers.file
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
              path: "/dev/stdout"
          codec_type: AUTO
          stat_prefix: ingress_https
          route_config:
            name: local_route
            virtual_hosts:
            - name: https
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: aqua-gateway-svc
                  timeout: 0s
          http_filters:
          - name: envoy.filters.http.health_check
            typed_config:
              "@type": type.googleapis.com/envoy.config.filter.http.health_check.v2.HealthCheck
              pass_through_mode: false
              headers:
              - name: ":path"
                exact_match: "/healthz"
              - name: "x-envoy-livenessprobe"
                exact_match: "healthz"
          - name: envoy.filters.http.router
            typed_config: {}
      transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            {{- if .Values.envoy.TLS.listener.rootCA_fileName }}
            validation_context:
              trusted_ca:
                filename: "/etc/ssl/envoy/listener/{{ .Values.envoy.TLS.listener.rootCA_fileName }}"
            {{- end }}
            alpn_protocols: "h2,http/1.1"
            tls_certificates:
            - certificate_chain:
                filename: "/etc/ssl/envoy/listener/{{ .Values.envoy.TLS.listener.publicKey_fileName }}"
              private_key:
                filename: "/etc/ssl/envoy/listener/{{ .Values.envoy.TLS.listener.privateKey_fileName }}"
  clusters:
  - name: aqua-gateway-svc
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
      cluster_name: aqua-gateway-svc
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: {{ .Release.Name }}-gateway-headless-svc.{{ .Release.Namespace }}.svc.cluster.local
                port_value: 8443
    {{- if .Values.envoy.TLS.cluster.enabled }}
    transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
            "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
            sni: {{ .Release.Name }}-gateway-svc
            common_tls_context:
              {{- if .Values.envoy.TLS.cluster.rootCA_fileName }}
              validation_context:
                trusted_ca:
                  filename: "/etc/ssl/envoy/cluster/{{ .Values.envoy.TLS.cluster.rootCA_fileName }}"
              {{- end }}
              alpn_protocols: "h2,http/1.1"
              tls_certificates:
              - certificate_chain:
                  filename: "/etc/ssl/envoy/cluster/{{ .Values.envoy.TLS.cluster.publicKey_fileName }}"
                private_key:
                  filename: "/etc/ssl/envoy/cluster/{{ .Values.envoy.TLS.cluster.privateKey_fileName }}"
    {{- end }}
admin:
  access_log_path: "/dev/stdout"
  address:
    socket_address:
      address: 127.0.0.1
      port_value: 8090