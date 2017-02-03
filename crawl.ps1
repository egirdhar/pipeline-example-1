[cmdletbinding()]
param(
    [string[]] 
    $Task = 'default',

    [string]
    $Server = 'localhost',
    
    [string]
    $Repo = '\\Server\DSCRepo'
)

 Get-ChildItem -Path c:\jenkins_home\ -Filter nuget -Recurse -ErrorAction SilentlyContinue -Force
 
 
 
 
 node
{
	stage 'Checkout'
	
  	        bat 'git init &&  git config http.sslVerify false'
 	        checkout([$class: 'GitSCM', branches: [[name: '*/master']],
            
    
    stage 'Build'
            
 	         bat 'nuget restore SampleWebApp.sln'
	         bat "\"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe\" SampleWebApp.sln  /p:OutDir=target /p:Configuration=Debug /p:Platform=\"Any CPU\" /p:ProductVersion=1.0.0.${env.BUILD_NUMBER}"
                }
    
    stage 'Test'
            bat "\"C:/Program Files (x86)/NUnit.org/nunit-console/nunit3-console.exe\" --result:TestResult.xml;format=nunit2  Tests/bin/Debug/Tests.dll"
            step([$class: 'NUnitPublisher', testResultsPattern:'**/TestResult.xml', debug: false, keepJUnitReports: true, skipJUnitArchiver:false, failIfNoResults: true]) 
    
    stage 'Code Analysis'
           
                        def scannerHome = tool 'SonarMSBuild'
                        def msbuildHome = tool 'MSBuild';
                          
        
                         bat "\"${scannerHome}/SonarQube.Scanner.MSBuild.exe\" begin  /d:sonar.host.url=${SONAR_HOST}  /k:\"SampleWebApp\" /n:\"SampleWebApp\" /v:\"1.0\" "
                         bat "\"${msbuildHome}\" /t:Rebuild"
                       bat "\"${scannerHome}/MSBuild.SonarQube.Runner.exe\" end"
            }           
                //        def response = 'http://localhost:9000/api/qualitygates/project_status?projectKey=SampleWebApp'
                 //       def slurper = new groovy.json.JsonSlurper()
                  //      def result = slurper.parseText(response.content)
                     //   println('Status: '+response.status)
                     //   println('Response: '+response.content)
                  //      if (result.projectStatus.status == "ERROR") {
                //            currentBuild.result = 'FAILURE'
                 //       }else{
                  //          currentBuild.result ='SUCCESS'
                //        }
                  
    
    stage 'Archive'
		 archiveArtifacts artifacts: 'DataLayer/target/*.*,ServiceLayer/target/*.*,SampleWebApp/target/*.*', fingerprint: true
         def server = Artifactory.newServer url:'http://localhost:9090/artifactory', username:'admin', password:'password'
        
         def uploadSpec =
            '''{
            "files": [
                {
                    "pattern": "DataLayer/target/**",
                    "target": "nuget-local/DataLayer.zip"
                    
                }
            ]
        }'''
    // Upload to Artifactory.
     
    def buildInfo1 = server.upload spec: uploadSpec
 }   
    
 
}

  
   
