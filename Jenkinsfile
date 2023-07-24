pipeline {
    agent any
    tools{
        maven 'Maven-3.9.3'
    }
    triggers {
       // poll repo every 2 minute for changes
       // pollSCM('H/2 * * * *')
        githubPush()
   }
    environment {
        GIT_REPO = 'git@github.com:samin-irtiza-bjit/Final_Project_LMS.git'
        IMAGE_NAME= "saminbjit/sparklms"
        IMAGE_TAG= "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Git Pull') {
            steps {
                git branch: 'main', credentialsId: 'github-key', url: env.GIT_REPO
                // git branch: 'main', url: env.GIT_REPO 
            }
        }
        
        stage('Build Application'){
            steps{
                //sh 'chmod +x mvnw'
                sh 'mvn clean install'
            }
        }
        stage('Build Image') {
            steps{
                script{
                    new_image=docker.build("${env.IMAGE_NAME}")
                }
            }
        }
        stage('Push Image to DockerHub') {
            steps {
                script{
                   
                    withDockerRegistry([ credentialsId: "dockerhub-login", url: "" ]) {
                        new_image.push("${env.IMAGE_TAG}")
                        new_image.push('latest')
                    }
                }
            }
        }
        stage('Cleanup & Deployment'){
            parallel {
                stage('Docker Cleanup') {
                    steps {
                        sh "docker rmi -f ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                        sh "docker rmi -f ${env.IMAGE_NAME}:latest"
                        sh 'docker system prune -f'
                    }
                }
                stage('Kubernetes Deployment'){
                    steps {
                        kubeconfig(caCertificate: 'f', credentialsId: 'kubeconfig', serverUrl: '') {
                            sh 'kubectl delete -f mysql.yml 2>/dev/null || true'
                            sh 'kubectl delete -f sparklms.yml 2>/dev/null || true'
                            sh 'kubectl apply -f mysql.yml && sleep 10'
                            sh 'kubectl apply -f sparklms.yml'
                        }
                    }
                }
            }
                // kubeconfig(caCertificate: 'f', credentialsId: 'kubeconfig', serverUrl: '') {
                //     sh 'kubectl delete -f mysql.yml 2>/dev/null || true'
                //     sh 'kubectl delete -f sparklms.yml 2>/dev/null || true'
                //     sh 'kubectl apply -f mysql.yml && sleep 10'
                //     sh 'kubectl apply -f sparklms.yml'
                // }
            
        }
    }
    post { 
        always { 
            cleanWs()
        }
    }
}
