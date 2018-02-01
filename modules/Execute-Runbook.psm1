function Execute-Runbook{
    Param
    (
        [Parameter(Mandatory)]
        [string]$params

    )

    $AutomationAccount=""
    $RunbookName=""
    $ResourceGroupName=""
    $RbParams=@{}

    write-output "Starting Execute-Runbook------------"
    write-output $params

    $RbParams=@{}

    ForEach($_ in $params){
        $key,$value=$_.split("=")
        if($key="runbookName"){
          $RunbookName=$value
        }ElseIf($key="resourceGroup"){
          $ResourceGroupName=$value
        }ElseIf($key="automationAccount"){
          $AutomationAccount=$value
        }else{

        }
        $RbParams.add($_.split("=")[0],$value)
    }

    write-output "The Runbook job parameters ------------"
    write-output $RunbookName
    write-output $AutomationAccount
    write-output $ResourceGroupName
    write-output $RbParams

    $clientID = $env:spnid
    $key = $env:spnkey
    $tenantid = $env:spntenant
    $SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword

    write-output "Executing Runbook $RunbookName in $AutomationAccount"

    try {
        Add-AzureRmAccount -Credential $cred -Tenant $tenantid -ServicePrincipal -EnvironmentName AzureUSGovernment
        if ($RbParams){
            Start-AzureRMAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -ResourceGroupName $ResourceGroupName -Parameter $RbParams
        }else{
            Start-AzureRMAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -ResourceGroupName $ResourceGroupName
        }
    }catch{
        $_
        return
    }
    return
}