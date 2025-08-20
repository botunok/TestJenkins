FROM maven:3.9.6-eclipse-temurin-21 as MAVEN_BUILD

COPY ./ ./

RUN mvn clean package

FROM eclipse-temurin:21-jre

ARG JAR_FILE=target/*.jar

COPY --from=MAVEN_BUILD ${JAR_FILE} /service.jar

ENTRYPOINT ["java", "-jar", "/service.jar"]
CMD ["--server.port=9090"]