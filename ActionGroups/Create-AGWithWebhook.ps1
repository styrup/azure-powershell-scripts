[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $subscriptionID,
    [string]
    $AGName,
    [string]
    $AGShortName,
    [string]
    $AGResourceGroupName,
    [string]
    $WebHookURL,
    [string]
    $AGResourceGroupLocation = "westeurope"
)

Set-AzContext -SubscriptionId $subscriptionID

$CRG = $null 
$CRG = Get-AzResourceGroup -Name $AGResourceGroupName -ErrorAction Ignore
if ($null -eq $CRG) {
    $CRG = New-AzResourceGroup -Name $AGResourceGroupName -Location $AGResourceGroupLocation
}

$ActionGroupReceiver = New-AzActionGroupReceiver -Name "$($AGName)-webhook" -UseCommonAlertSchema -WebhookReceiver -ServiceUri $WebHookURL
Set-AzActionGroup -ResourceGroupName $CRG.ResourceGroupName -Name $AGName -ShortName $AGShortName -Receiver $ActionGroupReceiver