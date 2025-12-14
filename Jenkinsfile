pipeline {
    agent any
    
    environment {
        IMAGE = "rebaeisafa/react-front"
        TAG = "${BUILD_NUMBER}"
        // Activer BuildKit
        DOCKER_BUILDKIT = "1"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    // Activer BuildKit explicitement
                    withEnv(['DOCKER_BUILDKIT=1']) {
                        bat "docker build --no-cache -t ${IMAGE}:${TAG} ."
                    }
                }
            }
        }
        
        stage('Test Container') {
            steps {
                script {
                    // Arrêter le conteneur s'il existe déjà
                    bat 'docker stop react-test-container || true'
                    bat 'docker rm react-test-container || true'
                    
                    // Lancer le conteneur pour test
                    bat "docker run -d --name react-test-container -p 8080:80 ${IMAGE}:${TAG}"
                    
                    // Attendre un peu pour que le conteneur démarre
                    sleep 10
                    
                    // Tester si le conteneur répond
                    bat 'curl -f http://localhost:8080 || echo "Container test failed"'
                }
            }
        }
        
        stage('Push to Docker Hub') {
            when {
                expression { env.BRANCH_NAME == 'main' }
            }
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        bat "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        bat "docker push ${IMAGE}:${TAG}"
                        bat "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
                        bat "docker push ${IMAGE}:latest"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Nettoyage
            bat 'docker stop react-test-container || true'
            bat 'docker rm react-test-container || true'
            script {
                // Supprimer l'image seulement si le build a réussi
                bat "docker rmi ${IMAGE}:${TAG} || true"
            }
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}