resources:
  - "@type": type.googleapis.com/envoy.config.listener.v3.Listener
    name: listener_0
    address:
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
                          prefix: "/agent_grpc_channel.GWChannelV2/PushNotificationHandler"
                          grpc: { }
                        route:
                          cluster: aqua-kube-enforcer
                          timeout: 0s
                      - match:
                          prefix: "/"
                          grpc: { }
                        route:
                          cluster: aqua-gateway
                          timeout: 0s
                      - match:
                          prefix: "/"
                        route:
                          cluster: aqua-kube-enforcer-k8s
                          timeout: 0s

              http_filters:
                - name: envoy.extensions.filters.http.health_check
                  typed_config:
                    "@type": type.googleapis.com/envoy.extensions.filters.http.health_check.v3.HealthCheck
                    pass_through_mode: false
                    headers:
                      - name: ":path"
                        exact_match: "/healthz"
                      - name: "x-envoy-livenessprobe"
                        exact_match: "healthz"
                - name: envoy.filters.http.router
                  typed_config: { }
        transport_socket:
          name: envoy.transport_sockets.tls
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
            common_tls_context:
              {{- if and (.Values.kubeEnforcerAdvance.envoy.TLS.listener.rootCA_fileName) (.Values.kubeEnforcerAdvance.envoy.TLS.listener.enabled) }}
              validation_context:
                trusted_ca:
                  filename: "/etc/ssl/envoy/rootCA.crt"
              {{- end }}
              alpn_protocols: "h2,http/1.1"
              tls_certificates:
                - certificate_chain:
                    filename: "/etc/ssl/envoy/server.crt"
                  private_key:
                    filename: "/etc/ssl/envoy/server.key"
