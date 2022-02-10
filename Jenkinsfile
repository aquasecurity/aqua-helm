@Library('aqua-pipeline-lib@master')_
import com.aquasec.deployments.orchestrators.*

def orchestrator = new K3s(this)
def namespace = "aqua"
def registry = "registry.aquasec.com"
platform = "k3s"
def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector' ]
pipeline {
    agent {
        label 'deployment_slave'
    }

    environment {
//        AQUASEC_AZURE_ACR_PASSWORD = credentials('aquasecAzureACRpassword')
//        AFW_SERVER_LICENSE_TOKEN = credentials('aquaDeploymentLicenseToken')
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
        stage ("Generate parallel stages") {
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
                    kubectl.createNamespace(namespace)
                    kubectl.createDockerRegistrySecret("registry.aquasec.com", namespace)
                }
            }
        }
        stage("Deploying Aqua Charts") {
            steps {
                parallel(
                        server: {
                            script {
                                helm.install("server", namespace, registry, platform)
                            }
                        },
                        enforcer: {
                            script {
                                helm.install("enforcer", namespace, registry, platform)
                            }
                        },
                        "kube-enforcer": {
                            script {
                                helm.install("kube-enforcer", namespace, registry, platform)
                            }
                        },
                        scanner: {
                            script {
                                helm.install("scanner", namespace, registry, platform)
                            }
                        }
                )
            }
        }
        stage("Validating Aqua Charts") {
            steps {
                script {
                    helm.getPodsState(namespace)
                    log.info "checking all pods are running or not"
                    def bs = "kubectl get pods -n aqua  | awk '{print \$3}' |grep -v STATUS | grep -v Running"
                    def status = sh (returnStatus:true ,script: bs)
                    log.info "checking Server endpoint"
                    helm.getScvStatus(namespace)
                }
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