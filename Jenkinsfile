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
        sh 'mvn clean package -U -Dmaven.repo.local=.m2/repository'
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
        SONAR_URL = "http://13.201.193.113:9000"
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
        steps {
            withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    rm -rf boxfuse-gitops-repo
                    
                    git clone "https://${GITHUB_TOKEN}@://github.com"
                    cd boxfuse-gitops-repo
                    
                    git config user.email "prakash.xyz@gmail.com"
                    git config user.name "Prakash Koparkar"
                    
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" k8s-manifests/deployment.yml
                    
                    git add k8s-manifests/deployment.yml
                    git commit -m "Update boxfuse image version to ${BUILD_NUMBER}"
                    git push origin main
                '''
            }
        }
    }
  }
}
