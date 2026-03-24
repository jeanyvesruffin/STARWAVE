FROM quay.io/keycloak/keycloak:26.0

ENV KC_HEALTH_ENABLED=true \
	KC_METRICS_ENABLED=true \
	KC_HTTP_ENABLED=true

EXPOSE 8080 9000

WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
