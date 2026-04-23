# Stage 1 — Build
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app

COPY pom.xml .
COPY Amazon-Core/ ./Amazon-Core/
COPY Amazon-Web/ ./Amazon-Web/

RUN mvn clean package -DskipTests

# Stage 2 — Run using Tomcat
FROM tomcat:9.0-jdk17-temurin

# Remove default apps (optional but clean)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR to Tomcat webapps
COPY --from=builder /app/Amazon-Web/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]