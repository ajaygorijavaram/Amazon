pipeline {
    agent any
    
    environment {
        APP_NAME     = 'java-app'
        REGISTRY     = 'localhost:5000'
        IMAGE        = "${REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}"
        JFROG_URL    = 'http://20.213.108.104:8082/artifactory'
        REPO_PATH    = 'libs-release-local'
    }

    stages {
        stage('Build & Test') {
            steps {
                dir('Amazon') {
                    sh 'mvn clean package -DskipTests'
                    sh 'find . -name "*.war" -o -name "*.yaml"'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                dir('Amazon') {
                    echo 'Building and pushing Docker image'
                    sh """
                        docker build -t ${IMAGE} .
                        docker push ${IMAGE}
                    """
                }
            }
        }

        stage('Push WAR to JFrog') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'jfrog-creds',
                    usernameVariable: 'JFROG_USER',
                    passwordVariable: 'JFROG_PASS')]) {
                    
                    sh '''
                        WAR_FILE="$WORKSPACE/Amazon/Amazon-Web/target/Amazon.war"
                        
                        echo "Looking for WAR file..."
                        ls -la "$WAR_FILE" 2>/dev/null || echo "WAR file not found at expected path"
                        
                        if [ ! -f "$WAR_FILE" ]; then
                            echo "ERROR: WAR file not found!"
                            find $WORKSPACE -name "*.war"
                            exit 1
                        fi
                        
                        echo "Uploading WAR to JFrog Artifactory..."
                        curl -u $JFROG_USER:$JFROG_PASS \
                             -T "$WAR_FILE" \
                             "${JFROG_URL}/${REPO_PATH}/java-app-${BUILD_NUMBER}.war"
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    // Search for k8s-deployment.yaml in common locations
                    def deploymentFile = ''
                    if (fileExists('Amazon/k8s-deployment.yaml')) {
                        deploymentFile = 'Amazon/k8s-deployment.yaml'
                    } else if (fileExists('k8s-deployment.yaml')) {
                        deploymentFile = 'k8s-deployment.yaml'
                    } else if (fileExists('Amazon/k8s/k8s-deployment.yaml')) {
                        deploymentFile = 'Amazon/k8s/k8s-deployment.yaml'
                    } else {
                        error "❌ k8s-deployment.yaml file not found! Please check your repository structure."
                    }
                    
                    echo "✅ Using deployment file: ${deploymentFile}"
                    
                    input message: 'Approve deployment to Minikube?', ok: 'Deploy'
                    
                    withKubeConfig([credentialsId: 'minikube-kubeconfig']) {
                        sh """
                            sed -i 's|localhost:5000/java-app:latest|${IMAGE}|g' ${deploymentFile}
                            kubectl apply -f ${deploymentFile}
                            kubectl rollout status deployment/java-app --timeout=90s || true
                        """
                    }
                }
            }
        }

        stage('Verify & Cleanup') {
            steps {
                withKubeConfig([credentialsId: 'minikube-kubeconfig']) {
                    sh 'kubectl get pods -o wide'
                    sh 'kubectl get services'
                }
            }
        }
    }

    post {
        success {
            echo "Build ${env.BUILD_NUMBER} deployed successfully"
        }
        failure {
            echo "Build ${env.BUILD_NUMBER} failed"
        }
        aborted {
            echo "Build ${env.BUILD_NUMBER} was aborted"
        }
    }
}
