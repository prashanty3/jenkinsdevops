pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = "prashanty3"
        IMAGE_NAME = "${DOCKER_HUB_USERNAME}/my-static-site:${GIT_COMMIT}"
        IMAGE_LATEST = "${DOCKER_HUB_USERNAME}/my-static-site:latest"
        CONTAINER_NAME = "static-site"
        HOST_PORT = "8081"
        CONTAINER_PORT = "80"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-token', url: 'https://github.com/prashanty3/jenkinsdevops.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME} -t ${IMAGE_LATEST} ."
                }
            }
        }

        stage('Run Container Locally') {
            steps {
                script {
                    // Stop and remove the container if it already exists
                    sh "docker ps -aqf 'name=${CONTAINER_NAME}' | xargs -r docker rm -f"

                    // Run the container in detached mode on port 8081
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_NAME}"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${IMAGE_NAME}
                            docker push ${IMAGE_LATEST}
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker ps -aqf 'name=${CONTAINER_NAME}' | xargs -r docker rm -f"
            echo "🧹 Cleanup complete. Pipeline finished."
        }
        success {
            echo "🚀 Deployed and available at: http://51.20.141.87:${HOST_PORT}/"
        }
        failure {
            echo "❌ Build failed. Check logs for errors."
        }
    }
}
