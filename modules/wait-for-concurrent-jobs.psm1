function Wait-For-Concurrent-Jobs{
    Param
    (
        [Parameter(Mandatory)]
        [string]$params
    )

    $queuename=$env:listenerqueueName
    $storageaccnt=$env:storageAccountName
    $storageaccountkey=$env:storageaccountkey
    $container=$env:clustercontainer
    $environment="AzureUSGovernment"
    $blobname=""
    $messages=@()
    $outmessage=""
    $currentmessage=""
    $proj=""
    $files=""

    ForEach($_ in $params.split("~")){
        $key,$val=$_.split("=")
        if($val.split("-")[0] -eq "env"){
            $v=$val.split("-")[1]
            $value = (get-item env:$v).value
        }else{
            $value = $val
        }

        if($key -eq "blobname"){
          $blobname=$value
        }elseIf($key -eq "waitmessage"){
            $messages+=$value
        }elseIf($key -eq "currentmessage"){
            $currentmessage=$value
        }elseIf($key -eq "proj"){
          $proj=$value
        }elseIf($key -eq "outmessage"){
          $outmessage=$value
        }else{

        }
    }

    $ctx = New-AzureStorageContext -StorageAccountName $storageaccnt -StorageAccountKey $storageaccountkey -Environment AzureUSGovernment
    $blobfile=Get-AzureStorageBlob -Container $container -Blob $blobname -Context $ctx  -ErrorAction Ignore
    if($blobfile){
       $files = $blobfile.ICloudBlob.DownloadText()
    }

    $files+=$currentmessage

    try{
        if(($files|Measure-Object –Line).Lines -ge ($messages.count)){
            $message=$proj+"-"+$outmessage
            #WriteMessageToQueue $storageaccountname $storagekey $environment $queuename $message
            Remove-AzureStorageBlob -Container $container -Blob $blobname -Context $ctx -Force    
        }else{
            $tempfile = New-TemporaryFile 
            Set-Content -Path $tempfile -Value $files
            Set-AzureStorageBlobContent -Container $container -Blob $blobname -Context $ctx -File $tempfile -Force
            Remove-Item $tempfile -Force -ErrorAction:SilentlyContinue
        }
    }catch{
        $_
    }
}

function WriteMessageToQueue( $storageaccnt,$storageaccountkey,$environment, $queuename, $Message){   
    try { 
        $ctx = New-AzureStorageContext -StorageAccountName $storageaccnt -StorageAccountKey $storageaccountkey -Environment $environment
        $queue = Get-AzureStorageQueue -name $queuename -context $ctx
        $queueMessage = New-Object -TypeName Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage -ArgumentList $Message
        $queue.CloudQueue.AddMessage($queueMessage) 
    }catch{ 
        $_
    }
}