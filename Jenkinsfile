#!/usr/bin/env groovy

def z = new contiamo.Methods()

z.setEnvVars()
echo env.BuildImageRegistry
def label = "jenkins-job-foodmartt-${env.BranchLower}"

podTemplate(cloud: "${env.K8sCloud}", label: label, serviceAccount: "jenkins", nodeSelector: "group=pantheon",containers: [
  containerTemplate(name: 'utils', image: "contiamo/base-utils:1.11.4-v0.0.1-156-g8dd2413", ttyEnabled: true, privileged: true, resourceRequestMemory: "8Gi")
  ],
  volumes: [
      hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
      secretVolume(secretName: 'jenkins-git-credentials', mountPath: '/home/jenkins/git')
  ],
  envVars: [
    envVar(key: 'GIT_AUTHOR_EMAIL', value: 'jenkins-x@googlegroups.com'),
    envVar(key: 'GIT_AUTHOR_NAME', value: 'jenkins-x-bot'),
    envVar(key: 'GIT_COMMITTER_EMAIL', value: 'jenkins-x@googlegroups.com'),
    envVar(key: 'GIT_COMMITTER_NAME', value: 'jenkins-x-bot'),
    envVar(key: 'JENKINS_URL', value: 'http://jenkins:8080'),
    envVar(key: 'XDG_CONFIG_HOME', value: '/home/jenkins'),
    envVar(key: 'HANA_HOST', value: 'foodmart-hana-connect'),
    envVar(key: 'HANA_PORT', value: '39013'),
    envVar(key: 'HANA_SCHEMA', value: 'SYSTEM'),
    envVar(key: 'HANA_USER', value: 'SYSTEM'),
    envVar(key: 'MYSQL_HOST', value: '172.25.224.3'),
    envVar(key: 'ORACLE_HOST', value: 'localhost'),
    envVar(key: 'ORACLE_PORT', value: '1521'),
    envVar(key: 'ORACLE_USER', value: 'SYSTEM'),
    envVar(key: 'TERADATA_HOST', value: 'prod16.9oi.org'),
    envVar(key: 'TERADATA_PORT', value: '10250'),
    envVar(key: 'DB2_HOST', value: 'localhost'),
    secretEnvVar(key: 'DB2INST1_PASSWORD', secretName: 'foodmart-db2-creds', secretKey: 'password'),
    secretEnvVar(key: 'DB2_USERNAME', secretName: 'foodmart-db2-creds', secretKey: 'username'),
    secretEnvVar(key: 'SLACK_WEBHOOK_URL', secretName: 'slackwebhook', secretKey: 'url'),
    secretEnvVar(key: 'HANA_PASSWORD', secretName: 'foodmart-hana-creds', secretKey: 'password'),
    secretEnvVar(key: 'MYSQL_USER', secretName: 'cloudsql-db-credentials', secretKey: 'username'),
    secretEnvVar(key: 'MYSQL_PASSWORD', secretName: 'cloudsql-db-credentials', secretKey: 'password'),
    secretEnvVar(key: 'ORACLE_PWD', secretName: 'foodmart-oracle-credentials', secretKey: 'password'),
    secretEnvVar(key: 'TERADATA_USER', secretName: 'foodmart-teradata-credentials', secretKey: 'username'),
    secretEnvVar(key: 'TERADATA_PASSWORD', secretName: 'foodmart-teradata-credentials', secretKey: 'password'),
  ]
)

{
  node(label){
    stage("Checkout"){
      container('utils'){
        z.gitCheckout()
        z.dockerLogin('gcr-docker-registry')
        sh "while true; do echo waiting; sleep 6; done"
      }
    }
  }
}
