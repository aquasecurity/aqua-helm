
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
                script {
                    sh """
                    pwd && \
                    ls -ltr
                    """
                }
                
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
                    rm -r aqua-helm
                    git clone https://github.com/aquasecurity/aqua-helm.git
                    cd aqua-helm
                    git checkout 5.3
                    helm lint server/ && \
                    helm lint tenant-manager/ && \
                    helm lint enforcer/ && \
                    helm lint gateway/ && \
                    helm lint aqua-quickstart/ && \
                    helm lint kube-enforcer/  --set "aquaSecret.kubeEnforcerToken=Test123" && \
                    helm lint kube-enforcer-starboard/ --set "aquaSecret.kubeEnforcerToken=Test123"
                    """
                }
            }
        }
    }
        
    //post {
    //    always {
    //        script {
    //            cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
    //        }
    //    }
    //}
}
