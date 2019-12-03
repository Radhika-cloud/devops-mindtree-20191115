node {
    
stage('Git CheckOut') {    
git url: 'https://github.com/Radhika-cloud/devops-mindtree-20191115.git'
}


def project_path = "atmosphere/spring-boot-samples/spring-boot-sample-atmosphere"
dir(project_path) {

stage('Clean Old Packages') {
sh label: 'Clean', script: 'mvn clean'
}
stage('Maven Compile') {
sh label: 'Comile', script: 'mvn compile'
}
stage('Maven Test') {
sh label: 'Testing', script: 'mvn test'
}

stage('SonarQube analysis') {
    withSonarQubeEnv(credentialsId: 'Sonar-secret-text', installationName: 'SonarQube') { // You can override the credential to be used
      sh 'mvn sonar:sonar'
    }            
}

stage('Maven Package') {
sh label: 'Testing', script: 'mvn package'
}

stage('Jfrog Artifacory'){
    script{
        def server = Artifactory.server 'JFrog-Artifactory'
        def uploadSpec = """{
             "files": [            {
                 "pattern": "**/*.jar",
                "target": "demo_301_pipeline"}]
         }"""
        server.upload(uploadSpec)
    }
}

stage('Archive Package') {
archive 'target/*.jar'
}

stage('Deploy Code info Docker Env.') {
sh label: 'Docker', script: 'docker-compose up -d --build'
}
   
stage('Geting Ready For Ansible') {
sh label: 'Docker', script: 'cp -rf target/*.jar ../../../terraform/ansible/templates/atmosphere-v1.jar'
sh label: 'Jenkins', script: "echo '<h1> TASK BUILD ID: ${env.BUILD_DISPLAY_NAME}</h1>' > ../../../terraform/ansible/templates/jenkins.html"
}   
    
stage('Deploy to Prod.') {
def project_path_1 = "../../../terraform"
dir(project_path_1) {    
sh label: 'terraform', script: '/bin/terraform  init'
sh label: 'terraform', script: '/bin/terraform  apply -input=false -auto-approve'
}   
}   
}    
}
