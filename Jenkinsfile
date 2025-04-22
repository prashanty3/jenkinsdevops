pipeline {
    agent any

    environment {
        // Use your Docker Hub username as prefix for the image name
        DOCKER_HUB_USERNAME = "prashanty3"
        // Dynamically set Docker image name using the Git commit ID
        IMAGE_NAME = "${DOCKER_HUB_USERNAME}/my-static-site:${GIT_COMMIT}"
        IMAGE_LATEST = "${DOCKER_HUB_USERNAME}/my-static-site:latest"
    }

    stages {
        // Stage 1: Clone the GitHub Repository
        stage('Clone Repository') {
            steps {
                // Replace with your GitHub repo and credentialsId
                git credentialsId: 'github-token', url: 'https://github.com/prashanty3/jenkinsdevops.git'
            }
        }

        // Stage 2: Build the Docker Image
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image and tag it with both Git commit ID and latest
                    sh "docker build -t ${IMAGE_NAME} -t ${IMAGE_LATEST} ."
                }
            }
        }

        // Stage 3: Run the Docker Container
        stage('Run Container Locally') {
            steps {
                script {
                    // Stop any existing container with the same name (optional)
                    sh 'docker rm -f static-site || true'

                    // Run the container in detached mode on port 8090
                    sh "docker run -d --name static-site -p 8090:80 ${IMAGE_NAME}"
                }
            }
        }

        // Stage 4: Push the Docker Image to Docker Hub
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        // Login to Docker Hub and push the image
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
        // Clean up: Remove container if something fails
        always {
            sh 'docker rm -f static-site || true'
            echo "Pipeline completed"
        }
        success {
            echo "✅ Build successful! Image pushed to Docker Hub as ${IMAGE_NAME}"
        }
        failure {
            echo "❌ Build failed. Check the logs for details."
        }
    }
}
// This Jenkinsfile is designed to build a static site using Docker, run it locally, and push the image to Docker Hub.
// Make sure to replace 'github-token' and 'dockerhub-creds' with your actual Jenkins credentials IDs.