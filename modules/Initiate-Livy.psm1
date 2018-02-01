function Initiate-Livy{
    Param
    (
        [Parameter(Mandatory)]
        [string]$params

    )

    $mainfile=""
    $pyfiles=@()
    $pyconf=@{}
    $pyargs=@()
    $postdata=@{}

    $joblocation=$env:pythonJobLocation
    #$joblocation="wasb://cerrscablob@cerrscaseautomationdev.blob.core.usgovcloudapi.net/"
    write-output "Starting Execute-Runbook------------"
    write-output $params

    ForEach($_ in $params.split("~")){
        $key,$val=$_.split("=")
        if($val.split("-")[0] -eq "env"){
            $v=$val.split("-")[1]
            $value = (get-item env:$v).value
        }else{
            $value = $val
        }

        if($key -eq "pyfiles"){
          $pyfiles+=$joblocation+$value
        }ElseIf($key -eq "pyargs"){
          $pyargs+=$value
        }ElseIf($key.substring(0,6) -eq "pyconf"){
          $key,$val=$_.split("-")
          $key=$val -join "-"
          $pyconf.add($key,$value)
        }elseIf($key -eq "mainfile"){
          $mainfile=$joblocation+$value
        }else{

        }
    }

    write-output "The livy parameters ------------"
    write-output "Mainfile is $mainfile"
    write-output "pyfiles are "($pyfiles|ConvertTo-JSON)
    write-output "pyargs are "($pyargs|ConvertTo-JSON)
    write-output "pyconf are "($pyconf|ConvertTo-JSON)


    $postdata.Add("file",$mainfile)
    if($pyfiles){
        $postdata.Add("pyfiles",$pyfiles)
    }

    if($pyargs){
        $postdata.Add("args",$pyargs)
    }

    if($pyconf){
        $postdata.Add("conf",$pyconf)
    }

    write-output "Post data is " ($postdata|ConvertTo-JSON)

    $clusteruser = $env:clusteruser
    $SecurePassword = $env:clusterpassword | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $clusteruser, $SecurePassword
    $clustername=$env:clustername

    $livyuri = "https://$clustername.azurehdinsight.us/livy/batches"
    write-output "Initiating Livy Api call $livyurl"

    try {
        $livybatch=Invoke-RestMethod -URI $livyuri -ContentType "application/json" -Credential $cred -Method POST -Body ($postdata|ConvertTo-JSON)
        write-output $livybatch|ConvertTo-JSON
    }catch{
        $_
        return
    }
    return
}