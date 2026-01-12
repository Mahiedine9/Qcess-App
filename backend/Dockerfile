# -------- Build stage --------
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /src

COPY pom.xml .
COPY platform-contracts/pom.xml platform-contracts/pom.xml
COPY platform-core/pom.xml      platform-core/pom.xml
COPY module-acess/pom.xml       module-acess/pom.xml
COPY module-maintenance/pom.xml module-maintenance/pom.xml
COPY module-notification/pom.xml module-notification/pom.xml
COPY module-dashboard/pom.xml  module-dashboard/pom.xml
COPY app-rest/pom.xml           app-rest/pom.xml

COPY platform-contracts/src platform-contracts/src
COPY platform-core/src      platform-core/src
COPY module-acess/src       module-acess/src
COPY module-maintenance/src module-maintenance/src
COPY module-notification/src module-notification/src
COPY module-dashboard/src   module-dashboard/src
COPY app-rest/src           app-rest/src
RUN mvn -q -B -DskipTests -pl app-rest -am clean package

FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /src/app-rest/target/*SNAPSHOT.jar app.jar

ENV DB_HOST=localhost \
    DB_PORT=5432 \
    DB_NAME=qcessdb \
    DB_USER=qcess \
    DB_PASSWORD=qcess

EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
