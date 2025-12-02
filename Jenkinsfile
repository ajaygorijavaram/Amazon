pipeline {
    agent any

    stages {
        stage('Clone Project') {
            steps {
                git branch: 'master', url: 'https://github.com/ajaygorijavaram/Amazon.git'
            }
        }

        stage('Clean') {
            steps {
                dir('Amazon') {
                    sh 'mvn clean'
                }
            }
        }

        stage('Compile') {
            steps {
                dir('Amazon') {
                    sh 'mvn compile'
                }
            }
        }

        stage('Test') {
            steps {
                dir('Amazon') {
                    sh 'mvn test'
                }
            }
        }

        stage('Build') {
            steps {
                dir('Amazon') {
                    sh 'mvn clean install'
                }
            }
        }
    }

    post {
        always {
            echo " Pipeline completed."
        }
        success {
            echo " Pipeline executed successfully!"
        }
        failure {
            echo " Pipeline failed."
        }
    }
}
