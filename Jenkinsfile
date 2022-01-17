@Library('aqua-pipeline-lib@master')_

def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector' ]
def platforms = ['gke', 'openshift']
pipeline {
    agent {
        label 'automation_azure'
    }
    environment {
        AQUASEC_AZURE_ACR_PASSWORD = credentials('aquasecAzureACRpassword')
    }
    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
    }
    stages {
        stage('Checkout') {
            steps {
                checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: scm.userRemoteConfigs
                ])              
            }
        }
        stage("Helm Lint Git") {
            agent { 
                dockerfile {
                    filename 'Dockerfile'
                    reuseNode true
                    }
            }
            steps {
                script {
                    for ( int i=0; i < charts.size(); i++) {
                        sh "helm lint ${charts[i]}"
                    }
                }
            }
        }
        stage("Kubeval checkings") {
                agent {
                    dockerfile {
                        filename 'Dockerfile'
                        reuseNode true
                        }
                }
                steps {
                    script {
                        sh "helm dependency update server/"
                        for ( int i=0; i < charts.size(); i++) {
                            sh "helm template ${charts[i]}/ --set global.platform=k8s,platform=k8s,imageCredentials.username=test,imageCredentials.password=test,webhooks.caBundle=test,certsSecret.serverCertificate=test,certsSecret.serverKey=test,user=test,password=test > ${charts[i]}.yaml && \
                            kubeval ${charts[i]}.yaml --ignore-missing-schemas"
                        }
                    }
                }
            }
        stage("Creating K3s Cluster") {
            steps {
                sh 'curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -'
                sleep(3)
                echo 'k3s installed'
            }
        }
        stage("Deploying Aqua Charts") {
            steps {
                sh '''
                    wget -q https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz
                    tar -zxvf helm-v3.7.2-linux-amd64.tar.gz
                    mkdir -pv local/bin
                    mv linux-amd64/helm local/bin/
                '''
                sh 'cp /etc/rancher/k3s/k3s.yaml ~/.kube/config'
                sh 'export KUBECONFIG=~/.kube/config'
                sh 'kubectl get nodes -o wide && kubectl create namespace aqua'
                script {
                    log.info "installing server chart"
                    def TOKEN = sh script: "az acr login --name 'aquasec' --expose-token -o json", returnStdout: true
                    def exposedTokenJSON = readJSON text: "${TOKEN}"
                    sh "kubectl create secret -n aqua docker-registry aquasec-registry --docker-server=aquasec.azurecr.io  --docker-username=00000000-0000-0000-0000-000000000000  --docker-password=\\${exposedTokenJSON['accessToken']}\n"
                    sh "local/bin/helm upgrade --install --namespace aqua server server/ --set global.platform=k3s,gateway.service.type=LoadBalancer,imageCredentials.create=false,imageCredentials.name=aquasec-registry,imageCredentials.repositoryUriPrefix=aquasec.azurecr.io,gateway.imageCredentials.repositoryUriPrefix=aquasec.azurecr.io"
                    sh "local/bin/helm list -n aqua"
                }
                sleep(45)
                sh "kubectl get pods -n aqua && kubectl get svc -n aqua"
            }
        }
        stage("Validating") {
            parallel {
                stage("Validating pods state") {
                    steps {
                        script {
                            log.info "checking all pods are running or not"
                            def buildScript= "kubectl get pods -n aqua  | awk '{print \$3}' |grep -v STATUS | grep -v Running"
                            def rc = script.sh(script: buildScript, returnStatus: true)
                            if (rc == 0) {
                                log.warn("Found issues in aqua namespace")
                                script.sh("kubectl describe pods -n aqua >> describe_pods.log ")
                                script.archiveArtifacts "describe_pods.log"
                            }
                            else {
                                log.info("all pods are running")
                            }
                        }
                    }
                }
                stage("Validating Server endpoint") {
                    steps {
                        script {
                            sh "kubectl get svc -n aqua"
                        }
                    }
                }
            }
        }

//        stage("Pushing Helm chart to dev repo") {
//            agent {
//                docker {
//                    image 'alpine:latest'
//                    args '-u root'
//                    reuseNode true
//                    }
//            }
//            steps {
//                script {
//                    sh 'apk add --no-cache ca-certificates git tar && tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
//                    sh 'helm plugin install https://github.com/chartmuseum/helm-push.git'
//                    sh 'helm plugin list'
//                    sh 'helm repo add aqua-dev https://helm-dev.aquaseclabs.com/'
//                    sh 'helm repo list'
//                    sh 'helm cm-push server/  aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push tenant-manager/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push enforcer/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push gateway/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push aqua-quickstart/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push kube-enforcer/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push cyber-center/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                    sh 'helm cm-push cloud-connector/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
//                }
//            }
//        }
        }
    post {
        always {
            script {
                sh "local/bin/helm uninstall server -n aqua"
                sh "sh /usr/local/bin/k3s-uninstall.sh"
                echo "k3s & server chart uninstalled"
                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
    }
