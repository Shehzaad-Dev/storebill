param(
  [string]$Owner = 'Shehzaad-Dev',
  [string]$Repo = 'storebill',
  [string]$Tag = 'v1.0.0',
  [string]$ReleaseName = 'StoreBill v1.0.0 Stable Release',
  [string]$NotesFile = 'RELEASE_NOTES.md',
  [string]$Apk = 'release_artifacts/app-release.apk',
  [string]$Aab = 'release_artifacts/app-release.aab'
)

if (-not $Env:GITHUB_TOKEN) {
  Write-Error "GITHUB_TOKEN environment variable not set. Export a PAT with repo scope and re-run."
  exit 1
}

$token = $Env:GITHUB_TOKEN
$baseUrl = "https://api.github.com/repos/$Owner/$Repo"
$body = @{ tag_name = $Tag; name = $ReleaseName; body = (Get-Content -Raw $NotesFile); draft = $false; prerelease = $false } | ConvertTo-Json

# Create release
$create = Invoke-RestMethod -Headers @{ Authorization = "token $token"; Accept = 'application/vnd.github.v3+json' } -Method Post -Uri "$baseUrl/releases" -Body $body
$uploadUrl = $create.upload_url -replace '\{\?name,label\}',''

# Upload assets
function Upload-Asset($filePath){
  if (-not (Test-Path $filePath)) { Write-Host "Skipping missing $filePath"; return }
  $name = [System.IO.Path]::GetFileName($filePath)
  $url = "$uploadUrl?name=$name"
  Invoke-RestMethod -Headers @{ Authorization = "token $token"; Accept = 'application/vnd.github.v3+json' } -Method Post -Uri $url -InFile $filePath -ContentType "application/octet-stream"
  Write-Host "Uploaded $name"
}

Upload-Asset $Apk
Upload-Asset $Aab

Write-Host "Release created: $($create.html_url)"
