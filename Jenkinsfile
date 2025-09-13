pipeline {
    agent any

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/akshu20791/Book-My-Show.git'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonarqube-server') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    sh '''
                    docker build -t narasimha0001/bookmyshow:latest .
                    docker push narasimha0001/bookmyshow:latest
                    '''
                }
            }
        }
        stage('Deploy to Docker') {
            steps {
                sh 'docker run -d -p 3000:3000 narasimha0001/bookmyshow:latest'
            }
        }
    }

    post {
        always {
            mail to: 'mudhenanarasimharao@gmail.com',
                 subject: "Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
                 body: "Check Jenkins console for details."
        }
    }
}
