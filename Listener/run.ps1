$in = Get-Content $triggerInput -Raw
$proj, $event = $in.split("-")

$clientID = $env:spnid
$key = $env:spnkey
$tenantid = $env:spntenant
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $clientID, $SecurePassword
$resourceGroupName = "cerrs-dev-test-rg"
$StorageAccountName = "cerrscaseautomation"
$container="listemer"
$filename="$proj.json"

$storagekey="g4cMymRd43HdRoAU+nHVNVUInozYYu8yE8Yo7QG3Jfe0namaWmeKCL6zD4BsKjdsLZGRSmjk7Ez0mJ4aa6S2wA=="

$ctx=New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storagekey -EnvironmentName "AzureUSGovernment"
#$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Blob = Get-AzureStorageBlob -Context $ctx -Container $container -Blob $filename
$listenerjson = $blob.ICloudBlob.DownloadText() | ConvertTo-Json


Write-Output $listenerjson