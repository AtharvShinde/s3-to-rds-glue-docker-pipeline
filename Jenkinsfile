pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t s3-to-rds-glue .'
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 010928211649.dkr.ecr.us-east-1.amazonaws.com
                docker tag s3-to-rds-glue:latest 010928211649.dkr.ecr.us-east-1.amazonaws.com/s3-to-rds-glue:latest
                docker push 010928211649.dkr.ecr.us-east-1.amazonaws.com/s3-to-rds-glue:latest
                '''
            }
        }
        stage('Deploy Resources with Terraform') {
            steps {
                sh '''
                terraform init
                terraform apply -auto-approve
                '''
            }
        }
    }
}
