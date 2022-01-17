@Library('aqua-pipeline-lib@master')_

def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector' ]
def platforms = ['gke', 'openshift']
pipeline {
    agent {
            label 'automation_slaves'
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
        stage("Creating k3s") {
            steps {
                sh 'curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -'
                sleep(5)
                echo 'k3s installed'
            }
        }
        stage("Integration Test") {
            steps {
                sh '''
                    wget -q https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz
                    tar -zxvf helm-v3.7.2-linux-amd64.tar.gz
                    mkdir -pv local/bin
                    mv linux-amd64/helm local/bin/
                '''
                sh 'touch ./k3s.yaml && cp /etc/rancher/k3s/k3s.yaml ./k3s.yaml && export KUBECONFIG="./k3s.yaml"'
                sh 'echo $KUBECONFIG'
                sh 'kubectl get nodes -o wide'
                sh 'local/bin/helm list -A'
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
                sh 'sh /usr/local/bin/k3s-uninstall.sh'
                sleep(5)
                echo 'k3s uninstalled'
                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
    }
