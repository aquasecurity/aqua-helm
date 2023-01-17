@Library('aqua-pipeline-lib@master')_
import com.aquasec.deployments.orchestrators.*

def orchestrator = new OrcFactory(this).GetOrc()
def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector', 'scanner', 'tenant-manager', 'codesec-agent' ]
def debug = false

pipeline {
    agent {
        label 'deployment_slave'

    }
    environment {
        ROOT_CA = credentials('deployment_ke_webook_root_ca')
        SERVER_CERT = credentials('deployment_ke_webook_crt')
        SERVER_KEY = credentials('deployment_ke_webook_key')
        AFW_SERVER_LICENSE_TOKEN = credentials('aquaDeploymentLicenseToken')
        DEPLOY_REGISTRY = "aquasec.azurecr.io"
        AQUADEV_AZURE_ACR_PASSWORD = credentials('aquadevAzureACRpassword')
        AUTH0_CREDS = credentials('auth0Credential')
        VAULT_TERRAFORM_SID = credentials('VAULT_TERRAFORM_SID')
        VAULT_TERRAFORM_SID_USERNAME = "$VAULT_TERRAFORM_SID_USR"
        VAULT_TERRAFORM_SID_PASSWORD = "$VAULT_TERRAFORM_SID_PSW"
        VAULT_TERRAFORM_RID = credentials('VAULT_TERRAFORM_RID')
        VAULT_TERRAFORM_RID_USERNAME = "$VAULT_TERRAFORM_RID_USR"
        VAULT_TERRAFORM_RID_PASSWORD = "$VAULT_TERRAFORM_RID_PSW"
        ENV_PLATFORM = "k3s"
    }
    parameters {
        string(name: 'AUTOMATION_BRANCH', defaultValue: 'master', description: "Automation branch for MSTP tests", trim: true)
    }
    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
        lock("k3s")
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
                        sh "helm dependency update kube-enforcer/"
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
        stage("updating consul") {
            steps {
                script {
                    helm.updateConsul("create")
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
                    kubectl.createNamespace create: "yes"
                    kubectl.createDockerRegistrySecret create: "yes", registry: env.DEPLOY_REGISTRY
                }
            }
        }
        stage("Deploying Aqua Charts") {
            failFast true
            steps {
                script {
                    def parallelStagesMap = [:]
                    def tmpCharts = [ 'server', 'kube-enforcer', 'enforcer', 'scanner', 'tenant-manager', 'cyber-center' ]
                    tmpCharts.eachWithIndex { item, index ->
                        parallelStagesMap["${index}"] = helm.generateDeployStage(index, item)
                    }
                    parallel parallelStagesMap
                }
            }
        }
        stage("Running Mstp tests") {
            steps {
                script {
                    helm.runMstpTests debug: debug, afwImage: params.AUTOMATION_BRANCH
                }
            }
        }
        stage("Pushing Helm chart to dev repo")
                {
            steps {
                script {
                    docker.image('alpine:latest').inside("-u root") {
                        helm.pushPreparation env: "dev"
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
                helm.updateConsul("delete")
                orchestrator.uninstall()
                echo "k3s & server chart uninstalled"
                helm.removeDockerLocalImages()
                cleanWs()
                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: 'deployments@aquasec.com'
            }
        }
    }
}