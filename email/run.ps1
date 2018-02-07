[CmdletBinding()]
# Description: This Powershell Script is used for seding an email. The trigger file contains the contents of the rmail which includes the following
#       To:name1<emailid1@host.com>,name2<emailid2@host.com>,name3<emailid1@host.com>,name4<emailid4@host.com>
#       From: name<emailid@host.com>
#       Subject: Subject of the email
#       body:
#            body of the email.
# 
#
#   The order of the above does not matter. However make sure the body is the last part of the message.
#
# Command : .\sendemail "C:\FileLocation\TriggerFileName"
#
$emailinfo = Get-Content $triggerInput|ConvertFrom-JSON
write-output $emailinfo|ConvertTo-JSON

$body="Test"
$to=""
$from="caseautomationsupport@cognosante.com"

$emailid="CGS\adm_pku"
$emailpswrd = ConvertTo-SecureString $env:emailpswdsecstr -asPlainText -Force
$creds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $emailid, $emailpswrd

if (-not ($emailinfo.to -And $emailinfo.subject)){
    return
}

if ($email.from){
    $from=$email.from
}

if ($email.body){
    $body=$email.body
}

try{
   Send-MailMessage -To $emailinfo.to -Body $body -Subject $emailinfo.subject  -UseSsl -Port $env:smtpport -SmtpServer $enf:smtpserver -From $from -Credential $creds
}catch{
    $_
}


    
