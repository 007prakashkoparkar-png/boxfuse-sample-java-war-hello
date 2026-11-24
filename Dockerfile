# --- Stage 1: Build the Application ---
FROM 007prakashkoparkar/maven-prakash-docker-agent:v1 AS builder

WORKDIR /app

# Copy the pom.xml and source code into the container
COPY pom.xml .
COPY src ./src

# Compile and package the application into a .war file
RUN mvn clean package

# --- Stage 2: Create the Runtime Image ---
FROM tomcat:9.0-jdk11-corretto

# Remove default Tomcat web applications to clean up the workspace
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the compiled .war file from the builder stage straight into Tomcat's deployment folder
# Note: Renaming it to ROOT.war makes it available at the root URL (http://<IP>:<PORT>/) instead of /hello-1.0/
COPY --from=builder /app/target/hello-1.0.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

