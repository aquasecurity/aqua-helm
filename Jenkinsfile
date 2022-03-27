@Library('aqua-pipeline-lib@deployment_helm')_
import com.aquasec.deployments.orchestrators.*

def orchestrator = new OrcFactory(this).GetOrc()
def charts = [ 'server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector', 'scanner', 'tenant-manager' ]


pipeline {
    agent {
        label 'deployment_slave'
    }
    environment {
        ROOT_CA = credentials('deployment_ke_webook_root_ca')
        SERVER_CERT = credentials('deployment_ke_webook_crt')
        SERVER_KEY = credentials('deployment_ke_webook_key')
        AFW_SERVER_LICENSE_TOKEN = credentials('aquaDeploymentLicenseToken')

        AQUADEV_AZURE_ACR_PASSWORD = credentials('aquadevAzureACRpassword')
        AUTH0_CREDS = credentials('auth0Credential')
        VAULT_TERRAFORM_SID = credentials('VAULT_TERRAFORM_SID')
        VAULT_TERRAFORM_SID_USERNAME = "$VAULT_TERRAFORM_SID_USR"
        VAULT_TERRAFORM_SID_PASSWORD = "$VAULT_TERRAFORM_SID_PSW"
        VAULT_TERRAFORM_RID = credentials('VAULT_TERRAFORM_RID')
        VAULT_TERRAFORM_RID_USERNAME = "$VAULT_TERRAFORM_RID_USR"
        VAULT_TERRAFORM_RID_PASSWORD = "$VAULT_TERRAFORM_RID_PSW"
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
        stage("updating conul") {
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
                    kubectl.createDockerRegistrySecret create: "yes"
                }
            }
        }
        stage("Deploying Aqua Charts") {
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
                    helm.runMstpTests test: "test"
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
                helm.removeDockerLocalImages()
                orchestrator.uninstall()
                helm.updateConsul("delete")
                echo "k3s & server chart uninstalled"
                cleanWs()
                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: 'deployments@aquasec.com'
            }
        }
    }
}