    [CmdletBinding()]
    # Description: This Powershell Script is used for sending an email. The trigger file contains the contents of the rmail which includes the following
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
    $email = Get-Content $triggerInput|ConvertFrom-JSON
    write-output $emailinfo|ConvertTo-JSON
    $to=$email.emailinfo.emailto
    $from=$email.emailinfo.emailfrom
    
    $subject=$email.content.subject
    $body=""
    if($email.content.body){
        $body=$email.content.body 
    }


    $body+="`nThis is an auto-generated message from the Case Automation system notifying you of an event completion. The event mentioned in the subject line has completed successfully.`n Please do not reply to this email. Contact Case automation support @$($email.emailinfo.contactno) if you have any questions"
    #$body+="`n This is an auto-generated message, therefore please do not reply to this email.`n Contact our customer support @ $($email.emailinfo.contactno) for any further questions"

    $emailid=$env:emailid
    $emailpswrd = ConvertTo-SecureString $env:emailpswdsecstr -asPlainText -Force
    $creds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $emailid, $emailpswrd

    write-output $env:smtpport
    if (-not ($to -And $subject)){
        return
    }

    try{
       Send-MailMessage -To $emailinfo.to -Body $body -Subject $emailinfo.subject  -UseSsl -Port $env:smtpport -SmtpServer $env:smtpserver -From $from -Credential $creds
    }catch{
        $_
        return
    }
