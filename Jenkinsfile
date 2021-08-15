//@Library('aqua-pipeline-lib@master')_

pipeline {
    //agent {
    //    dockerfile {
    //        label 'automation_slaves'
    //}
    agent { dockerfile true }
    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
    }
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

        stage("Create Runs") {
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
                    git clone https://github.com/KoppulaRajender/aqua-helm.git
                    cd aqua-helm
                    git checkout 6.2_jenkins
                    helm lint server/

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