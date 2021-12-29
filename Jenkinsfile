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
                    helm lint cloud-connector/
                    """

                    sh"""
                    ls -ltr ./ && ls -ltr / && \
                    helm repo add aqua-dev https://helm-dev.aquaseclabs.com/ && \
                    helm cm-push server/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push tenant-manager/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push enforcer/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push gateway/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push aqua-quickstart/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push kube-enforcer/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push cyber-center/ aqua-dev --version="${currentBuild.number}" && \
                    helm cm-push cloud-connector/ aqua-dev --version="${currentBuild.number}"
                    """
                }
            }
        }
//        stage("Pushing Charts to aqua-dev repo") {
//            agent {
//                dockerfile {
//                    filename 'Dockerfile'
//                    reuseNode true
//                }
//            }
//            
//        }
    }

}
