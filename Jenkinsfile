pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }
    }

    post {
        success {
            sh '''
curl -X POST -H 'Content-type: application/json' \
--data '{"text": "SUCCESS: Job ${JOB_NAME} Build #${BUILD_NUMBER}"}' \
https://hooks.slack.com/services/XXXX/YYYY/ZZZZ
'''
        }
        failure {
            sh '''
curl -X POST -H 'Content-type: application/json' \
--data '{"text": "FAILED: Job ${JOB_NAME} Build #${BUILD_NUMBER}"}' \
https://hooks.slack.com/services/XXXX/YYYY/ZZZZ
'''
        }
    }
}
