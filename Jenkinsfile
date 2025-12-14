pipeline {
    agent any
    options { timestamps() }

    environment {
        IMAGE = "nouveauUser/react-front"
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
                bat "docker build -t %IMAGE%:%TAG% ."
            }
        }

        stage('Run Test') {
            steps {
                bat """
                docker rm -f react_test 2>nul || exit 0
                docker run -d -p 8082:80 --name react_test %IMAGE%:%TAG%
                ping -n 6 127.0.0.1 > nul
                """
            }
        }

        stage('Push Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub_new',
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
        always {
            bat "docker rm -f react_test 2>nul || exit 0"
        }
        success {
            echo '✅ Image Docker React poussée avec succès'
        }
    }
}
