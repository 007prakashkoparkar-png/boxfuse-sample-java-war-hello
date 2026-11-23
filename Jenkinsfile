pipeline {
    agent any // Runs directly on your newly configured Ubuntu 24.04 server
    
    stages {
        stage('Checkout Source') {
            steps {
                // Dynamically clones your repository branch into the Jenkins workspace
                checkout scm
            }
        }
        
        stage('Build War Payload') {
            steps {
                // Cleans old artifacts and packages your source code into a .war file
                sh 'mvn clean package'
            }
        }
        
        stage('SonarQube Code Quality Analysis') {
            steps {
                // Connects directly to the native SonarQube server engine we initialized
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
    }
}

