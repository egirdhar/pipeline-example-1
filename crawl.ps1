[cmdletbinding()]
param(
    [string[]] 
    $Task = 'default',

    [string]
    $Server = 'localhost',
    
    [string]
    $Repo = '\\Server\DSCRepo'
)

 Get-ChildItem -Path c:\jenkins_home\ -Filter nuget.exe -Recurse -ErrorAction SilentlyContinue -Force