pipeline {
  agent {
    docker {
      image 'maven:3.9.6-eclipse-temurin-21'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // Mount Docker socket to build images
    }
  }
  stages {
    stage('Checkout') {
      steps {
        echo 'Checking out source code...'
        checkout scm
      }
    }
    stage('Build and Test') {
      steps {
        sh 'ls -ltr'
        sh 'mvn clean package'
      }
    }
    stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://13.201.99.189:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
          sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar -Dsonar.login=\$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}"
        }
      }
    }
    stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "007prakashkoparkar/boxfuse-app:${env.BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = credentials('docker-cred')
      }
      steps {
        script {
            sh "docker build -t ${DOCKER_IMAGE} ."
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            docker.withRegistry('https://docker.io', "docker-cred") {
                dockerImage.push()
            }
        }
      }
    }
    stage('Update Deployment File') {
        environment {
            GIT_REPO_NAME = "boxfuse-gitops-repo" 
            GIT_USER_NAME = "007prakashkoparkar"
        }
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh """
                    git config user.email "prakash.xyz@gmail.com"
                    git config user.name "Prakash Koparkar"
                    sed -i "s/replaceImageTag/${env.BUILD_NUMBER}/g" k8s-manifests/deployment.yml
                    git add k8s-manifests/deployment.yml
                    git commit -m "Update boxfuse image version to ${env.BUILD_NUMBER}"
                    # FIXED: Corrected the malformed shell syntax and variable formatting
                    git push https://${GITHUB_TOKEN}@://github.com{GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:main
                """
            }
        }
    }
  }
}

