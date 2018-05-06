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
    $livyendpoint=""
    $outmessage=""

    write-output "Inside Initiating Livy------------"

    $sep1=[string[]]@("~~")
    $sep2=[string[]]@("~=")
    ForEach($_ in $params.split($sep1, [System.StringSplitOptions]::RemoveEmptyEntries)){
        $vartype,$varname,$varval,$varpass,$varkeyname=$_.split($sep2, [System.StringSplitOptions]::RemoveEmptyEntries)

        if($varname -eq "pyfiles"){
          $pyfiles+=$varval
        }elseIf($varname -eq "pyargs"){
          $pyargs+=$varval
        }elseIf($varname -eq "proj"){
          $proj=$varval
        }elseIf($varname -eq "outMessage"){
          $outmessage=$proj+"-"+$varval
        }elseIf($varname -eq "mainfile"){
          $mainfile=$varval
        }elseIf($varname -eq "pyconf"){
          $pyconf.add($varkeyname,$varval)
        }elseIf($varname -eq "livyendpoint"){
          $livyendpoint=$varval
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