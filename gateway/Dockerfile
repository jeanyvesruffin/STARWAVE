# =============================================================================
# STARWAVE Gateway – Dockerfile multi-stage (Java 24)
# Build context : racine du projet (.)
# =============================================================================

FROM maven:3.9-eclipse-temurin-24 AS build

WORKDIR /build

COPY pom.xml ./pom.xml
COPY backend/pom.xml ./backend/pom.xml
COPY gateway/pom.xml ./gateway/pom.xml

RUN mvn -f pom.xml dependency:go-offline -pl gateway -am -q

COPY gateway/src ./gateway/src
RUN mvn -f pom.xml package -pl gateway -am -DskipTests -q

# ---------------------------------------------------------------------------
FROM eclipse-temurin:24-jre AS runtime

LABEL org.opencontainers.image.title="STARWAVE Gateway"

RUN groupadd -r starwave && useradd -r -g starwave starwave
USER starwave
WORKDIR /app

COPY --from=build /build/gateway/target/starwave-gateway-*.jar app.jar

EXPOSE 8082

ENV SPRING_PROFILES_ACTIVE=dev \
    JAVA_OPTS="-Xms128m -Xmx256m -XX:+UseContainerSupport"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
