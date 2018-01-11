$in = Get-Content $triggerInput -Raw

$RunbookName, $ResourceGroupName, $AutomationAccount = $in.split(",")

$clientID = $env:spnid
$key = $env:spnkey
$tenantid = $env:spntenant
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword

write-output "Executing Runbook $runbookName in $AutomationAccount"

try {
    Add-AzureRmAccount -Credential $cred -Tenant $tenantid -ServicePrincipal -EnvironmentName AzureUSGovernment

    #Select-AzureSubscription -Default -SubscriptionName $env:spnsubscription
    #Select-AzureRmSubscription -SubscriptionName $env:spnsubscription
    #Start-AzureAutomationRunbook -AutomationAccountName "svc-oms-automation" -Name "Delete-HDISparkCluster"
    Start-AzureRMAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -ResourceGroupName $ResourceGroupName
}catch{
    $_
    $sendemail = "subject~$runbookName could not be executed~~~body~$_.Exception"
    return
}
$sendemail = "subject~CA-Runbook $runbookName successfully completed"
return