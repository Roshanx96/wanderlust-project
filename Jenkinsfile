// Jenkinsfile-CI
pipeline {
    agent any

    parameters {
        string(name: 'FRONTEND_TAG', description: 'Frontend Docker Image Tag (e.g., v1)')
        string(name: 'BACKEND_TAG', description: 'Backend Docker Image Tag (e.g., v1)')
    }

    environment {
        GIT_REPO = 'https://github.com/Roshanx96/wanderlust-mega-project.git'
        DOCKERHUB_USER = 'roshanx'
        FRONTEND_IMAGE = "${DOCKERHUB_USER}/wanderlust-frontend-beta:${FRONTEND_TAG}"
        BACKEND_IMAGE = "${DOCKERHUB_USER}/wanderlust-backend-beta:${BACKEND_TAG}"
        SONARQUBE_SERVER = 'SonarQube-Server'  // Sonar server name configured in Jenkins
    }

    stages {

        stage('Parameter Validation') {
            steps {
                script {
                    if (!params.FRONTEND_TAG || !params.BACKEND_TAG) {
                        error "Both FRONTEND_TAG and BACKEND_TAG parameters must be provided!"
                    }
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: "${env.GIT_REPO}"
            }
        }

        stage('Security Scans') {
            steps {
                sh '''
                trivy fs .
                dependency-check --project wanderlust-mega-project --scan ./ --format ALL --out dependency-check-report
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=wanderlust-mega-project \
                      -Dsonar.sources=backend,frontend \
                      -Dsonar.host.url=$SONAR_HOST_URL \
                      -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Wait for Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Update .env files') {
            steps {
                sh '''
                bash Automation/updatefrontendnew.sh
                bash Automation/updatebackendnew.sh
                '''
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                sh '''
                docker build -t $FRONTEND_IMAGE frontend/
                docker push $FRONTEND_IMAGE

                docker build -t $BACKEND_IMAGE backend/
                docker push $BACKEND_IMAGE
                '''
            }
        }

        stage('Trigger CD Pipeline') {
            steps {
                build job: 'wanderlust-cd-pipeline', 
                parameters: [
                    string(name: 'FRONTEND_TAG', value: "${params.FRONTEND_TAG}"),
                    string(name: 'BACKEND_TAG', value: "${params.BACKEND_TAG}")
                ]
            }
        }
    }

    post {
        failure {
            echo "CI Pipeline Failed ❌"
        }
        success {
            echo "CI Pipeline Successful ✅"
        }
    }
}
