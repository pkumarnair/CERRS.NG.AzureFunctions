$in = Get-Content $triggerInput -Raw

$proj, $eventname = $in.split("-")
$rgn = $env:region

$filename="D:\home\site\wwwroot\configs\$rgn\$proj.json"

$listener=(Get-Content $filename -Raw)|ConvertFrom-Json
Write-Output "Importing module " + $listener.applicationName

$events = $listener.events| where { $_.eventTrigger -eq $eventname }
ForEach $event in $events{
    Write-Output $event.eventDescription
    Write-Output $event.eventFunction
    Write-Output $event.eventParams|convertTo-Json
}

#Import-Module "D:\home\site\wwwroot\modules\Execute-Runbook.psm1"
#Write-Output "Executing module"
#Execute-Runbook "Delete-HDISparkCluster~CERRS-DEV-TEST-RG~svc-oms-automation"

#Write-Output $listenerjson