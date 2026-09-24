#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@jenkins-shared-lib-terrafrom-project', retriever: modernSCM(
  [$class: 'GitSCMSource',
  remote: 'https://github.com/Omars105/Jenkins-shared-library.git',
  credentialsId: 'Github-jenkins-pat'
  ]
)

pipeline {   
  agent any
  tools {
    maven 'maven-3.9'
  }
  environment {
    IMAGE_NAME = 'omar1015/java-maven-app:java-maven-2.0'
    BRANCH_NAME = 'feature/terraform-jenkins-project'
  }
  stages {
    stage("build app") {

      steps {
        script {
          echo 'building application jar...'
          buildJar()
        }
      }
    }
    stage("build image") {
      steps {
        script {
          echo 'building docker image...'
          buildImage(env.IMAGE_NAME)
          dockerLogin()
          dockerPush(env.IMAGE_NAME)
        }
      }
    }
    stage("provision server"){
      environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws_secret_access_key_id')
        TF_VAR_env_prefix = 'test'
      }
    steps{
      script{
        dir("terraform") {
          sh "terraform init"           
          sh "terraform apply --auto-approve"   
          EC2_PUBLIC_IP = sh(script:"terraform output -raw ec2-public-ip", returnStdout: true).trim() 
          
        }
      }
    }
    }
    stage("deploy") {
      environment {
        DOCKER_CREDS = credentials('omar-dockerhub-repo')
      }
      steps {
        script {
          echo "waiting for EC2 to be ready"
          sleep(time:60, unit:"SECONDS")
          echo 'deploying docker image to EC2...'
          
          def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
          def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

          sshagent(['server-ssh-key']) {
            sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
            sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
            sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
          }
        }
      }
    }               
  }
}
