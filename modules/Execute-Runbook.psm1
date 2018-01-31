function Execute-Runbook{
    Param
    (
        [Parameter(Mandatory)]
        [string[]]$params

    )

    $RbParams=@{}

    ForEach($_ in $RbParamsIn){
        $key,$value=$_.split("=")
        if($key="runbookName"){
          $runbookName=$value
        }ElseIf($key="resourceGroup"){
          $resourceGroup=$value
        }ElseIf($key="automationAccount"){
          $automationAccount=$value
        }else{

        }
        $RbParams.add($_.split("=")[0],$value)
    }

    $clientID = $env:spnid
    $key = $env:spnkey
    $tenantid = $env:spntenant
    $SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword

    write-output "Executing Runbook $runbookName in $AutomationAccount"
    write-output $RbParams

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