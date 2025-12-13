pipeline {
    agent any
    options { timestamps() }

    environment {
        IMAGE = "safarebaei/monapp"
        TAG   = "build-${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker version'
                bat "docker build -t %IMAGE%:%TAG% ."
            }
        }

        stage('Run (Docker)') {
            steps {
                bat """
                docker rm -f monapp_test 2>nul || exit 0
                docker run -d --name monapp_test -p 8082:80 %IMAGE%:%TAG%
                """
            }
        }

        stage('Smoke Test') {
            steps {
                bat """
                ping -n 5 127.0.0.1 > nul
                curl -I http://localhost:8082 | find "200 OK"
                """
            }
        }

        stage('Cleanup') {
            steps {
                bat "docker rm -f monapp_test 2>nul || exit 0"
            }
        }

        stage('Push (Docker Hub)') {
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
                    docker tag %IMAGE%:%TAG% %IMAGE%:latest
                    docker push %IMAGE%:%TAG%
                    docker push %IMAGE%:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build + Smoke Test + Push Docker Hub OK'
        }
        failure {
            echo '❌ Pipeline FAILED'
        }
        always {
            bat "docker rm -f monapp_test 2>nul || exit 0"
        }
    }
}
