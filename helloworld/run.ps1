$in = Get-Content $triggerInput -Raw
Write-Output "PowerShell script processed queue message '$in'"
write-Output 'Getting variables'
#$result = Get-Variable | out-string
$result = Get-AzureRmContext | out-string
write-output "--------------------"
write-Output $result
write-output "--------------------"



<#
$subscriptionId = "9f657357-308f-4780-aee7-070aa7f55580"
$resourceGroupName = "CERRS-DEV-TEST-RG"
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName

Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint -EnvironmentName AzureUSGovernment


Start-AzureRmAutomationRunbook -Name "Delete-HDISparkCluster" -AutomationAccountName "svc-oms-automation" -ResourceGroupName "CERRS-DEV-TEST-RG"
#>


$runbookName = "Delete-HDISparkCluster"
$ResourceGroup = "CERRS-DEV-TEST-RG"
$AutomationAcct = "svc-oms-automation"

$job = Start-AzureRmAutomationRunbook –AutomationAccountName $AutomationAcct -Name $runbookName -ResourceGroupName $ResourceGroup

$doLoop = $true
While ($doLoop) {
   $job = Get-AzureRmAutomationJob –AutomationAccountName $AutomationAcct -Id $job.JobId -ResourceGroupName $ResourceGroup
   $status = $job.Status
   $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped"))
}

Get-AzureRmAutomationJobOutput –AutomationAccountName $AutomationAcct -Id $job.JobId -ResourceGroupName $ResourceGroup –Stream Output