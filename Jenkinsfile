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
                            sudo apt update
                            sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
                            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
                            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                            sudo apt update
                            sudo apt install -y docker-ce
                            sudo usermod -aG docker jenkins
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