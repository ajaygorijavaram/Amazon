FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM tomcat:10-jre17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/Amazon-Web/target/Amazon.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 9090
ENV JAVA_OPTS="-Dserver.port=9090"
ENTRYPOINT ["catalina.sh", "run"]
