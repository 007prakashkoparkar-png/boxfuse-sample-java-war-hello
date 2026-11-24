# --- Stage 1: Build the WAR file using Maven ---
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy configuration and source files
COPY pom.xml .
COPY src ./src

# Package the application into a WAR file
RUN mvn clean package

# --- Stage 2: Create the production server image ---
FROM tomcat:10.1
WORKDIR /usr/local/tomcat/webapps/

# Remove default Tomcat root applications
RUN rm -rf ROOT

# Copy the compiled WAR file from Stage 1
COPY --from=build /app/target/*.war ./ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
