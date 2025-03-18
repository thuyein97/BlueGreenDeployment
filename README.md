# Blue-Green Deployment Pipeline

## Overview

This Jenkins pipeline automates the build, test, security scan, deployment, and traffic switching for a blue-green deployment strategy using Kubernetes. It ensures a smooth transition between two environments (blue and green) to minimize downtime and risk during deployment.

## Prerequisites

-   Jenkins installed with necessary plugins:
    -   Pipeline
    -   SonarQube Scanner
    -   Trivy for security scanning
    -   Kubernetes CLI (`kubectl`)
    -   Docker and Docker Registry
    -   Kubernetes cluster (e.g., Minikube)
    -   Nexus repository for artifact storage
    -   SonarQube server for code quality analysis

## Pipeline Parameters

| Parameter      | Choices       | Description                                                 |
| :------------- | :------------ | :---------------------------------------------------------- |
| `DEPLOY_ENV`   | `blue`, `green` | The target environment to deploy the application.             |
| `DOCKER_TAG`   | `blue`, `green` | Docker image tag for deployment.                               |
| `SWITCH_TRAFFIC` | `true`/`false` | Flag to switch traffic between blue and green.                  |

## Environment Variables

| Variable          | Value                                 | Description                                        |
| :---------------- | :------------------------------------ | :------------------------------------------------- |
| `IMAGE_NAME`      | `thuyein97/bankapp`                    | The name of the docker image.                             |
| `TAG`             | Value from `DOCKER_TAG` parameter      | The tag of the docker image.                               |
| `KUBE_NAMESPACE`  | `webapps`                              | The Kubernetes namespace for deployment.                |
| `SCANNER_HOME`    | SonarQube scanner path                  | The path to the SonarQube scanner installation. |

## Stages

1.  **Git Checkout**
    -   Clones the repository from GitHub.
2.  **Compile**
    -   Compiles the Java application using Maven.
3.  **Test**
    -   Runs unit tests (without execution).
4.  **Trivy FS Scan**
    -   Scans the local file system for security vulnerabilities.
5.  **SonarQube Analysis**
    -   Runs static code analysis using SonarQube.
6.  **SonarQube Quality Gate**
    -   Waits for SonarQube's quality gate approval.
7.  **Build Application**
    -   Packages the application as a JAR file.
8.  **Publish Artifact to Nexus**
    -   Deploys the application artifact to Nexus repository.
9.  **Docker Build**
    -   Builds the Docker image for the application.
10. **Trivy Image Scan**
    -   Scans the Docker image for vulnerabilities.
11. **Docker Push Image**
    -   Pushes the built image to Docker Hub.
12. **Deploy MySQL Deployment and Service**
    -   Ensures MySQL database is deployed in Kubernetes.
13. **Deploy SVC-APP**
    -   Deploys the Kubernetes service for the application.
14. **Deploy to Kubernetes**
    -   Deploys the application to the specified blue or green environment.
15. **Switch Traffic Between Blue & Green**
    -   Switches traffic to the newly deployed environment if `SWITCH_TRAFFIC` is enabled.
16. **Verify Deployment**
    -   Verifies the deployment status and the running service.

## Deployment Strategy

-   The pipeline alternates between blue and green environments.
-   Traffic is only switched after a successful deployment and verification.
-   If a failure occurs, the previous environment remains active.

## Usage

1.  Configure Jenkins with required credentials:
    -   Git credentials (`git-cred`)
    -   SonarQube credentials (`To_sonar`)
    -   Docker registry credentials (`docker-cred`)
    -   Kubernetes secret (`k8s-secret`)
2.  Run the pipeline with desired parameters.
3.  Monitor logs and SonarQube quality gate status.
4.  If enabled, traffic will switch to the newly deployed environment.

## Troubleshooting

-   **Build fails at Maven steps:** Ensure Maven is installed and configured correctly.
-   **SonarQube scan issues:** Check SonarQube server connectivity and configurations.
-   **Docker build failures:** Verify Dockerfile correctness and Docker service status.
-   **Kubernetes deployment errors:** Validate Kubernetes cluster connectivity and YAML configurations.

## Conclusion

This pipeline enables efficient blue-green deployments, ensuring zero-downtime releases while maintaining security and code quality standards. Modify the pipeline as needed to fit project-specific requirements.