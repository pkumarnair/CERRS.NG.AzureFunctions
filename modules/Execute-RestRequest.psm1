function Execute-RestRequest{
    Param
    (
        [Parameter(Mandatory)]
        [string]$params

    )

    $restUrl=""
    $restMethod=""
    $restparams=""
    $postparam=""
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

    write-output "Inside Execute RestRequest------------"

    ForEach($_ in $params.split("~")){
        $key,$val=$_.split("=")
        if($val.split("-")[0] -eq "env"){
            $v=$val.split("-")[1]
            $value = (get-item env:$v).value
        }else{
            $value = $val
        }

        if($key -eq "resturl"){
          $restUrl=$value
        }elseIf($key -eq "restMethod"){
          $restMethod=$value
        }elseIf($key -Match "restparams-*"){
            $key,$val=$key.split("-")
            $key=$val -join "-"
            if ($restparams){
                $restparams+="&$val=$value"      
            }else{
                $restparams+="$val=$value"      
            }
        }elseIf($key -Match "header-*"){
            $key,$val=$key.split("-")
            $key=$val -join "-"
            $headers.Add($val, $value)
        }else{

        }
    }

    if($restMethod){
        $restUrl=$restUrl+"?$restparams"
    }

    write-output "---------------------------"
    write-output $restUrl
    write-output $restparams
    write-output $headers
    write-output "---------------------------"

    try {
        if($restMethod -eq "Get"){
            if($headers.count -eq 0){
                $restresponse=Invoke-RestMethod -URI $resturl -ContentType "application/json" -Method GET -Headers $headers
            }else{
                $restresponse=Invoke-RestMethod -URI $resturl -ContentType "application/json" -Method GET
            }
        }
        write-output $restresponse|ConvertTo-JSON
    }catch{
        $_
        return
    }
    return
}