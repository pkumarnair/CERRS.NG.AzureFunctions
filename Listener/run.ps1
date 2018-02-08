$in = Get-Content $triggerInput -Raw
$proj, $eventname = $in.split("-")
$eventname = $eventname -join "-"
$rgn = $env:region

$listenerfile="D:\home\site\wwwroot\configs\$rgn\$proj.json"

$listener=(Get-Content $listenerfile -Raw)|ConvertFrom-Json
Write-Output "Importing module $($listener.applicationName)"
$eventFunc = ""
$evntparms = ""

$event = $listener.events| where { $_.eventTrigger -eq $eventname }
$emailto=$listener.events.emailto
$eventFunc = $event.eventFunction
$evntparms = @(ForEach($_ in $event.eventParams){"$($_.key)=$($_.value)"}) -join "~"

$emailinfo=@{}
$emailinfo.Add("to",$emailto)
$emailinfo.Add("subject",$eventname)
$emailMessage=$emailinfo|ConvertTo-JSON

if($evntparms){
    $evntparms ="proj=$proj~"+$evntparms
}else{
    $evntparms ="proj=$proj"
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