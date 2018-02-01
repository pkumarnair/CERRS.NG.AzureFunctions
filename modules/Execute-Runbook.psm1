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

    ForEach($_ in $params.split("~")){
        $key,$val=$_.split("=")
        write-output "?????????????????"
        write-output $val
        if($val.split("-")[0] -eq "env"){
            $v=$val.split("-")[1]
            $value = (get-item env:$v).value
        }else{
            $value = $val
        }
        write-output $value
        write-output "?????????????????"
        if($key -eq "runbookName"){
          $RunbookName=$value
        }ElseIf($key -eq "resourceGroup"){
          $ResourceGroupName=$value
        }ElseIf($key -eq "automationAccount"){
          $AutomationAccount=$value
        }else{

        }

        write-output "Key is $key, and value is $value"
        $RbParams.add($key,$value)
    }

    write-output "The Runbook job parameters ------------"
    write-output $RunbookName
    write-output $AutomationAccount
    write-output $ResourceGroupName
    write-output $RbParams|ConvertTo-JSON

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