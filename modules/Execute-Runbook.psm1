function Execute-Runbook{
    Param
    (
        [Parameter(Mandatory)]
        [string]$params

    )

    $AutomationAccount=""
    $RunbookName=""
    $ResourceGroupName=""
    $hybridAutoServer=""
    $proj=""
    $RbParams=@{}

    write-output "Starting Execute-Runbook------------"
    #write-output $params

    $sep1=[string[]]@("~~")
    $sep2=[string[]]@("~=")
    ForEach($_ in $params.split($sep1, [System.StringSplitOptions]::RemoveEmptyEntries)){
        $vartype,$varname,$varval,$varpass,$varkeyname=$_.split($sep2, [System.StringSplitOptions]::RemoveEmptyEntries)

        if($varname -eq "ResourceGroupName"){
            $ResourceGroupName=$varval;
        }elseif($varname -eq "AutomationAccount"){
            $AutomationAccount=$varval;
        }elseif($varname -eq "RunbookName"){
            $RunbookName=$varval;
        }elseif($varname -eq "hybridAutoServer"){
            $hybridAutoServer=$varval;
        }elseif($varname -eq "proj"){
            $proj=$varval;
        }elseif($varname -eq "outmessage"){
            $varval=$proj+"-"+$varval;
        }else{

        }

        if($varpass -eq "false"){
            continue
        }

        if(!$RbParams[$varname]){
            if($vartype -eq "list"){
                $RbParams[$varname]=@();
            }elseif($vartype  -eq "hashtable"){
                $RbParams[$varname]=@{};
            }else{
            }
        }

        if($vartype -eq "list"){
            $RbParams[$varname]+=$varval
        }elseif($vartype -eq "hashtable"){
            $RbParams[$varname].Add($varkeyname, $varval)
        }else{
            $RbParams[$varname]=$varval
        }
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