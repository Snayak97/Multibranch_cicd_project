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
              checkout([
                $class: 'GitSCM',
                branches: [[name: "*/${env.BRANCH_NAME}"]],
                userRemoteConfigs: [[url: "${GIT_URL}"]]
              ])
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

    stage('SonarQube Analysis') {
      steps {
        echo "===== Starting SonarQube Analysis for branch: ${BRANCH_NAME} ====="
        script {
          retry(2) {
            withSonarQubeEnv("sonar") {
              try {
                sh """
                  sonar-scanner \
                  -Dsonar.projectKey=${APP_NAME}-${BRANCH_NAME} \
                  -Dsonar.projectName=${APP_NAME}-${BRANCH_NAME} \
                  -Dsonar.sources=. \
                """
                echo "SonarQube analysis completed successfully for ${BRANCH_NAME}"
              } catch (err) {
                echo "SonarQube analysis failed: ${err}"
                throw err
              }
            }
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
