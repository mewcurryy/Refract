pipeline {
    agent any

    environment {
        PROJECT = 'Refract.xcodeproj'
        SCHEME = 'Refract'
        DESTINATION = 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
        LANG = 'en_US.UTF-8'
        LC_ALL = 'en_US.UTF-8'
    }

    stages {
        stage('Checkout'){
            steps {
                checkout scm
            }
        }

        stage('Install xcpretty') {
            steps {
                sh 'gem install xcpretty --user-install'
            }
        }

        stage('Build') {
            steps {
                sh """
                    export PATH="$PATH:/Users/davin/.gem/ruby/2.6.0/bin"
                    set -o pipefail && xcodebuild build \
                        -project "${PROJECT}" \
                        -scheme "${SCHEME}" \
                        -destination "${DESTINATION}" \
                        | xcpretty
                """
            }
        }

        stage('Unit Test') {
            steps {
                sh """
                    export PATH="$PATH:/Users/davin/.gem/ruby/2.6.0/bin"
                    xcrun simctl shutdown all || true
                    set -o pipefail && xcodebuild test \
                        -project "${PROJECT}" \
                        -scheme "${SCHEME}" \
                        -destination "${DESTINATION}" \
                        -parallel-testing-enabled NO \
                        -maximum-concurrent-test-simulator-destinations 1 \
                        | xcpretty --report junit --output build/reports/junit.xml
                """
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'build/reports/junit.xml'
        }
        success {
            echo 'build & test success! ✅'
        }
        failure {
            echo 'failed. check the log ❌'
        }
    }
}