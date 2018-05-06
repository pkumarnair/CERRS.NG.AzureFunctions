$in = Get-Content $triggerInput -Raw
$proj, $eventname = $in.split("-")
$eventname = $eventname -join "-"
$rgn = $env:region


function WriteMessageToQueue( $storageaccnt,$storageaccountkey,$environment, $queuename, $Message)
    {   
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
 
 
$listenerfile="D:\home\site\wwwroot\configs\$rgn\$proj.json"

$listener=(Get-Content $listenerfile -Raw)|ConvertFrom-Json
Write-Output "Importing module $($listener.applicationName)"
$eventFunc = ""
$evntparms = ""

$event=$listener.events| where { $_.eventTrigger -eq $eventname }

if ($listener.emailinfo){
    $storageaccountname=$env:storageAccountName
    $storagekey=$env:storageaccountkey
    $queuename=$env:emailQueueName
    $emailinfo=@{}
    $emailinfo.Add("to",$listener.emailinfo.emailto)
    $emailinfo.Add("from",$listener.emailinfo.emailfrom)
    $emailinfo.Add("subject",$eventname)
    $emailMessage=$emailinfo|ConvertTo-JSON
    $environment=$env:environment
    WriteMessageToQueue $storageaccountname $storagekey $environment $queuename $emailMessage
    #Write-Output "Wrote email" $emailMessage
}

if(-not $event){
    Write-Output "Nothing to do"
    return
}

$eventFunc=$event.eventFunction
$evntparms=@(ForEach($_ in $event.eventParams){"$($_.type)~=$($_.key)~=$($ExecutionContext.InvokeCommand.ExpandString($_.value))~=$($_.pass)~=$($_.keyname)"}) -join "~~"

if($evntparms){
    $evntparms ="string~=proj~=$proj~=false~~"+$evntparms
}else{
    $evntparms ="string~=proj~=$proj~=false"
}

<#
$events = $listener.events| where { $_.eventTrigger -eq $eventname }
ForEach ($event in $events){
    Write-Output $event.eventDescription
    Write-Output $event.eventFunction
    $eventFunc = $event.eventFunction
    $evntparms = @(ForEach($_ in $event.eventParams){$_.value}) -join "~"
    Write-Output $evntparms
}
#>

Import-Module "D:\home\site\wwwroot\modules\$eventFunc.psm1"
Write-Output "$(Get-Date -Format o) - Starting module $eventFunc"

try{
    &$eventFunc $evntparms
}catch{
    $_
}

Write-Output "$(Get-Date -Format o) - Ended moduled at $eventFunc"

#remove-module $eventFunction
#Write-Output $listenerjson


