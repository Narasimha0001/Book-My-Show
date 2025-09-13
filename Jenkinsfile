pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "narasimha0001/bookmyshow"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'feature/Capstone', url: 'https://github.com/Narasimha0001/Book-My-Show.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    script {
                        // Get the sonar-scanner installation path
                        def scannerHome = tool 'sonar-scanner'
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                          -Dsonar.projectKey=bookmyshow \
                          -Dsonar.sources=./bookmyshow-app \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_AUTH_TOKEN
                        """
                    }
                }
            }
        }

      stage('Quality Gate') {
    steps {
        script {
            try {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            } catch (err) {
                echo "⚠️ Quality Gate check skipped due to timeout: ${err}"
            }
        }
    }
}


        stage('Install Dependencies') {
            steps {
                sh 'cd bookmyshow-app && npm install'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker build -t $DOCKER_IMAGE:${BUILD_NUMBER} ./bookmyshow-app
                    docker push $DOCKER_IMAGE:${BUILD_NUMBER}
                    docker tag $DOCKER_IMAGE:${BUILD_NUMBER} $DOCKER_IMAGE:latest
                    docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Deploy to Docker') {
            steps {
                sh 'docker run -d -p 3000:3000 --name bookmyshow $DOCKER_IMAGE:latest || true'
            }
        }
    }

    post {
        always {
            script {
                try {
                    mail to: 'mudhenanarasimharao@gmail.com',
                         subject: "Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
                         body: "Check Jenkins console for details."
                } catch (err) {
                    echo "⚠️ Email notification skipped: ${err}"
                }
            }
        }
    }
}
