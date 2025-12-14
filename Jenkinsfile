pipeline {
    agent any

    environment {
        IMAGE = "rebaeisafa/react-front"
        TAG   = "latest"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %IMAGE%:%TAG% ."
            }
        }

        stage('Push Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'react_id',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    bat """
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker push %IMAGE%:%TAG%
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Image Docker créée et poussée automatiquement'
        }
        failure {
            echo '❌ Pipeline échoué'
        }
    }
}
