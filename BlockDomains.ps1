# =============================
# CONFIG
# =============================
$policyId = "a5bb37c1-1165-4ec2-a930-4fba896ce7de"
$path     = "C:\Users\Ninavi\Documents\"
$fileList = @("blocked_domains_part1.txt", "blocked_domains_part2.txt") # List of domain files
 
# =============================
# CONNECT
# =============================
Connect-MgGraph -Scopes "Policy.ReadWrite.B2BManagementPolicy"
 
# =============================
# LOAD AND COMBINE DOMAINS (TXT)
# =============================
$allDomains = @()
foreach ($file in $fileList) {
    $domains = Get-Content (Join-Path $path $file) |
        ForEach-Object { $_.Trim().ToLower() } |
        Where-Object { $_ -and $_ -notmatch '^\s*#' } |
        Sort-Object -Unique
    
    # Add the domains from this file to the cumulative list
    $allDomains += $domains
}

# Remove duplicates from the combined list of domains
$allDomains = $allDomains | Sort-Object -Unique

Write-Host "Total domains loaded: $($allDomains.Count)"

# =============================
# BUILD BODY
# =============================
$innerPolicy = @{
    B2BManagementPolicy = @{
        InvitationsAllowedAndBlockedDomainsPolicy = @{
            BlockedDomains = $allDomains
        }
        AutoRedeemPolicy = @{
            AdminConsentedForUsersIntoTenantIds = @()
            NoAADConsentForUsersFromTenantsIds  = @()
        }
    }
} | ConvertTo-Json -Compress -Depth 20
 
$body = @{
    definition = @($innerPolicy)
} | ConvertTo-Json -Compress -Depth 20
 
# =============================
# SIZE CHECK
# =============================
$charCount = $body.Length
Write-Host "Policy JSON size (characters): $charCount"
 
if ($charCount -gt 25000) {
    Write-Warning "❌ Policy exceeds 25,000 character limit. Graph call will fail."
    return
}
 
# =============================
# PATCH
# =============================
$uri = "https://graph.microsoft.com/beta/policies/b2bManagementPolicies/$policyId"
 
Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType "application/json"
Write-Host "✅ Policy updated"
