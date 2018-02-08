$in = Get-Content $triggerInput -Raw
$proj, $eventname = $in.split("-")
$eventname = $eventname -join "-"
$rgn = $env:region

$listenerfile="D:\home\site\wwwroot\configs\$rgn\$proj.json"

$listener=(Get-Content $listenerfile -Raw)|ConvertFrom-Json
Write-Output "Importing module $($listener.applicationName)"
$eventFunc = ""
$evntparms = ""

$event=$listener.events| where { $_.eventTrigger -eq $eventname }

if ($listener.emailinfo){
    $emailinfo=@{}
    $emailinfo.Add("to",$listener.emailinfo.emailto)
    $emailinfo.Add("from",$listener.emailinfo.emailfrom)
    $emailinfo.Add("subject",$eventname)
    $emailMessage=$emailinfo|ConvertTo-JSON
    Write-Output "Wrote email" $emailMessage
}

if(-not $eventFunc){
    Write-Output "Nothing to do"
    return
}

$eventFunc=$event.eventFunction
$evntparms=@(ForEach($_ in $event.eventParams){"$($_.key)=$($_.value)"}) -join "~"

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