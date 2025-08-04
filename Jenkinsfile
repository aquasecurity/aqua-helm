@Library('aqua-pipeline-lib@lihiz_helm_jenkins') _
import com.aquasec.deployments.orchestrators.*

def orchestrator = new OrcFactory(this).GetOrc()
def charts = ['server', 'kube-enforcer', 'enforcer', 'gateway', 'aqua-quickstart', 'cyber-center', 'cloud-connector', 'scanner', 'tenant-manager', 'codesec-agent']
// deployCharts = ['server', 'kube-enforcer', 'enforcer', 'scanner', 'cyber-center', 'codesec-agent']
def deployCharts = ['server']
def debug = false

pipeline {
    agent {
        kubernetes kubernetesAgents.devopsCommon(size: 'xLarge', cloud: 'kubernetes', dind: 'True')
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
                script {
                    log.info "hi"
                    //checkout scm
                    //sh "wget -q https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz && tar xf kubeval-linux-amd64.tar.gz && mv kubeval /usr/local/bin"
                    //sh "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
                }
            }
        }
//         stage("Helm lint") {
//             steps {
//                 script {
//                     parallel charts.collectEntries { chart ->
//                         ["${chart}": {
//                             stage("Helm Lint ${chart}") {
//                                 helmBasic.lint(chart)
//                             }
//                         }]
//                     }
//                 }
//             }
//         }
//         stage("Helm template") {
//             steps {
//                 script {
//                     parallel charts.collectEntries { chart ->
//                         ["${chart}": {
//                             stage("Helm template ${chart}") {
//                                 helmBasic.template(chart)
//                             }
//                         }]
//                     }
//                 }
//             }
//         }
//         stage("Trivy scan") {
//             steps {
//                 script {
//                     parallel charts.collectEntries { chart ->
//                         ["${chart}": {
//                             stage("Trivy scan ${chart}") {
//                                 helmBasic.trivyScan(chart)
//                             }
//                         }]
//                     }
//                 }
//             }
//         }
        stage("Creating K3s Cluster") {
            steps {
                script {
                    sh "curl -sfL https://github.com/k3s-io/k3s/releases/latest/download/k3s -o /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s"
                    sh "nohup k3s server --snapshotter=native > /tmp/k3s.log 2>&1 &"
                    sleep(10)
                    sh "k3s kubectl get nodes"
                    sh "k3s kubectl get sa -A"
                    //error "byush"
                }
            }
        }
//         stage("Update consul") {
//             steps {
//                 script {
//                     helmBasic.updateConsul("create")
//                 }
//             }
//         }
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
                    sleep(3000)
//                     sh "k3s kubectl get sa -A"
//                     sh "kubectl config current-context"
//                     sh "kubectl config get-contexts"
//                     sh "echo \$KUBECONFIG"
//                     sh "helm list -A"
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
//         stage("Running Mstp tests") {
//             steps {
//                 script {
//                     //helmBasic.runMstpTests debug: debug, afwImage: params.AUTOMATION_BRANCH
//                     print "Running Mstp tests"
//                 }
//             }
//         }
        stage("Push charts") {
            steps {
                script {
                    parallel charts.collectEntries { chart ->
                        ["${chart}": {
                            stage("Push ${chart}") {
                                helmBasic.push(chart, "dev")
                            }
                        }]
                    }
                }
            }
        }
    }
//     post {
//         always {
//             script {
//                 //helmBasic.updateConsul("delete")
//                 //orchestrator.uninstall()
//                 //echo "k3s & server chart uninstalled"
//                 //helmBasic.removeDockerLocalImages()
//                 //cleanWs()
//                 notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: 'deployments@aquasec.com'
//             }
//         }
//     }
}