[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $AzureCostLink
)

$SplitWord = "/view/"
# Get the raw ViewConfiguration
$ViewConfiguration = $AzureCostLink.Substring(($AzureCostLink.IndexOf($SplitWord) + $SplitWord.Length))

# Decode the raw ViewConfiguration
$DecoedeViewConfiguration = [uri]::UnescapeDataString($ViewConfiguration)

# Base64 decode the ViewConfiguration
$data = [System.Convert]::FromBase64String("$DecoedeViewConfiguration")

# And then we decompress the string
$ms = New-Object IO.MemoryStream
$ms.Write($data, 0, $data.Length)
$ms.Seek(0, 0) | Out-Null
$cs = New-Object IO.Compression.GZipStream($ms, [IO.Compression.CompressionMode]::Decompress)
$sr = New-Object IO.StreamReader($cs)
$RawJsonPayload = $sr.readtoend()

# Convert to Json for pretty print
$RawJsonPayload | ConvertFrom-Json -Depth 100 | ConvertTo-Json -Depth 100