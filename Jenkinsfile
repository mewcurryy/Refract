pipeline {
    agent any

    environment {
        PROJECT = 'Refract.xcodeproj'
        SCHEME = 'Refract'
        DESTINATION = 'platform=iOS Simulator, name=iPhone 17, OS=latest'
    }

    stages {
        stage('Checkout'){
            steps {
                checkout scm
            }
        }

        stage('Install xcpretty') {
            steps {
                sh 'gem install xcpretty --no-document'
            }
        }

        stage('Build') {
            steps {
                sh """
                    set -o pipefail && xcodebuild build \
                        -project ${PROJECT} \
                        -scheme ${SCHEME} \
                        -destination ${DESTINATION} \
                        | xcpretty
                """
            }
        }

        stage('Unit Test') {
            steps {
                sh """
                    set -o pipefail && xcodebuild test \ 
                        -project ${PROJECT} \
                        -scheme ${SCHEME} \
                        -destination ${DESTINATION} \
                        | xcpretty --report junit --output build/reports/junit.xml
                """ // pipefail buat mastiin semuanya sukses dan kalo ada 1 yang gagal tetap gagal
            }
        }
    }

    post {
        always {
            junit 'build/reports/junit.xml'
        }
        success {
            echo 'build & test success! ✅' 
        }
        failure {
            echo 'failed. check the log ❌'
        }
    }
}