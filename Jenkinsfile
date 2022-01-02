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
                dockerfile {
                filename 'Dockerfile'
                reuseNode true
                } 
            }
            steps {
                script {
                    sh """
                    helm lint server/ && \
                    helm lint tenant-manager/ && \
                    helm lint enforcer/ && \
                    helm lint gateway/ --set "db.external.password=Test123" && \
                    helm lint aqua-quickstart/ && \
                    helm lint kube-enforcer/  --set "aquaSecret.kubeEnforcerToken=Test123" && \
                    helm lint cyber-center/ && \
                    helm lint cloud-connector/ && \
                    helm repo list
                    """
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
                    sh """
                    echo $currentBuild.number && echo $JOB_NAME \
                    helm repo add aqua-dev https://helm-dev.aquaseclabs.com/ && \
                    helm repo list && \
                    helm cm-push --help && \
                    job= echo $JOB_NAME | cut -f2 -d"/"
                    helm cm-push tenant-manager/ aqua-dev --version="${job}-${currentBuild.number}"
                    """
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
