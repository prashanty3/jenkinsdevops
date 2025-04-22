pipeline {
    agent any

    environment {
        // Dynamically set Docker image name using the Git commit ID
        IMAGE_NAME = "my-static-site:${GIT_COMMIT}"
        DOCKERHUB_REPO = "prashanty3/my-static-site" // Replace with your Docker Hub username
    }

    stages {
        // Stage 0: Check Docker Installation and install if needed
        stage('Setup Docker') {
            steps {
                script {
                    def dockerInstalled = sh(script: 'command -v docker || echo "not found"', returnStdout: true).trim()
                    
                    if (dockerInstalled == "not found") {
                        echo "🚨 Docker not found. Installing Docker..."
                        
                        // Non-interactive Docker installation (no sudo password prompt)
                        sh '''
                            # Update package lists
                            sudo apt-get update || true
                            
                            # Install dependencies for Docker
                            sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common || true
                            
                            # Add Docker's official GPG key
                            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
                            
                            # Set up the stable repository
                            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                            
                            # Update again after adding repo
                            sudo apt-get update
                            
                            # Install Docker
                            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                            
                            # Verify Docker is installed
                            docker --version
                        '''
                    } else {
                        echo "✅ Docker is already installed: ${dockerInstalled}"
                    }
                    
                    // Make sure Docker service is running
                    sh "service docker status || service docker start"
                }
            }
        }

        // Stage 1: Clone the GitHub Repository
        stage('Clone Repository') {
            steps {
                git credentialsId: 'github-token', url: 'https://github.com/prashanty3/jenkinsdevops.git'
            }
        }

        // Stage 2: Build the Docker Image
        stage('Build Docker Image') {
            steps {
                script {
                    // Tag with both commit ID and latest
                    sh "docker build -t ${IMAGE_NAME} -t ${DOCKERHUB_REPO}:latest -t ${DOCKERHUB_REPO}:${GIT_COMMIT} ."
                }
            }
        }

        // Stage 3: Run the Docker Container for testing
        stage('Run Container Locally') {
            steps {
                script {
                    // Remove existing container if it exists and start new one
                    sh 'docker rm -f static-site || true'
                    sh "docker run -d --name static-site -p 8080:80 ${IMAGE_NAME}"
                    
                    // Simple validation that the container is running
                    sh 'sleep 5' // Give container time to start
                    sh 'docker ps | grep static-site'
                }
            }
        }

        // Stage 4: Push to Docker Hub
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKERHUB_REPO}:latest
                            docker push ${DOCKERHUB_REPO}:${GIT_COMMIT}
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up - remove the container and images to free up space
            sh 'docker rm -f static-site || true'
            
            // Optional: Clean up dangling images and containers
            sh 'docker system prune -f'
            
            // Print completion message
            echo "Pipeline completed. Image pushed to Docker Hub: ${DOCKERHUB_REPO}:${GIT_COMMIT}"
        }
        success {
            echo "✅ Build successful! The static website has been containerized and published."
        }
        failure {
            echo "❌ Build failed. Check the logs for details."
        }
    }
}