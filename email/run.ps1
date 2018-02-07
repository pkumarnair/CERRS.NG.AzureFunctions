$in = Get-Content $triggerInput|ConvertFrom-JSON
write-output $in|ConvertTo-JSON

