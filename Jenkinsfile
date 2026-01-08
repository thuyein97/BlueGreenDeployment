pipeline {
    agent any
    tools {
        maven 'maven3'
    }
    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        IMAGE_NAME = "thuyein97/bankapp"
        TAG = "${GIT_COMMIT.take(7)}-${BUILD_NUMBER}"
        KUBE_NAMESPACE = 'webapps'
        SCANNER_HOME = tool 'sonar_scanner'
        REGISTRY   = "ghcr.io"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/thuyein97/jenkins-devsecops-gitops-pipeline.git'
            }
        }
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        stage('test') {
            steps {
                sh 'mvn test'
            }
        }
                
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --exit-code 1 --format table -o fs.html ."
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=bankapp -Dsonar.projectName=bankapp -Dsonar.java.binaries=."
                }
            }
        }
        stage('SonarQube QualityGate') {
            steps {
                script{
                    waitForQualityGate abortPipeline: true, credentialsId: 'To_sonar'
                }
            }
        }
        stage('Build application') {
            steps {
                sh 'mvn package -DskipTests=true'
            }
        }
        stage('Publish Artifact to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'My_Global_Settings', jdk: '', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                sh 'mvn deploy -DskipTests=true'
                }
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} .'
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --exit-code 1 --format table -o image.html ${REGISTRY}/${IMAGE_NAME}:${TAG}"
            }
        }
        stage('Docker Push Image') {
            steps {
                withDockerRegistry(
                    credentialsId: 'ghcr-cred',
                    url: 'https://ghcr.io'
                ) {
                    sh """
                        docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}
                    """
                }
            }
        }
        // For the complete demo with mysql deployment.
        stage('Deploy MySQL Deployment and Service') {
            steps {
                script {
                    withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: '', credentialsId: 'k8s-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
                        sh "kubectl apply -f mysql-ds.yml -n ${KUBE_NAMESPACE}"  // Ensure you have the MySQL deployment YAML ready
                    }
                }
            }
        }
        stage('Update Git for ArgoCD') {
            steps {
                script {
                    withCredentials([gitUsernamePassword(credentialsId: 'git-creds', gitToolName: 'Default')]) {
                    sh """
                        git checkout main
                        git pull origin main
                        sed -i 's/tag: .*/tag: ${TAG}/g' ./helm/bankapp/values.yaml
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        git add ./helm/bankapp/values.yaml
                        git commit -m "chore: update image tag to ${TAG} [skip ci]"
                        git push origin main
                    """
                    }
                }
            }
        }
    }
    post {
        always {
            sh 'docker system prune -f'
        }
    }
}


