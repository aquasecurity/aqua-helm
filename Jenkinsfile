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
                /*dockerfile {
                filename 'Dockerfile'
                args '-u root:sudo'
                reuseNode true
                } */
                docker { 
                    image 'alpine:latest' 
                    args '-u root'
                    reuseNode true
                    }
            }
            steps {
                script {
                    sh 'apk add --no-cache ca-certificates git && wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz && tar -zxvf helm-v3.7.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin'
                    sh ' ls -ltr'
                    sh """
                    helm lint server/ && \
                    helm lint tenant-manager/ && \
                    helm lint enforcer/ && \
                    helm lint gateway/ --set "db.external.password=Test123" && \
                    helm lint aqua-quickstart/ && \
                    helm lint kube-enforcer/  --set "aquaSecret.kubeEnforcerToken=Test123" && \
                    helm lint cyber-center/ && \
                    helm lint cloud-connector/
                    """
                    sh 'helm plugin install https://github.com/chartmuseum/helm-push.git'
                    sh 'helm plugin list'
                }
            }
        }
        stage("Pushing Helm chart to dev repo") {
            agent {
                dockerfile {
                filename 'Dockerfile'
                reuseNode true
                }
            }
            steps {
                script {
                    sh 'echo $currentBuild.number && echo $JOB_NAME'
                    sh 'helm repo add aqua-dev https://helm-dev.aquaseclabs.com/'
                    sh 'helm plugin install https://github.com/chartmuseum/helm-push.git'
                    sh 'helm repo list'
                    sh 'helm cm-push --help'
                    sh 'helm package tenant-manager/'
                    sh 'ls -ltr tenant-manager/'
                    sh 'helm push tenant-manager/ aqua-dev --version="${JOB_NAME}-${currentBuild.number}"'
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
