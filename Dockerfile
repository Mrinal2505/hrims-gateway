FROM eclipse-temurin:17-jre-jammy

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Duser.timezone=UTC"

ARG GIT_SHA=unknown
ARG VERSION=0.0.1
LABEL org.opencontainers.image.title="hrims-gateway" \
      org.opencontainers.image.vendor="HTI" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}"

WORKDIR /app
COPY target/*.jar /app/app.jar
RUN mkdir -p /app/log

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -sf http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", \
  "-Dfile.encoding=UTF-8", \
  "-Duser.timezone=UTC", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]