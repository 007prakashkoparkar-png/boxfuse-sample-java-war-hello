pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        echo 'Checking out source code...'
        checkout scm
      }
    }
    stage('Build and Test') {
      agent {
        docker {
          image 'maven:3.9.6-eclipse-temurin-21'
          reuseNode true
        }
      }
      steps {
        sh 'mvn clean package -Dmaven.repo.local=.m2/repository'
      }
    }
    stage('Static Code Analysis') {
      agent {
        docker {
          image 'maven:3.9.6-eclipse-temurin-21'
          reuseNode true
        }
      }
      environment {
        SONAR_URL = "http://13.201.99.189:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
          sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar -Dsonar.login=\$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL} -Dmaven.repo.local=.m2/repository -Dsonar.userHome=.sonar"
        }
      }
    }
    stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "007prakashkoparkar/boxfuse-app:${env.BUILD_NUMBER}"
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh "docker build -t ${DOCKER_IMAGE} ."
          sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
          sh "docker push ${DOCKER_IMAGE}"
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
                    git push https://${GITHUB_TOKEN}@://github.com{GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:main
                """
            }
        }
    }
  }
}
