pipeline {
    agent any

    environment {
        // Dynamically set Docker image name using the Git commit ID
        IMAGE_NAME = "my-static-site:${GIT_COMMIT}"
    }

    stages {

        // Stage 0: Ensure Docker is Installed
        stage('Check Docker Installation') {
            steps {
                script {
                    sh '''
                        if ! command -v docker &> /dev/null
                        then
                            echo "🚨 Docker is not installed. Installing Docker..."
                            # Install Docker (Debian/Ubuntu-based)
                            sudo apt-get update
                            sudo apt-get install ca-certificates curl
                            sudo install -m 0755 -d /etc/apt/keyrings
                            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                            sudo chmod a+r /etc/apt/keyrings/docker.asc
                            echo \
                            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                            $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
                            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                            sudo apt-get update
                            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                            sudo docker run hello-world
                            echo "✅ Docker installed successfully."
                        else
                            echo "✅ Docker is already installed."
                        fi
                    '''
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
                    sh 'docker build -t $IMAGE_NAME .'
                }
            }
        }

        // Stage 3: Run the Docker Container
        stage('Run Container Locally') {
            steps {
                script {
                    sh 'docker rm -f static-site || true'
                    sh 'docker run -d --name static-site -p 8080:80 $IMAGE_NAME'
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
                            docker push $IMAGE_NAME
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker rm -f static-site || true'
        }
    }
}
// This Jenkinsfile is designed to build a static site using Docker, run it locally, and push the image to Docker Hub.
// It includes a stage to check if Docker is installed and installs it if not. The pipeline uses Git to clone the repository,