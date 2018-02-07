$in = Get-Content $triggerInput|ConvertFrom-JSON
$rgn = $env:
write-output $in|ConvertTo-JSON

