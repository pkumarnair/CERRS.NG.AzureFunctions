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
    $messages=@()
    write-output "Inside Initiate-Parallel-Requests------------"

    ForEach($_ in $params.split("~")){
        $key,$val=$_.split("=")
        if($val.split("-")[0] -eq "env"){
            $v=$val.split("-")[1]
            $value = (get-item env:$v).value
        }else{
            $value = $val
        }

        if($key -eq "queuename"){
          $queuename=$value
        }elseIf($key -eq "storagekey"){
          $storagekey=$value
        }elseIf($key -eq "storageaccountname"){
            $storageaccountname=$value
        }elseIf($key -eq "message"){
            $messages+=$value
        }elseIf($key -eq "proj"){
          $proj=$value
        }else{

        }
    }

    try{
        $ctx=New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storagekey -Environment AzureUSGovernment
        $queue = Get-AzureStorageQueue –Name $queueName –Context $ctx
    }catch{
        $_
        return
    }

    ForEach($message in $messages){
        try {
            $queueMessage = New-Object -TypeName Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage -ArgumentList ($proj+"-"+$message)
            $queue.CloudQueue.AddMessage(queueMessage)
        }catch{
            $_
            return
        }
    }

    return
}