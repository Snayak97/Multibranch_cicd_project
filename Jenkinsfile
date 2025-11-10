pipeline {
    agent any

    environment {
        IMAGE_NAME = "myreactapp"
        DEFAULT_PORT = "5173"
    }

    stages {

        stage('Branch Validation') {
            steps {
                script {
                    echo "Checking branch: ${env.BRANCH_NAME}"

                    
                    def allowedBranches = ["develop", "staging", "main"]
                    def isReleaseBranch = env.BRANCH_NAME ==~ /^release\/.*/

                    
                    def isFeatureBranch = env.BRANCH_NAME ==~ /^feature\/.*/
                    def isHotfixBranch = env.BRANCH_NAME ==~ /^hotfix\/.*/

                    if (isFeatureBranch || isHotfixBranch) {
                        echo "Skipping pipeline for branch: ${env.BRANCH_NAME} (feature or hotfix branch)"
                        currentBuild.result = 'SUCCESS'
                        error("Skipping build — feature/* and hotfix/* are ignored")
                    }

                    if (!allowedBranches.contains(env.BRANCH_NAME) && !isReleaseBranch) {
                        echo "Skipping pipeline for branch: ${env.BRANCH_NAME}"
                        currentBuild.result = 'SUCCESS'
                        error("Skipping build — only allowed: develop, staging, main, release/*")
                    } else {
                        echo "Branch allowed: ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                deleteDir()
                echo 'Workspace cleaned successfully'
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    BRANCH_NAME = env.BRANCH_NAME.replaceAll('[^a-zA-Z0-9_-]', '-')
                    echo "🪴 Current branch: ${BRANCH_NAME}"

                    switch (BRANCH_NAME) {
                        case "develop":
                            PORT = "8071"
                            break
                        case "staging":
                            PORT = "8073"
                            break
                        case "main":
                            PORT = "8077"
                            break
                        default:
                            // Dynamic port for release branches
                            if (BRANCH_NAME.startsWith("release-")) {
                                PORT = 8000 + Math.abs(BRANCH_NAME.hashCode() % 100)
                            } else {
                                PORT = DEFAULT_PORT
                            }
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
                echo "Deployment failed for ${BRANCH_NAME}"
            }
        }
    }
}
