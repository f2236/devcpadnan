pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    parameters {
        string(name: 'TOMCAT_URL', defaultValue: 'http://localhost:9090', description: 'Base URL of the Tomcat server')
        string(name: 'TOMCAT_CONTEXT', defaultValue: 'calculator', description: 'Tomcat context path used for deployment')
        string(name: 'TOMCAT_CREDENTIALS_ID', defaultValue: 'tomcat-manager', description: 'Jenkins credentials ID for Tomcat Manager')
    }

    environment {
        APP_NAME = 'calculator'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'mvn -B clean test'
                    } else {
                        bat 'mvn -B clean test'
                    }
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'mvn -B -DskipTests package'
                    } else {
                        bat 'mvn -B -DskipTests package'
                    }
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: params.TOMCAT_CREDENTIALS_ID, usernameVariable: 'TOMCAT_USER', passwordVariable: 'TOMCAT_PASSWORD')]) {
                            def deployUrl = "${params.TOMCAT_URL}/manager/text/deploy?path=/${params.TOMCAT_CONTEXT}&update=true"
                            if (isUnix()) {
                                sh "curl --fail --show-error --silent -u \"$TOMCAT_USER:$TOMCAT_PASSWORD\" --upload-file \"target/${env.APP_NAME}.war\" \"${deployUrl}\""
                            } else {
                                bat "curl --fail --show-error --silent -u %TOMCAT_USER%:%TOMCAT_PASSWORD% --upload-file \"target\\${env.APP_NAME}.war\" \"${deployUrl}\""
                            }
                            echo "✓ Successfully deployed calculator.war to ${params.TOMCAT_URL}/${params.TOMCAT_CONTEXT}"
                        }
                    } catch (Exception e) {
                        echo "✗ Deploy stage failed. This is likely because the '${params.TOMCAT_CREDENTIALS_ID}' credential is not set up in Jenkins."
                        echo ""
                        echo "To fix this:"
                        echo "1. Go to Jenkins → Manage Jenkins → Manage Credentials → (global)"
                        echo "2. Click 'Add Credentials' with these values:"
                        echo "   - Kind: Username with password"
                        echo "   - Username: admin"
                        echo "   - Password: admin123"
                        echo "   - ID: ${params.TOMCAT_CREDENTIALS_ID}"
                        echo "3. Save and re-run this job"
                        echo ""
                        echo "Or use the automated setup script:"
                        echo "   cd workspace && .\\setup-jenkins-credentials.ps1 -JenkinsToken YOUR_API_TOKEN"
                        echo ""
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.war', fingerprint: true
        }
    }
}