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
    $environment=$env:environment
    $blobname=""
    $messages=@()
    $outmessage=""
    $currentmessage=""
    $proj=""
    $files=""

    $sep1=[string[]]@("~~")
    $sep2=[string[]]@("~=")
    ForEach($_ in $params.split($sep1, [System.StringSplitOptions]::RemoveEmptyEntries)){
        $key,$value=$_.split($sep2, [System.StringSplitOptions]::RemoveEmptyEntries)

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

    $ctx = New-AzureStorageContext -StorageAccountName $storageaccnt -StorageAccountKey $storageaccountkey -Environment $environment
    $blobfile=Get-AzureStorageBlob -Container $container -Blob $blobname -Context $ctx  -ErrorAction Ignore
    if($blobfile){
       $files = $blobfile.ICloudBlob.DownloadText()
    }

    $files+=$currentmessage
    $filescount=($files | Measure-Object -Line).Lines
    $msgcnt=$messages.count
    try{
        if($filescount -ge $msgcnt){
            $message=$proj+"-"+$outmessage
            WriteMessageToQueue $storageaccnt $storageaccountkey $environment $queuename $message
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