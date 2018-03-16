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
    $pyfiles=@()
    $pyconf=@{}
    $pyargs=@()
    $hybridAutoServer=""

    write-output "Starting Execute-Runbook------------"
    #write-output $params

    $sep1=[string[]]@("~~")
    $sep2=[string[]]@("~=")
    ForEach($_ in $params.split($sep1, [System.StringSplitOptions]::RemoveEmptyEntries)){
        $key,$value=$_.split($sep2, [System.StringSplitOptions]::RemoveEmptyEntries)
        if($key -eq "runbookName"){
            $RunbookName=$value
        }ElseIf($key -eq "resourceGroupName"){
            $ResourceGroupName=$value
        }ElseIf($key -eq "automationAccount"){
            $AutomationAccount=$value
        }ElseIf($key -eq "proj"){
            $proj=$value
        }ElseIf($key -eq "outMessage"){
            $value=$proj+"-"+$value
        }elseif($key -eq "pyfiles"){
            $pyfiles+=$value
        }elseIf($key -eq "pyargs"){
            $pyargs+=$value
        }elseIf($key -Match "pyconf-*"){
            $key1,$val=$key.split("-")
            $key1=$val -join "-"
            $pyconf.add($key1,$value)
        }elseIf($key -eq "hybridAutoServer"){
            $hybridAutoServer=$value
        }else{

        }

        #write-output "Key is $key, and value is $value"
        If($key -ne "proj" -and $key -ne "hybridAutoServer" -and $key -ne "pyfiles" -and $key -ne "pyargs" -and -not($key -Match "pyconf-*")){
              $RbParams.add($key,$value)
        }
    }

    If($pyfiles){
              $RbParams.add("pyfiles",$pyfiles)
    }

    If($pyargs){
              $RbParams.add("pyargs",$pyargs)
    }

    If($pyconf.count){
        $RbParams.add("pyconf",$pyconf)
    }

    write-output "The Runbook job parameters ------------"
    write-output "Runbook is $RunbookName"
    write-output "AutomationAccount is $AutomationAccount"
    write-output "ResourceGroupName is $ResourceGroupName"
    write-output $RbParams|ConvertTo-JSON

    $clientID = $env:spnid
    $key = $env:spnkey
    $tenantid = $env:spntenant
    $SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword

    write-output "Executing Runbook $RunbookName in $AutomationAccount"

    try {
        Add-AzureRmAccount -Credential $cred -Tenant $tenantid -ServicePrincipal -EnvironmentName AzureUSGovernment
        if($hybridAutoServer){
            if ($RbParams){
                  Start-AzureRMAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -ResourceGroupName $ResourceGroupName -Parameter $RbParams -RunOn $hybridAutoServer
            }else{
                  Start-AzureRMAutomationRunbook -AutomationAccountName $AutomationAccount -Name $RunbookName -ResourceGroupName $ResourceGroupName -RunOn $hybridAutoServer
            }  
        }elseIf ($RbParams){
              write-output "executing runbook now"
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