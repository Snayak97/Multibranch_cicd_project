pipeline {
  agent any

  environment {
    IMAGE_NAME = "myreactapp"
    DEFAULT_PORT = "5173"
    SONAR_HOME = tool 'sonar'
    APP_NAME = "my-react-app"
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
    ansiColor('xterm')
  }

  stages {

    stage('Cleanup') {
      steps {
        echo "========== CLEANING WORKSPACE =========="
        deleteDir()
        echo "Workspace cleaned successfully"
      }
    }

    stage('Checkout Code') {
      steps {
        script {
          echo "Checking out code..."
          retry(3) {
            try {
              checkout scm
              echo "Checkout successful"
            } catch (err) {
              echo "Checkout failed: ${err}"
              echo "Retrying checkout in 2 seconds..."
              sleep 2
              throw err
            }
          }
          echo "========== CHECKOUT COMPLETED =========="
        }
      }
    }

    stage('Debug Workspace') {
      steps {
        echo "========== WORKSPACE DEBUG =========="
        sh '''
          echo "---- Current Directory ----"
          pwd

          echo "---- List Files ----"
          ls -la

          echo "---- Display HTML File ----"
          cat index.html || echo "index.html not found"

          echo "---- Git Status ----"
          git status || echo "Not a git repo"
        '''
      }
    }

    stage('Setup Environment') {
      steps {
        script {
          BRANCH_NAME = env.BRANCH_NAME.replaceAll('[^a-zA-Z0-9_-]', '-')
          echo "🪴 Current branch: ${BRANCH_NAME}"

          PORT = DEFAULT_PORT

          switch (true) {
            case (BRANCH_NAME == "develop"):
              PORT = "8071"
              break
            case (BRANCH_NAME.startsWith("feature")):
              PORT = "8072"
              break
            case (BRANCH_NAME == "staging"):
              PORT = "8073"
              break
            case (BRANCH_NAME.startsWith("release")):
              PORT = "8074" 
              break
            case (BRANCH_NAME.startsWith("hotfix")):
              PORT = "8076" 
              break
            case (BRANCH_NAME == "main"):
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
                echo "========== BUILDING DOCKER IMAGE FOR BRANCH: ${BRANCH_NAME} =========="

                // Step 1: Clean up old images for this branch
                sh """
                    echo "Pruning old Docker images for branch ${BRANCH_NAME}..."
                    docker image prune -f --filter "label=branch=${BRANCH_NAME}" || true
                """

                // Step 2: Build new Docker image
                try {
                    sh """
                        echo "Building Docker image ${IMAGE_NAME}:${BRANCH_NAME}-latest ..."
                        docker build -t ${IMAGE_NAME}:${BRANCH_NAME}-latest --label branch=${BRANCH_NAME} .
                        
                        echo "Verifying Docker image build..."
                        docker images | grep ${IMAGE_NAME} || true
                    """
                    echo "✅ Docker image built successfully: ${IMAGE_NAME}:${BRANCH_NAME}-latest"
                } catch (err) {
                    echo "❌ Docker build failed: ${err}"
                    error "Stopping pipeline due to Docker build failure"
                }
            }
        }
    }
   
   stage('Deploy using Docker Compose') {
    steps {
        script {
            echo "========== DEPLOYING BRANCH: ${BRANCH_NAME} =========="

            // Step 1: Export environment variables safely
            env.BRANCH_NAME_SAFE = BRANCH_NAME.replaceAll('[^a-zA-Z0-9_-]', '-')
            env.DEPLOY_PORT = PORT
            echo "🔹 Branch: ${env.BRANCH_NAME_SAFE}, Port: ${env.DEPLOY_PORT}"

            try {
                // Step 2: Stop and remove any existing container for this branch
                echo "🔹 Stopping and removing existing container (if any)..."
                sh """
                    docker rm -f ${IMAGE_NAME}_${env.BRANCH_NAME_SAFE} || true
                    docker compose -p ${IMAGE_NAME}_${env.BRANCH_NAME_SAFE} down || true
                """

                // Step 3: Start deployment using Docker Compose
                echo "🔹 Starting Docker Compose deployment..."
                sh """
                    docker compose -p ${IMAGE_NAME}_${env.BRANCH_NAME_SAFE} up -d --build
                """

                // Step 4: Verify that the container is running
                echo "🔹 Verifying deployment..."
                def running = sh(script: "docker ps --filter 'name=${IMAGE_NAME}_${env.BRANCH_NAME_SAFE}' --filter 'status=running' -q", returnStdout: true).trim()
                if (!running) {
                    error "❌ Deployment failed: container ${IMAGE_NAME}_${env.BRANCH_NAME_SAFE} is not running!"
                }

                echo "✅ Deployment completed successfully for branch: ${BRANCH_NAME}"
            } catch (err) {
                echo "❌ Deployment failed for branch: ${BRANCH_NAME}: ${err}"
                
            }
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
