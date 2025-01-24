pipeline {
    agent any

    tools {
        jdk 'JDK_17' 
        maven '3.9.9' 
    }

    environment {
        AWS_REGION = 'ap-south-1' 
        ECR_REPO = 'dev/ted-search' 
        IMAGE_TAG = "${env.BUILD_NUMBER}" 
        AWS_ACCOUNT_ID = '713881821143' 
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/misgav777/ted_search-.git'
            }
        }

        stage('Build and Test') {
            steps {
                dir('app') { // Navigate to the app directory where pom.xml is located
                    sh 'mvn clean install'
                    sh 'mvn test'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageName = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
                    dir('app') { // Navigate to the app directory where Dockerfile is located
                        sh """
                            # Build the Docker image
                            docker build -t ${imageName} .
                        """
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    
                    def imageName = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
                    sh """
                        # Authenticate to AWS ECR
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        
                        # Push the Docker image to ECR
                        docker push ${imageName}
                    """
                }
            }
        }

        stage('Run E2E Tests with Docker Compose') {
            steps {
                dir('app') {
                    script {
                        try {
                            // Start services using Docker Compose
                            sh """
                                docker compose up -d --build
                                sleep 20
                            """
                            
                            // Run curl test to ensure the app is working
                            sh """
                                chmod +x e2e.sh
                                ./e2e.sh
                             """

                            // Add other E2E test commands here if needed
                            
                        } finally {
                            // Clean up Docker Compose services
                            sh "docker compose down"
                            sh "docker system prune -fa"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Build and deployment completed successfully!"
        }
        failure {
            echo "Build or deployment failed!"
        }
        always {
            cleanWs() // Clean up workspace
        }
    }
}
