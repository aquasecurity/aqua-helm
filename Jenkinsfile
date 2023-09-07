@Library('aqua-pipeline-lib@master') _
import com.aquasec.deployments.orchestrators.*

def orchestrator = new OrcFactory(this).GetOrc()
def charts = ['server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector', 'scanner', 'tenant-manager', 'codesec-agent']
def deployCharts = [ 'server', 'kube-enforcer', 'enforcer', 'scanner', 'cyber-center', 'codesec-agent' ]
def debug = false

pipeline {
    agent {
        label 'deployment_slave'
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
                checkout scm
            }
        }
        stage("Helm lint") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Helm Lint ${chart}") {
                                helmBasic.lint(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Helm template") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Helm template ${chart}") {
                                helmBasic.template(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Trivy scan") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Trivy scan ${chart}") {
                                helmBasic.trivyScan(chart)
                            }
                        }]
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
        stage("Update consul") {
            steps {
                script {
                    helmBasic.updateConsul("create")
                }
            }
        }
        stage("Installing Helm") {
            steps {
                script {
                    helmBasic.installHelm()
                    helmBasic.settingKubeConfig()
                }
            }
        }
        stage("Deploy charts") {
            steps {
                script {
                    parallel deployCharts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Deploy ${chart}") {
                                helmBasic.install(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Validate charts") {
            steps {
                script {
                    parallel deployCharts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Validate ${chart}") {
                                helmBasic.validate(chart)
                            }
                        }]
                    }
                }
            }
        }
        stage("Running Mstp tests") {
            steps {
                script {
                    helmBasic.runMstpTests debug: debug, afwImage: params.AUTOMATION_BRANCH
                }
            }
        }
        stage("Push charts") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Push ${chart}") {
                                helmBasic.push(chart)
                            }
                        }]
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                helmBasic.updateConsul("delete")
                orchestrator.uninstall()
                echo "k3s & server chart uninstalled"
                helmBasic.removeDockerLocalImages()
                cleanWs()
                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: 'deployments@aquasec.com'
            }
        }
    }
}