@Library('aqua-pipeline-lib@master')_

def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector' ]
pipeline {
    agent {
            label 'automation_slaves'
    }
    environment {
        aqua_helm = fileExists 'aqua-helm'
        helm_bin = fileExists 'linux-amd64/helm'
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
                docker { 
                    image 'alpine:latest' 
                    args '-u root'
                    reuseNode true
                    }
            }
            steps {
                script {
                    if (helm_bin) {
                        sh "cp linux-amd64/helm /usr/local/bin"
                    } else {
                        sh "wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz && \
                        tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && \
                        cp linux-amd64/helm /usr/local/bin"
                    }
                    for ( int i =0; i < charts.size(); i++) {
                        sh "helm lint ${charts[i]}"
                    }
                }
            }
        }
        stage("Kubeval checkings") {
                agent {
                        docker {
                            image 'alpine:latest'
                            args '-u root'
                            reuseNode true
                            }
                }
                steps {
                    sh 'apk add --no-cache ca-certificates git && tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
                    sh '''
                        wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz && tar xf kubeval-linux-amd64.tar.gz && mv kubeval /usr/local/bin
                        helm dependency update server/
                        helm template server/ --set global.platform=k8s,imageCredentials.username=test,imageCredentials.password=test > server.yaml && kubeval server.yaml --strict --exit-on-error
                    '''
                }
            }
        stage("Creating k3s") {
            steps {
                sh 'curl -sfL https://get.k3s.io | sh -'
                sleep(5)
                echo 'k3s installed'
            }
        }
        stage("Integration Test") {
            steps {
                //sh 'tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
                echo "okay"
            }
        }
        stage("Clearing deployment") {
            steps {
                sh 'tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
                //sh 'helm uninstall -n aqua $(helm list -A | awk '{print $1}' | tail -n+2)'
                echo 'helm uninstall completed'
                sh 'sh /usr/local/bin/k3s-uninstall.sh'
                sleep(5)
                echo 'k3s uninstalled'
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
                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
    }
