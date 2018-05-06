function Initiate-Parallel-Requests{
    Param
    (
        [Parameter(Mandatory)]
        [string]$params
    )

    $proj=""
    $storagekey=""
    $queuename=""
    $storageaccountname=""
    $connectionstring=""
    $messages=@()
    $environment=$env:environment
    write-output "Inside Initiate-Parallel-Requests------------"

    $sep1=[string[]]@("~~")
    $sep2=[string[]]@("~=")
    ForEach($_ in $params.split($sep1, [System.StringSplitOptions]::RemoveEmptyEntries)){
        $vartype,$varname,$varval,$varpass,$varkeyname=$_.split($sep2, [System.StringSplitOptions]::RemoveEmptyEntries)

        if($varname -eq "queuename"){
          $queuename=$varval
        }elseIf($varname -eq "storagekey"){
          $storagekey=$varval
        }elseIf($varname -eq "connectionstring"){
          $connectionstring=$varval
        }elseIf($varname -eq "storageaccountname"){
            $storageaccountname=$varval
        }elseIf($varname -eq "message"){
            $messages+=$varval
        }elseIf($varname -eq "proj"){
          $proj=$varval
        }else{

        }
    }

    write-output "queuename is $queuename"
    write-output "connectionstring is $connectionstring"
    write-output "storageaccountname is $storageaccountname"
    write-output "storagekey is $storagekey"
    write-output "messages is $messages"

    ForEach($message in $messages){
        try {
            $message=$proj+"-"+$message
            WriteMessageToQueue $storageaccountname ($storagekey|out-string) $environment $queuename $message
        }catch{ 
            $_
            return
        }
    }
    return
}
 
function WriteMessageToQueue( $storageaccnt,$storageaccountkey,$environment, $queuename, $Message){   
    try { 
            $ctx = New-AzureStorageContext -StorageAccountName $storageaccnt -StorageAccountKey $storageaccountkey -Environment $environment
            $queue = Get-AzureStorageQueue -name $queuename -context $ctx
            $queueMessage = New-Object -TypeName Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage -ArgumentList $Message
            $queue.CloudQueue.AddMessage($queueMessage) 
    }
    catch { 
        $_
    }
}