pipeline {
    agent any
    tools {
        maven 'maven3'
    }
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Choose which environment to deploy: Blue or Green')
        choice(name: 'DOCKER_TAG', choices: ['blue', 'green'], description: 'Choose the Docker image tag for the deployment')
        booleanParam(name: 'SWITCH_TRAFFIC', defaultValue: false, description: 'Switch traffic between Blue and Green')
    }
    environment {
        IMAGE_NAME = "thuyein97/bankapp"
        TAG = "${params.DOCKER_TAG}"  // The image tag now comes from the parameter
        KUBE_NAMESPACE = 'webapps'
        SCANNER_HOME = tool 'sonar_scanner'
        REGISTRY   = "ghcr.io"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/thuyein97/BlueGreenDeployment.git'
            }
        }
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        stage('test') {
            steps {
                sh 'mvn test -DskipTests=true'
            }
        }
                
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        }
        
        // stage('SonarQube Analysis') {
        //     steps {
        //         withSonarQubeEnv('sonar') {
        //             sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=BlueGreen -Dsonar.projectName=BlueGreen -Dsonar.java.binaries=."
        //         }
        //     }
        // }
        // stage('SonarQube QualityGate') {
        //     steps {
        //         script{
        //             waitForQualityGate abortPipeline: false, credentialsId: 'To_sonar'
        //         }
        //     }
        // }
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
        
        
        // stage('Docker build') {
        //     steps {
        //         script {
        //             withDockerRegistry(credentialsId: 'docker-cred') {
        //                 sh "docker build -t ${IMAGE_NAME}:${TAG} ."
        //             }
        //         }
        //     }
        // }

        stage('Build Image') {
            steps {
                sh 'docker build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} .'
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html ${REGISTRY}/${IMAGE_NAME}:${TAG}"
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
        
    //     stage('Deploy MySQL Deployment and Service') {
    //         steps {
    //             script {
    //                 withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: '', credentialsId: 'k8s-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
    //                     sh "kubectl apply -f mysql-ds.yml -n ${KUBE_NAMESPACE}"  // Ensure you have the MySQL deployment YAML ready
    //                 }
    //             }
    //         }
    //     }
        
    //     stage('Deploy SVC-APP') {
    //         steps {
    //             script {
    //                 withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: '', credentialsId: 'k8s-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
    //                     sh """ if ! kubectl get svc bankapp-service -n ${KUBE_NAMESPACE}; then
    //                             kubectl apply -f bankapp-service.yml -n ${KUBE_NAMESPACE}
    //                           fi
    //                     """
    //                }
    //             }
    //         }
    //     }
        
    //     stage('Deploy to Kubernetes') {
    //         steps {
    //             script {
    //                 def deploymentFile = ""
    //                 if (params.DEPLOY_ENV == 'blue') {
    //                     deploymentFile = 'app-deployment-blue.yml'
    //                 } else {
    //                     deploymentFile = 'app-deployment-green.yml'
    //                 }

    //                 withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: '', credentialsId: 'k8s-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
    //                     sh "kubectl apply -f ${deploymentFile} -n ${KUBE_NAMESPACE}"
    //                 }
    //             }
    //         }
    //     }
        
    //     stage('Switch Traffic Between Blue & Green Environment') {
    //         when {
    //             expression { return params.SWITCH_TRAFFIC }
    //         }
    //         steps {
    //             script {
    //                 def newEnv = params.DEPLOY_ENV

    //                 // Always switch traffic based on DEPLOY_ENV
    //                 withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: '', credentialsId: 'k8s-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
    //                     sh '''
    //                         kubectl patch service bankapp-service -p "{\\"spec\\": {\\"selector\\": {\\"app\\": \\"bankapp\\", \\"version\\": \\"''' + newEnv + '''\\"}}}" -n ${KUBE_NAMESPACE}
    //                     '''
    //                 }
    //                 echo "Traffic has been switched to the ${newEnv} environment."
    //             }
    //         }
    //     }
        
    //     stage('Verify Deployment') {
    //         steps {
    //             script {
    //                 def verifyEnv = params.DEPLOY_ENV
    //                 withKubeConfig(caCertificate: '', clusterName: 'minikube', contextName: '', credentialsId: 'k8s-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.49.2:8443') {
    //                     sh """
    //                     kubectl get pods -l version=${verifyEnv} -n ${KUBE_NAMESPACE}
    //                     kubectl get svc bankapp-service -n ${KUBE_NAMESPACE}
    //                     """
    //                 }
    //             }
    //         }
        // }
    }
}
