# Stage 1 — Build
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY Amazon-Core/ ./Amazon-Core/
COPY Amazon-Web/ ./Amazon-Web/
RUN mvn clean package -DskipTests

# Stage 2 — Run
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/Amazon-Web/target/*.war app.war
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.war"]