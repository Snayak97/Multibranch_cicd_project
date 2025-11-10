pipeline {
    agent any

    environment {
        IMAGE_NAME = "myreactapp"
        DEFAULT_PORT = "5173"
    }

    stages {
        
        stage('Cleanup') {
            steps {
                deleteDir()
                echo 'Workspace cleaned successfully'
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Checking out code..."
                checkout scm
                script {
                    
                    BRANCH_NAME = env.BRANCH_NAME.replaceAll('[^a-zA-Z0-9_-]', '-')
                    echo "🪴 Current branch: ${BRANCH_NAME}"

                    
                    switch (BRANCH_NAME) {
                        case "develop":
                            PORT = "8071"
                            break
                        case "feature":
                            PORT = "8072"
                            break
                        case "staging":
                            PORT = "8073"
                            break
                        case "release-v1-0-0":
                            PORT = "8074"
                            break
                        case "hotfix-v1-0-1":
                            PORT = "8076"
                            break
                        case "main":
                            PORT = "8077"
                            break
                        default:
                            PORT = DEFAULT_PORT
                    }

                    echo "Port assigned: ${PORT}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image for ${BRANCH_NAME}"

                    sh """
                        docker image prune -f --filter "label=branch=${BRANCH_NAME}" || true
                        
                        docker build -t ${IMAGE_NAME}:${BRANCH_NAME}-latest --label branch=${BRANCH_NAME} .
                        
                    """
                }
            }
        }

        stage('Deploy using Docker Compose') {
            steps {
                script {
                    echo "Deploying ${BRANCH_NAME} branch..."

                    sh """
                        export BRANCH_NAME=${BRANCH_NAME}
                        export PORT=${PORT}

                        docker rm -f ${IMAGE_NAME}_${BRANCH_NAME} || true

                        docker compose -p ${IMAGE_NAME}_${BRANCH_NAME} down || true
                        docker compose -p ${IMAGE_NAME}_${BRANCH_NAME} up -d --build
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                echo "Deployment successful for ${BRANCH_NAME} on port ${PORT}"
            }
        }
        failure {
            script {
                echo " Deployment failed for ${BRANCH_NAME}"
            }
        }
    }
}
