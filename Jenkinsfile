pipeline {

    agent any

    environment {
        APP_NAME   = 'java-app'
        REGISTRY   = 'localhost:5000'
        IMAGE      = "${REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}"
    }

    stages {

        stage('Build & Test') {
            steps {
                echo 'Stage 1 - Build'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo 'Stage 2 - Docker image as agent'
                sh """
                    docker build -t ${IMAGE} .
                    docker push ${IMAGE}
                """
            }
        }

        stage('Push WAR to JFrog') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'jfrog-creds',
                    usernameVariable: 'JFROG_USER',
                    passwordVariable: 'JFROG_PASS')]) {
                    sh """
                        curl -u $JFROG_USER:$JFROG_PASS \
                        -T target/*.war \
                        "http://20.213.108.104:8082/artifactory/libs-release-local/${APP_NAME}-${env.BUILD_NUMBER}.war"
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                input message: 'Approve deployment to Minikube?', ok: 'Deploy'
                withKubeConfig([credentialsId: 'minikube-kubeconfig']) {
                    sh """
                        sed -i 's|localhost:5000/java-app:latest|${IMAGE}|g' k8s-deployment.yaml
                        kubectl apply -f k8s-deployment.yaml
                        kubectl rollout status deployment/java-app
                    """
                }
            }
        }

        stage('Verify & Cleanup') {
            steps {
                withKubeConfig([credentialsId: 'minikube-kubeconfig']) {
                    sh 'kubectl get pods'
                    sh 'kubectl get services'
                }
            }
        }
    }

    post {
        success {
            echo "Build ${env.BUILD_NUMBER} deployed successfully"
            rtPublishBuildInfo(serverId: 'jfrog-server')
        }
        failure {
            echo "Build ${env.BUILD_NUMBER} failed"
        }
        aborted {
            echo "Build ${env.BUILD_NUMBER} was aborted"
        }
    }
}
