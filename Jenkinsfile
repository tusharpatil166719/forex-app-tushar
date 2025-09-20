node {
    // Parameters for user input
    
    properties([
        parameters([
            string(name: 'AMOUNT', defaultValue: '1000', description: 'Amount in INR'),
            choice(name: 'CURRENCY', choices: ['USD', 'EUR', 'AED', 'GBP', 'JPY'], description: 'Target currency')
        ])
    ])

    stage('Checkout') {
        checkout scm
    }
    stage('Setup Maven') {
        // Get the installed Maven path by tool name
        def mvnHome = tool name: 'Default', type: 'hudson.tasks.Maven$MavenInstallation'
        env.PATH = "${mvnHome}/bin:${env.PATH}"
        echo "Using Maven at: ${mvnHome}"
    }


    stage('Build') {
        sh 'mvn clean compile'
    }

    stage('Test & Coverage') {
        sh 'mvn test jacoco:report'
        junit 'target/surefire-reports/*.xml'
        publishHTML(target: [
            reportDir: 'target/site/jacoco',
            reportFiles: 'index.html',
            reportName: 'Jacoco Coverage Report'
        ])
    }

    stage('Package') {
        sh 'mvn package -DskipTests'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
    }

    stage('Run Forex App') {
        sh "java -cp target/forex-app-1.0.0.jar com.example.forex.ForexConverter rates.csv ${params.AMOUNT} ${params.CURRENCY}"
    }

    stage('Copy files to Docker Host') {
        withCredentials([sshUserPrivateKey(credentialsId: 'ec2-user', keyFileVariable: 'KEY', usernameVariable: 'USERNAME')]) {
            sh '''
                scp -i ${KEY} -o StrictHostKeyChecking=no target/forex-app-1.0.0.jar rates.csv ec2-user@agent01:/tmp/workspace/pipeline/
            '''
        }
    }

    stage('Docker Build & Run') {
        node('agent01') {
            sh '''
              sudo docker build -t forex-app .
              sudo docker run --rm forex-app ${AMOUNT} ${CURRENCY}
            '''
        }
    }
}
