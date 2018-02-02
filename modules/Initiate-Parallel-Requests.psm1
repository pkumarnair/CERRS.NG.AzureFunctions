Import-Module Import-Module "D:\home\site\wwwroot\modules\AzureRmStorageQueueCoreHelper.psm1"

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

    $resourcegroupname=$env:spnresourcegroupname
    $clientID = $env:spnid
    $key = $env:spnkey
    $tenantid = $env:spntenant
    $SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword

    try {
        Add-AzureRmAccount -Credential $cred -Tenant $tenantid -ServicePrincipal -EnvironmentName AzureUSGovernment
    }catch{
        $_
        return
    }

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


    $storage=Get-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -AccountName $storageaccountname

    write-output $storage
    write-output "queuename is $queuename"
    write-output "connectionstring is $connectionstring"
    write-output "storageaccountname is $storageaccountname"
    write-output "messages is $messages"

    try{
        write-output "11111111111111111111111111111111111111111"
        #$ctx=New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storagekey -Environment AzureUSGovernment
        #$ctx=New-AzureStorageContext -ConnectionString $connectionstring
        #$ctx=$storage.Context
        write-output "22222222222222222222222222222222222222222"
        #$queue = Get-AzureStorageQueue –Name $queuename –Context $ctx
        $queue = Get-AzureRmStorageQueueQueue -resourceGroup $resourcegroupname -storageAccountName $storageaccountname -queueName $queuename
    }catch{
        $_
        return
    }

    ForEach($message in $messages){
        try {
            write-output "3333333333333333333333333333333333333333333"
            $queueMessage = New-Object -TypeName Microsoft.WindowsAzure.Storage.Queue.CloudQueueMessage -ArgumentList ($proj+"-"+$message)
            #$queue.CloudQueue.AddMessage($queueMessage)
            Add-AzureRmStorageQueueMessage -queue $queue -message @{"message"=$proj+"-"+$message}
        }catch{
            $_
            return
        }
    }

    return
}