@Library('aqua-pipeline-lib@master')_

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
                docker { 
                    image 'alpine:latest' 
                    args '-u root'
                    reuseNode true
                    }
            }
            steps {
                script {
                    sh 'apk add --no-cache ca-certificates git && wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz && tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
                    sh 'helm lint server/ tenant-manager/ enforcer/ gateway/ aqua-quickstart/ kube-enforcer/ cyber-center/ cloud-connector/'
                }
            }
        }
        stage("Kubeval checkigs") {
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
                        helm template server/ --set global.platform=k8s,imageCredentials.username=test,imageCredentials.password=test > server.yaml && kubeval server.yaml --strict --exit-on-error
                    '''
                }
            }
        stage("Creating k3s") {
            steps {
                sh 'curl -sfL https://get.k3s.io | sh -'
                sleep(45)
                echo 'k3s installed'
                sh 'sh /usr/local/bin/k3s-uninstall.sh'
                sleep(30)
                echo 'k3s uninstalled'
            }
        }
        stage("Pushing Helm chart to dev repo") {
            agent {
                docker {
                    image 'alpine:latest'
                    args '-u root'
                    reuseNode true
                    }
            }
            steps {
                script {
                    sh 'apk add --no-cache ca-certificates git tar && tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
                    sh 'helm plugin install https://github.com/chartmuseum/helm-push.git'
                    sh 'helm plugin list'
                    sh 'helm repo add aqua-dev https://helm-dev.aquaseclabs.com/'
                    sh 'helm repo list'
                    sh 'helm cm-push server/  aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push tenant-manager/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push enforcer/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push gateway/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push aqua-quickstart/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push kube-enforcer/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push cyber-center/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                    sh 'helm cm-push cloud-connector/ aqua-dev --version="6.5-${JOB_NAME##*/}-${BUILD_NUMBER}"'
                }
            }
        }
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
