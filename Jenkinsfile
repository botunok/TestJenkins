pipeline {
    agent any

    environment {
        // Настройки окружения
        DOCKER_IMAGE = "mamaev/testjenkins"
        DOCKER_TAG = "latest"
        CONTAINER_NAME = "testjenkins"
        SERVER_PORT = "9090"
    }

    options {
        // Автоматически очищать рабочую директорию после сборки
        cleanWs()
        disableConcurrentBuilds()
        // Таймаут сборки (60 минут)
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                // Получение кода из репозитория
                checkout scm
                // Вывод информации о коммите
                sh 'git log -1 --oneline'
            }
        }
        /*
        stage('Build') {
            steps {
                // Сборка Java проекта с Maven
                sh 'mvn clean package'
            }
            post {
                // Действия после сборки
                success {
                    // Архивируем артефакты для сохранения
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Test') {
            steps {
                // Запуск тестов
                sh 'mvn test'
            }
            post {
                // Публикация результатов тестов
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        */
        stage('Build Docker Image') {
            steps {
                // Сборка Docker образа
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Run Container') {
            steps {
                // Останавливаем старый контейнер если он существует
                sh "docker rm -f ${CONTAINER_NAME} || true"
                // Запускаем новый контейнер
                sh "docker run -d -p ${SERVER_PORT}:${SERVER_PORT} --name ${CONTAINER_NAME} ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }

        stage('Test Deployment') {
            steps {
                // Ждем пока приложение запустится
                sleep time: 10, unit: 'SECONDS'
                // Проверяем, что приложение работает
                script {
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${SERVER_PORT}/test || echo 'Failed'", returnStdout: true).trim()
                    if (response != "200") {
                        error "Application test failed with HTTP code: ${response}"
                    } else {
                        echo "Application is running successfully!"
                    }
                }
            }
        }
    }

    post {
        // Действия после завершения пайплайна
        always {
            cleanWs()
            // Очистка: останавливаем и удаляем контейнер
            sh "docker rm -f ${CONTAINER_NAME} || true"
            // Уведомление о завершении
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
        }
        success {
            // Уведомление об успешной сборке
            echo "Build succeeded!"
        }
        failure {
            // Уведомление о неудачной сборке
            echo "Build failed!"
            // Можно добавить отправку уведомления (email, Slack и т.д.)
        }
        unstable {
            // Уведомление о нестабильной сборке
            echo "Build is unstable!"
        }
    }
}