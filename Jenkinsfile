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

        stage('Run Container Interactively') {
            steps {
                script {
                    // Stop and remove any existing container with the same name
                    sh "docker ps -aqf 'name=${CONTAINER_NAME}' | xargs -r docker rm -f"

                    // Run the image interactively to trigger any entrypoint scripts
                    sh "docker run -it ${IMAGE_NAME} || true"
                }
            }
        }

        stage('Run Container Detached') {
            steps {
                script {
                    // Run the container in detached mode and map ports
                    sh "docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${CONTAINER_NAME} ${IMAGE_NAME}"
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
        success {
            echo "🚀 Deployed and available at: http://51.20.141.87:${HOST_PORT}/"
        }
        failure {
            echo "❌ Build failed. Check logs for errors."

            // Optional: Cleanup container only on failure
            sh "docker ps -aqf 'name=${CONTAINER_NAME}' | xargs -r docker rm -f"
        }
    }
}
