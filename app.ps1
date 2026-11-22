param([Parameter(Mandatory=$true, Position=0)][string] $InputPath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
function Invoke-Analysis($data) {
    $limit = $data['max_gap_days']
    $releases = $data['releases']
    if ($null -eq $limit -or [int]$limit -lt 0 -or $releases -isnot [array]) { throw 'Enter a gap threshold and release dates' }
    $counts = [System.Collections.Generic.SortedDictionary[string, int]]::new()
    $dates = [System.Collections.Generic.Dictionary[string, DateTime]]::new()
    foreach ($release in $releases) {
        $date = [DateTime]::ParseExact([string]$release, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)
        $key = $date.ToString('yyyy-MM-dd', [cultureinfo]::InvariantCulture)
        if (!$counts.ContainsKey($key)) { $counts.Add($key, 0); $dates.Add($key, $date) }
        $counts[$key]++
    }
    $gap = [System.Collections.Generic.List[object]]::new()
    $previous = $null
    foreach ($key in $counts.Keys) {
        if ($previous) {
            $days = ($dates[$key] - $dates[$previous]).Days
            if ($days -gt [int]$limit) { $gap.Add(@($previous, $key, $days)) }
        }
        $previous = $key
    }
    @{ long_gaps = $gap.ToArray(); same_day = @($counts.Keys | Where-Object { $counts[$_] -gt 1 }) }
}

try {
    $payload = Get-Content -LiteralPath $InputPath -Raw | ConvertFrom-Json -AsHashtable
    if ($payload -isnot [System.Collections.IDictionary]) { throw 'Input must be a JSON object' }
    Invoke-Analysis $payload | ConvertTo-Json -Depth 30 -Compress
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
