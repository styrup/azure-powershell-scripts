[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $subid,
  [string]
  $linkSuffix
)
<# This might work...
$doc = @{}
$doc.Add("currency", "DKK")
$doc.Add("dateRange", "Last30Days")


$totalCost = @{"name" = "PreTaxCost"; "function" = "Sum" }
$totalCostUSD = @{"name" = "PreTaxCostUSD"; "function" = "Sum" }
$sorting = @(@{ "direction" = "ascending"; "name" = "UsageDate" })
$grouping = @(@{ "type" = "Dimension"; "name" = "ResourceGroupName" })
$query = @{"type" = "ActualCost"; "dataSet" = @{"granularity" = "Daily"; "aggregation" = @{"totalCost" = $totalCost; "totalCostUSD" = $totalCostUSD }; "sorting" = $sorting; "grouping" = $grouping }; "timeframe" = "None" }
$doc.Add("query", $query)

$doc.Add("chart", "StackedColumn")
$doc.Add("accumulated", "false")

$pivots = @(@{"type" = "Dimension"; "name" = "ServiceName" }, @{"type" = "Dimension"; "name" = "ResourceLocation" }, @{"type" = "Dimension"; "name" = "ResourceGroupName" })
$doc.Add("pivots", $pivots)
$doc.Add("scope", "subscriptions/$subid")
$kpis = @(@{"type" = "Forecast"; "enabled" = $false })
$doc.Add("kpis", $kpis)
$doc.Add("displayName", "DailyCosts")
$s = $doc | ConvertTo-Json -Depth 100

#>
$data = '{
  "currency": "DKK",
  "dateRange": "Last30Days",
  "query": {
    "type": "ActualCost",
    "dataSet": {
      "granularity": "Daily",
      "aggregation": {
        "totalCost": {
          "name": "PreTaxCost",
          "function": "Sum"
        },
        "totalCostUSD": {
          "name": "PreTaxCostUSD",
          "function": "Sum"
        }
      },
      "sorting": [
        {
          "direction": "ascending",
          "name": "UsageDate"
        }
      ],
      "grouping": [
        {
          "type": "Dimension",
          "name": "ResourceGroupName"
        }
      ]
    },
    "timeframe": "None"
  },
  "chart": "StackedColumn",
  "accumulated": "false",
  "pivots": [
    {
      "type": "Dimension",
      "name": "ServiceName"
    },
    {
      "type": "Dimension",
      "name": "ResourceLocation"
    },
    {
      "type": "Dimension",
      "name": "ResourceGroupName"
    }
  ],
  "scope": "subscriptions/' + $subid + '",
  "kpis": [
    {
      "type": "Forecast",
      "enabled": false
    }
  ],
  "displayName": "DailyCosts"
}'
$ms = New-Object System.IO.MemoryStream
$cs = New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Compress)
$sw = New-Object System.IO.StreamWriter($cs)
$sw.Write($data)
$sw.Flush()
$sw.Close();
$s = [System.Convert]::ToBase64String($ms.ToArray())
$link = "https://portal.azure.com#@$($linkSuffix)/blade/Microsoft_Azure_CostManagement/Menu/open/CostAnalysis/scope/%2Fsubscriptions%2F$subid/view/$([uri]::EscapeDataString($s))"
$link