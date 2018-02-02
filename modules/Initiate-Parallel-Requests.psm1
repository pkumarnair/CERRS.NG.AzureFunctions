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
<#
    try{
        $message=$proj+"-"+$message
        test-function $storageaccountname $storagekey $queuename $message 
        write-output "11111111111111111111111111111111111111111"
        $ctx=New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storagekey -Environment AzureUSGovernment
        #$ctx=New-AzureStorageContext -ConnectionString $connectionstring
        write-output "22222222222222222222222222222222222222222"
        $queue = Get-AzureStorageQueue –Name $queuename –Context $ctx
    }catch{
        $_
        return
    }
#>
    ForEach($message in $messages){
        try {
            $message=$proj+"-"+$message
            test-function $storageaccountname $storagekey $queuename $message 
            #write-output "3333333333333333333333333333333333333333333"
            #$queueMessage = New-Object -TypeName Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage -ArgumentList ($proj+"-"+$message)
            #$queue.CloudQueue.AddMessage($queueMessage)
        }catch{
            $_
            return
        }
    }

    return
}

function test-function{
    Param(
        $storageaccountname,
        $storagekey,
        $queuename,
        $message

        )

    try{
        write-output "11111111111111111111111111111111111111111"
        $ctx=New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storagekey -Environment AzureUSGovernment
        write-output "22222222222222222222222222222222222222222"
        $queue = Get-AzureStorageQueue –Name $queuename –Context $ctx
        write-output "33333333333333333333333333333333333333333"
        $queueMessage = New-Object -TypeName Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage -ArgumentList $message
        write-output "44444444444444444444444444444444444444444"
        $queue.CloudQueue.AddMessage($queueMessage)
    }catch{
        $_
        return
    }

    return
}