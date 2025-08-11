@Library('aqua-pipeline-lib@lihiz_helm_jenkins') _

def charts = ['server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector', 'scanner', 'tenant-manager', 'codesec-agent']
def deployCharts = ['server', 'kube-enforcer', 'enforcer', 'scanner', 'cyber-center', 'codesec-agent']

pipeline {
    agent {
        kubernetes kubernetesAgents.bottlerocket(size: '4xLarge', cloud: 'kubernetes', dind: 'True', capacityType: 'on-demand')
    }
    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
        disableConcurrentBuilds(abortPrevious: true)
    }
    stages {
        stage('Checkout and downloads') {
            steps {
                script {
                    checkout scm
                    sh "wget -q https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz && tar xf kubeval-linux-amd64.tar.gz && mv kubeval /usr/local/bin"
                    sh "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
                    sh "helm plugin install https://github.com/chartmuseum/helm-push.git"
                }
            }
        }
        stage("Helm dependency update") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Helm dependency updates: ${chart}") {
                                sh "helm dependency update ${chart}/"
                            }
                        }]
                    }
                }
            }
        }
        stage("Helm lint") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Helm Lint ${chart}") {
                                helmBasic.lint(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Helm template") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Helm template ${chart}") {
                                helmBasic.template(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Trivy scan") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Trivy scan ${chart}") {
                                helmBasic.trivyScan(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Creating Kind Cluster") {
            steps {
                script {
                    // Install kind
                    sh '''
                    ARCH=$(uname -m); [ "$ARCH" = "x86_64" ] && ARCH=amd64
                    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/latest/kind-$(uname -s | tr '[:upper:]' '[:lower:]')-$ARCH"
                    chmod +x ./kind
                    sudo mv ./kind /usr/local/bin/kind
                    '''
                    // Create the kind cluster
                    sh "kind create cluster --name ${env.BUILD_NUMBER}"
                    // Set kubeconfig context
                    sh "kubectl config current-context"
                    // Check the kind deployment
                    sh "kubectl get nodes"
                }
            }
        }

        stage("Installing Helm") {
            steps {
                script {
                    helmBasic.installHelm()
                }
            }
        }
        stage("Deploy charts") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "aquasec-acr-pull-creds", passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
                        sh script: "echo \$PASSWORD | docker login --username \$USER --password-stdin aquasec.azurecr.io"
                    }
                    parallel deployCharts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Deploy ${chart}") {
                                helmBasic.install(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Validate charts") {
            steps {
                script {
                    parallel deployCharts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Validate ${chart}") {
                                helmBasic.validate(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Push charts") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Push ${chart}") {
                                helmBasic.push(chart, "dev")
                            }
                        }]
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                try {
                    sh "kind delete cluster --name ${env.BUILD_NUMBER}"
                } catch (err) {
                    sh "kind delete cluster --name ${env.BUILD_NUMBER}"
                }
                sh "docker system prune -f"
            }
        }
    }
}
