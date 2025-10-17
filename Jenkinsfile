pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        SONARQUBE_SERVER = 'SonarQube'
        GIT_REPO_URL = 'https://github.com/Roshanx96/wanderlust.git'
        GIT_BRANCH = 'main'
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()
                checkout scm
            }
        }

        stage('Determine Build Info') {
            steps {
                script {
                    // Generate image tag using branch name and build number (e.g., main-42)
                    env.BRANCH = env.GIT_BRANCH.replaceAll('/', '-')
                    env.IMAGE_TAG = "${env.BRANCH}-${env.BUILD_NUMBER}"
                    echo "Generated Image Tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Security Scans') {
            parallel {
                stage('Trivy Scan') {
                    steps {
                        sh 'trivy fs . --exit-code 1 --severity HIGH,CRITICAL || true'
                    }
                }
                stage('OWASP Dependency Check') {
                    steps {
                        sh 'dependency-check.sh --project wanderlust --scan . || true'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('SonarQube')
            }
            steps {
                sh '''
                    export SONAR_SCANNER_HOME="$HOME/.sonar-scanner"
                    if ! [ -x "$SONAR_SCANNER_HOME/bin/sonar-scanner" ]; then
                        wget -O sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
                        unzip -o sonar-scanner.zip
                        mv sonar-scanner-5.0.1.3006-linux "$SONAR_SCANNER_HOME"
                    fi
                    export PATH="$SONAR_SCANNER_HOME/bin:$PATH"
                '''
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh 'sonar-scanner -Dsonar.projectKey=wanderlust -Dsonar.sources=. -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Push Docker Images') {
            steps {
                script {
                    echo "Building Docker images with tag: ${env.IMAGE_TAG}"
                    
                    sh """
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                        docker build -t roshanx/wanderlust-frontend-image:${env.IMAGE_TAG} ./frontend
                        docker push roshanx/wanderlust-frontend-image:${env.IMAGE_TAG}
                        
                        docker build -t roshanx/wanderlust-backend-image:${env.IMAGE_TAG} ./backend
                        docker push roshanx/wanderlust-backend-image:${env.IMAGE_TAG}
                    """
                }
            }
        }

        stage('Trigger CD Pipeline') {
            steps {
                echo "Triggering CD pipeline with tag: ${env.IMAGE_TAG}"
                build job: 'wanderlust-cd', parameters: [
                    string(name: 'FRONTEND_TAG', value: env.IMAGE_TAG),
                    string(name: 'BACKEND_TAG', value: env.IMAGE_TAG)
                ]
            }
        }
    }

    post {
        success {
            echo "✅ CI pipeline completed successfully (Tag: ${env.IMAGE_TAG})"
        }
        failure {
            echo "❌ CI pipeline failed."
        }
    }
}
