$in = Get-Content $triggerInput -Raw
$proj, $event = $in.split("-")

$clientID = $env:spnid
$key = $env:spnkey
$tenantid = $env:spntenant
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword
$resourceGroupName = "cerrs-dev-test-rg"
$StorageAccountName = "cerrscaseautomation"
$container="listemer"
$filename="D:\home\site\wwwroot\configs\$proj.json"

$listenerjson=(Get-Content $filename -Raw)|ConvertFrom-Json
Write-Output "Importing module $listenerjson.applicationName"
Import-Module "D:\home\site\wwwroot\modules\Execute-Runbook.psm1"
Write-Output "Executing module"
#Execute-Runbook "Delete-HDISparkCluster~CERRS-DEV-TEST-RG~svc-oms-automation"

Write-Output $listenerjson