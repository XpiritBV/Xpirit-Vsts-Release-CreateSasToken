Trace-VstsEnteringInvocation $MyInvocation

$StorageAccountName= Get-VstsInput -Name "StorageAccountRM" 
$StorageContainerName = Get-VstsInput -Name "StorageContainerName" 
$SasTokenTimeOutInHours = Get-VstsInput -Name "SasTokenTimeOutInHours" -Default 1 -AsInt
$Permission = Get-VstsInput -Name "Permission" -Default "r"
$outputStorageContainerSasToken = Get-VstsInput -Name outputStorageContainerSasToken
$outputStorageURI = Get-VstsInput -Name outputStorageUri

Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

Write-VstsTaskVerbose "Creating StorageContext on StorageAccount $StorageAccountName"
$StorageAccountContext = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName}).Context

Write-VstsTaskVerbose "Creating StorageUri with container $StorageContainerName"
$storageAccountContainerURI = $StorageAccountContext.BlobEndPoint + $StorageContainerName
Write-VstsTaskVerbose "StorageAccountContainerUri: $storageAccountContainerURI"
Set-VstsTaskVariable -Name $outputStorageURI -Value $storageAccountContainerURI
Write-VstsTaskVerbose "outputStorageURI: $outputStorageURI"

$ArtifactsLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccountContext -Permission $Permission -ExpiryTime (Get-Date).AddHours($SasTokenTimeOutInHours)
#Write-VstsTaskVerbose "ArtifactsLocationSasToken: $ArtifactsLocationSasToken"

#Moving it to a securestring does not work. So now the next task has to pass it as a securestring with the parameter
#$ArtifactsLocationSasTokenSecure = ConvertTo-SecureString $ArtifactsLocationSasToken -AsPlainText -Force
#Write-VstsTaskVerbose "ArtifactsLocationSasTokenSecure: $ArtifactsLocationSasTokenSecure"
#Set-VstsTaskVariable -Name $outputStorageContainerSasToken -Value $ArtifactsLocationSasTokenSecure
#Write-VstsTaskVerbose "outputStorageContainerSasToken: $outputStorageContainerSasToken"

Set-VstsTaskVariable -Name $outputStorageContainerSasToken -Value $ArtifactsLocationSasToken -Secret
Write-VstsTaskVerbose "outputStorageContainerSasToken: $ArtifactsLocationSasToken"

Trace-VstsLeavingInvocation $MyInvocation


