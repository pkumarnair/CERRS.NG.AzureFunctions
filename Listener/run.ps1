$in = Get-Content $triggerInput -Raw

$clientID = $env:spnid
$key = $env:spnkey
$tenantid = $env:spntenant
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword
$resourceGroupName = "cerrs-dev-test-rg"
$StorageAccountName = "cerrscaseautomation"
$container="listener"
$filename="listener"
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Blob = Get-AzureStorageBlob -Context $StorageAccount.Context -Container $container -Blob $Filename
$Text = $blob.ICloudBlob.DownloadText()
Write-Output $Text