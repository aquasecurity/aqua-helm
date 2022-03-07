@Library('aqua-pipeline-lib@deployment_helm')_
import com.aquasec.deployments.orchestrators.*

def orchestrator = new OrcFactory(this).GetOrc()
def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector' ]

pipeline {
    agent {
        label 'deployment_slave'
    }

    environment {
        ROOT_CA = credentials('deployment_ke_webook_root_ca')
        SERVER_CERT = credentials('deployment_ke_webook_crt')
        SERVER_KEY = credentials('deployment_ke_webook_key')
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
        stage ("Yamls Checking") {
            steps {
                script {
                    def deploymentImage = docker.build("helm", "-f Dockerfile .")
                    deploymentImage.inside("-u root") {
                        sh "helm dependency update server/"
                        def parallelStagesMap = [:]
                        charts.eachWithIndex { item, index ->
                            parallelStagesMap["${index}"] = helm.generateStage(index, item)
                        }
                        parallel parallelStagesMap
                    }
                }
            }
        }
        stage("Creating K3s Cluster") {
            steps {
                script {
                    orchestrator.install()
                }
            }
        }
        stage("Installing Helm") {
            steps {
                script {
                    helm.installHelm()
                    helm.settingKubeConfig()
                }
            }
        }
        stage ("preparation") {
            steps {
                script {
                    kubectl.createNamespace()
                    kubectl.createDockerRegistrySecret()
                }
            }
        }
        stage("Deploying Aqua Charts") {
            steps {
                parallel(
                        server: {
                            stage("install") {
                                steps {
                                    script {
                                        helm.install(chart = "server")
                                    }
                                }
                            }
                            stage("validate") {
                                steps {
                                    script {
                                        helm.validate(chart = "server")
                                    }
                                }
                            }
                        },
                        enforcer: {
                            stage("install") {
                                steps {
                                    script {
                                        helm.install(chart = "enforcer")
                                    }
                                }
                            }
                            stage("validate") {
                                steps {
                                    script {
                                        helm.validate(chart = "enforcer")
                                    }
                                }
                            }
                        },
                        "kube-enforcer": {
                            stage("install") {
                                steps {
                                    script {
                                        helm.install(chart = "kube-enforcer")
                                    }
                                }
                            }
                            stage("validate") {
                                steps {
                                    script {
                                        helm.validate(chart = "kube-enforcer")
                                    }
                                }
                            }
                        },
                        scanner: {
                            stage("install") {
                                steps {
                                    script {
                                        helm.install(chart = "scanner")
                                    }
                                }
                            }
                            stage("validate") {
                                steps {
                                    script {
                                        helm.validate(chart = "scanner")
                                    }
                                }
                            }
                        }
                )
            }
        }
        stage("Pushing Helm chart to dev repo") {
            steps {
                script {
                    docker.image('alpine:latest').inside("-u root") {
                        helm.pushPreparation()
                        def parallelStagesMap = [:]
                        charts.each {chart ->
                            parallelStagesMap[chart] = {
                                stage(chart) {
                                    helm.push(chart)
                                }
                            }
                        }
                        parallel parallelStagesMap
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                orchestrator.uninstall()
                echo "k3s & server chart uninstalled"
                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
}