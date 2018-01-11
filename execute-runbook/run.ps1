$in = Get-Content $triggerInput -Raw

$runbookName, $AutomationAccount = $in.split(",")
$runbookName="svc-oms-automation"
$AutomationAccount="Delete-HDISparkCluster"

$clientID = $env:spnid
$key = $env:spnkey
$tenantid = $env:spntenant
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword

write-output "Executing Runbook $runbookName in $AutomationAccount"

try {
    Add-AzureRmAccount -Credential $cred -Tenant $tenantid -ServicePrincipal -EnvironmentName AzureUSGovernment
    Select-AzurermSubscription -SubscriptionName $env:spnsubscription
    #Start-AzureAutomationRunbook -AutomationAccountName "svc-oms-automation" -Name "Delete-HDISparkCluster"
    Start-AzureAutomationRunbook -AutomationAccountName $AutomationAccount -Name $runbookName
}catch{
    $_
    $sendemail = "subject~$runbookName could not be executed~~~body~$_.Exception"
    return
}
$sendemail = "subject~CA-Runbook $runbookName successfully completed"
return
<#
$resourceGroupName = "CERRS-DEV-TEST-RG"
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName

Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint -EnvironmentName AzureUSGovernment


Start-AzureRmAutomationRunbook -Name "Delete-HDISparkCluster" -AutomationAccountName "svc-oms-automation" -ResourceGroupName "CERRS-DEV-TEST-RG"
#>

<#
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
#>