//@Library('aqua-pipeline-lib@master')_

pipeline {
    agent {
        dockerfile {
            label 'automation_slaves'
    }
    }
    //options {
    //    ansiColor('xterm')
    //    timestamps()
    //    skipStagesAfterUnstable()
    //    skipDefaultCheckout()
    //    buildDiscarder(logRotator(daysToKeepStr: '7'))
    //}
    stages {
        //stage('Checkout') {
        //    steps {
        //        script {
        //            deployment.clone branch: "master"
        //            checkout([
        //                    $class: 'GitSCM',
        //                    branches: scm.branches,
        //                    doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
        //                    extensions: [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: 'cloudformation/']]],
        //                                [$class: 'RelativeTargetDirectory', relativeTargetDir: 'cloudformation']],
        //                    userRemoteConfigs: scm.userRemoteConfigs
        //            ])
        //            dir("cloudformation"){
        //                sh "mv cloudformation/* . && rm -rf cloudformation"
        //            }
        //        }
        //    }
        //}

        stage("Helm Lint Git") {
            steps {
                script {
                    //def deploymentImage = docker.build("deployment-image")
                    //deploymentImage.inside("-u root") {
                    //    log.info "Installing aqaua-deployment  python package"
                    //    sh """
                    //    aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner 934027998561
                    //    pip install aqua-deployment
                    //    """
                    //    log.info "Finished to install aqaua-deployment python package"
                    //    cloudformation.run  publish: false
                    //}
                    sh """
                    rm -r aqua-helm
                    git clone https://github.com/KoppulaRajender/aqua-helm.git
                    cd aqua-helm
                    git checkout 6.2_jenkins
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
        stage("Helm Lint HelmRepo") {
            steps {
                script {
                    sh """
                    helm repo add aqua-helm https://helm.aquasec.com && \
                    helm lint aqua-helm/server && \
                    helm lint aqua-helm/tenant-manager/ && \
                    helm lint aqua-helm/enforcer/ && \
                    helm lint aqua-helm/gateway/ && \
                    #helm lint aqua-helm/aqua-quickstart/ && \
                    helm lint aqua-helm/kube-enforcer/  --set "aquaSecret.kubeEnforcerToken=Test123" && \
                    #helm lint aqua-helm/kube-enforcer-starboard/ --set "aquaSecret.kubeEnforcerToken=Test123"
                    """
                }
            }
        }
    }
//    post {
//        always {
//            script {
//                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
//            }
//        }
//    }
}