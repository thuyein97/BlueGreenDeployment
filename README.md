# Jenkins DevSecOps GitOps Pipeline

An **end-to-end DevSecOps CI/CD pipeline** implemented using **Jenkins**, following **GitOps principles** with **Helm and Argo CD**.

This repository demonstrates how to build, scan, package, containerize, and deploy a Java application securely into Kubernetes with **security gates enforced at multiple stages**.

---

## 🚀 What This Project Demonstrates

- CI/CD implemented as **Pipeline as Code (Jenkinsfile)**
- **Shift-left security** using SAST and container scanning
- **Artifact management** with Nexus
- **Container security** using Trivy
- **GitOps-based deployment** using Helm + Argo CD
- Kubernetes deployment including application and database (MySQL)

This project is designed for **learning, portfolio, and interview demonstration purposes**, while still following **real-world best practices**.

---

## 🧱 Architecture Overview

```
Developer → GitHub → Jenkins CI
                    ├─ Maven Build & Tests
                    ├─ SonarQube (Quality Gate)
                    ├─ Trivy (FS & Image Scan)
                    ├─ Nexus (Artifact Repo)
                    ├─ Docker Build & Push (GHCR)
                    └─ GitOps Update (Helm values)

GitHub (Helm Repo) → Argo CD → Kubernetes Cluster
                                    ├─ BankApp Deployment
                                    └─ MySQL Deployment
```

---

## 🔐 Security Controls (DevSecOps)

| Stage | Tool | Purpose |
|-----|------|--------|
| Code Quality & SAST | SonarQube | Enforces quality gates before packaging |
| Filesystem Scan | Trivy FS | Detects vulnerabilities in source & dependencies |
| Image Scan | Trivy Image | Blocks vulnerable container images |
| Artifact Integrity | Nexus | Secure artifact storage |

> 🚫 Pipeline fails automatically on **HIGH or CRITICAL** vulnerabilities.

---

## 🛠️ Tech Stack

- **CI/CD**: Jenkins (Declarative Pipeline)
- **Build Tool**: Maven
- **Language**: Java
- **Code Quality**: SonarQube
- **Security Scanning**: Trivy
- **Artifact Repository**: Nexus
- **Containerization**: Docker
- **Registry**: GitHub Container Registry (GHCR)
- **Orchestration**: Kubernetes (Minikube)
- **GitOps**: Helm + Argo CD

---

## 📁 Repository Structure

```
.
├── Jenkinsfile
├── helm/
│   └── bankapp/
│       ├── templates/
│       └── values.yaml
├── mysql-ds.yml
├── Dockerfile
├── pom.xml
└── README.md
```

---

## 🔄 Pipeline Stages

1. **Git Checkout**
2. **Compile** (Maven)
3. **Unit Tests**
4. **Trivy Filesystem Scan**
5. **SonarQube Analysis**
6. **SonarQube Quality Gate**
7. **Package Application**
8. **Publish Artifact to Nexus**
9. **Docker Image Build**
10. **Trivy Image Scan**
11. **Docker Image Push (GHCR)**
12. **Deploy MySQL (Demo Purpose)**
13. **Update Helm Values (GitOps)**
14. **Argo CD Sync to Kubernetes**

---

## 🏷️ Image Tagging Strategy

Docker images are tagged using:

```
<short-git-sha>-<jenkins-build-number>
```

Example:
```
a3f9c2b-42
```

### Benefits
- Full traceability to Git commit
- Guaranteed uniqueness
- Easy rollback in GitOps workflows

---

## 🔁 GitOps Workflow (Argo CD)

1. Jenkins updates the image tag in `helm/bankapp/values.yaml`
2. Changes are committed back to GitHub
3. Argo CD detects the change
4. Argo CD syncs the application to Kubernetes

> 🚀 No direct `kubectl apply` for application deployment — Git is the source of truth.

---

## 🧪 MySQL Deployment Note

MySQL deployment is included **only for demonstration completeness**.

In real production environments:
- Databases are provisioned separately
- CI pipelines do **not** manage stateful infra directly

---

## 📌 Jenkins Pipeline Best Practices Used

- Declarative pipeline syntax
- Pipeline-level options:
  - Timestamps
  - Disabled concurrent builds
  - Build retention policy
- Automated cleanup (`docker system prune`)
- Security gates enforced
- GitOps-based continuous delivery

---

## ▶️ How to Run (High Level)

1. Set up Jenkins with required plugins
2. Configure credentials:
   - GitHub
   - GHCR
   - Nexus
   - SonarQube
   - Kubernetes
3. Configure tools in Jenkins:
   - Maven
   - Sonar Scanner
4. Create Jenkins pipeline job pointing to this repo
5. Run the pipeline 🚀

---

## 📣 Use Case

This repository is suitable for:
- DevOps / DevSecOps portfolios
- Interview demonstrations
- Learning Jenkins + GitOps + security pipelines

---

## 👤 Author

**Thu Yein Tin**  
DevOps / Cloud Engineer

---

## ⭐ If You Found This Useful

Please ⭐ star the repository and feel free to fork or improve it.

Happy building! 🚀

