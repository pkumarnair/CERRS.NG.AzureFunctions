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

    ForEach($_ in $params.split("~")){
        $key,$value=$_.split("=")
        if($key -eq "queuename"){
          $queuename=$value
        }elseIf($key -eq "storagekey"){
          $storagekey=$value
        }elseIf($key -eq "connectionstring"){
          $connectionstring=$value
        }elseIf($key -eq "storageaccountname"){
            $storageaccountname=$value
        }elseIf($key -eq "message"){
            $messages+=$value
        }elseIf($key -eq "proj"){
          $proj=$value
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
            WriteMessageToQueue $storageaccountname $storagekey $environment $queuename $message
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
 
