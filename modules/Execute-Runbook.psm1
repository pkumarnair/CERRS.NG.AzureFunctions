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
        $key,$value=$_.split("=")
        write-output "?????????????????"
        write-output $value
        if($value.substring(0,5) -eq "$env:"){
            write-output "========="
            write-output $value
            $value = Get-Variable -Name value
            write-output $value
            write-output "========="
        }
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