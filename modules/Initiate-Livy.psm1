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
    $outmessage=""

    $joblocation=$env:pythonJobLocation
    $livyendpoint=$env:livyendpoint
    #$joblocation="wasb://cerrscablob@cerrscaseautomationdev.blob.core.usgovcloudapi.net/"
    write-output "Inside Initiating Livy------------"

    ForEach($_ in $params.split("~")){
        $key,$value=$_.split("=")
        if($key -eq "pyfiles"){
          $pyfiles+=$joblocation+$value
        }elseIf($key -eq "pyargs"){
          $pyargs+=$value
        }elseIf($key -eq "proj"){
          $proj=$value
        }elseIf($key -eq "outMessage"){
          $outmessage=$proj+"-"+$value
        }elseIf($key -eq "mainfile"){
          $mainfile=$joblocation+$value
        }elseIf($key -Match "pyconf-*"){
          $key,$val=$key.split("-")
          $key=$val -join "-"
          $pyconf.add($key,$value)
        }else{

        }
    }

    if($outmessage){
        $pyargs=, $outmessage + $pyargs
    }

    $postdata.Add("file",$mainfile)
    if($pyfiles){
        $postdata.Add("pyFiles",$pyfiles)
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

    $livyuri = "https://$clustername.$livyendpoint/livy/batches"
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