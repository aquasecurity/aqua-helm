
@Library('aqua-pipeline-lib@master')_

pipeline {
    agent {
        dockerfile {
            label 'automation_slaves'
        }
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
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions: scm.extensions + [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: 'aqua-helm/']]]],
                        userRemoteConfigs: scm.userRemoteConfigs
                ])
            }
        }
        stage("Helm Lint Git") {
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
