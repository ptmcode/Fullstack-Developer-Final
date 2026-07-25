FROM gradle:8.14-jdk21 AS builder

WORKDIR /app

COPY gradle gradle
COPY build.gradle settings.gradle gradle.properties ./
COPY src ./src

ENV TZ=Asia/Phnom_Penh

RUN gradle bootJar --no-daemon

FROM eclipse-temurin:21-jre-alpine

ENV TZ=Asia/Phnom_Penh

COPY --chown=1001:1001 --from=builder /app/build/libs/*.jar /app/app.jar

EXPOSE 30033

USER 1001

ENTRYPOINT ["java", "-Duser.timezone=Asia/Phnom_Penh", "-jar", "/app/app.jar"]
