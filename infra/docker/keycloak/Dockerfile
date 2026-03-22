## Multi-stage Dockerfile
## Stage 1: get Keycloak distribution from the official image
FROM quay.io/keycloak/keycloak:26.0 AS kc-base

## Stage 2: runtime image based on UBI that can install packages
FROM registry.access.redhat.com/ubi8/ubi:8.8

USER root
# If package manager not available, add a small static busybox binary (includes wget)
ADD https://github.com/nxadm/busybox-static/releases/download/1.35.0/busybox-x86_64 /usr/local/bin/busybox
RUN chmod +x /usr/local/bin/busybox && ln -s /usr/local/bin/busybox /usr/local/bin/wget

# Copy Keycloak distribution from the official image
COPY --from=kc-base /opt/keycloak /opt/keycloak

ENV KC_HEALTH_ENABLED=true \
	KC_METRICS_ENABLED=true \
	KC_HTTP_ENABLED=true

EXPOSE 8080 9000

USER 1000
WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--import-realm"]
