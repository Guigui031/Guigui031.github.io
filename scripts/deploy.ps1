<#
.SYNOPSIS
    Builds the site and deploys dist/ to the web server over SSH.

.DESCRIPTION
    Runs `pnpm build`, packages dist/, uploads it, and syncs it into the remote
    webroot with rsync --delete so removed pages disappear. The remote
    .well-known directory (ACME/SSL challenges) is never touched.

    Server details live in deploy.config.json at the repo root, which is
    gitignored so they stay out of this public repository. Create it from
    deploy.config.example.json.

.PARAMETER DryRun
    Show exactly which files rsync would add, change, and delete, then stop
    without modifying the server.

.PARAMETER SkipBuild
    Deploy the existing dist/ without rebuilding.

.PARAMETER Force
    Deploy even if the local branch is behind its remote or the working tree
    has uncommitted changes.

.EXAMPLE
    pnpm run deploy:check     # preview the changes
    pnpm run deploy           # build and deploy
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$SkipBuild,
    [switch]$Force,
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not $ConfigPath) { $ConfigPath = Join-Path $RepoRoot 'deploy.config.json' }

function Fail($message) {
    Write-Host "ERROR: $message" -ForegroundColor Red
    exit 1
}

function Step($message) {
    Write-Host ""
    Write-Host "==> $message" -ForegroundColor Cyan
}

# ---------------------------------------------------------------- config ----

if (-not (Test-Path $ConfigPath)) {
    Fail "No config at $ConfigPath. Copy deploy.config.example.json to deploy.config.json and fill in your server details."
}

$cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
foreach ($key in @('SshUser', 'SshHost', 'SshKey', 'RemotePath', 'RemoteOwner')) {
    if (-not $cfg.$key) { Fail "deploy.config.json is missing '$key'." }
}

$SshKey = $cfg.SshKey -replace '^~', $HOME
if (-not (Test-Path $SshKey)) { Fail "SSH key not found: $SshKey" }

$Target = "$($cfg.SshUser)@$($cfg.SshHost)"
$RemotePath = $cfg.RemotePath.TrimEnd('/')

# ------------------------------------------------------------ git guards ----

# The local checkout falling behind the remote is the dangerous case: building
# from a stale tree and syncing with --delete would remove live pages.
Step "Checking repository state"
Push-Location $RepoRoot
try {
    & git fetch --quiet
    $behind = (& git rev-list --count 'HEAD..@{u}' 2>$null)
    if ($LASTEXITCODE -eq 0 -and [int]$behind -gt 0) {
        if ($Force) {
            Write-Host "    WARNING: local branch is $behind commit(s) behind its remote (--Force)." -ForegroundColor Yellow
        }
        else {
            Fail "Local branch is $behind commit(s) behind its remote. Run 'git pull' first, or pass -Force."
        }
    }

    $dirty = & git status --porcelain
    if ($dirty) {
        Write-Host "    Note: working tree has uncommitted changes; deploying them anyway." -ForegroundColor Yellow
    }

    $sha = (& git rev-parse --short HEAD).Trim()
    Write-Host "    Deploying from $sha"
}
finally {
    Pop-Location
}

# ----------------------------------------------------------------- build ----

$DistPath = Join-Path $RepoRoot 'dist'

if ($SkipBuild) {
    Step "Skipping build (-SkipBuild)"
}
else {
    Step "Building site"
    Push-Location $RepoRoot
    try {
        if (Get-Command pnpm -ErrorAction SilentlyContinue) {
            & pnpm run build
        }
        else {
            # pnpm is not on PATH here; corepack ships with Node and provides it.
            & corepack pnpm run build
        }
        if ($LASTEXITCODE -ne 0) { Fail "Build failed." }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path (Join-Path $DistPath 'index.html'))) {
    Fail "dist/index.html is missing - refusing to deploy an incomplete build."
}
$fileCount = (Get-ChildItem $DistPath -Recurse -File).Count
if ($fileCount -lt 20) {
    Fail "dist/ has only $fileCount files, which looks wrong - refusing to sync with --delete."
}
Write-Host "    dist/ contains $fileCount files"

# ---------------------------------------------------------------- upload ----

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$remoteTar = "/tmp/site-$stamp.tgz"
$remoteDir = "/tmp/site-$stamp"
$localTar = Join-Path $env:TEMP "site-$stamp.tgz"

Step "Packaging and uploading"
& tar -czf $localTar -C $DistPath .
if ($LASTEXITCODE -ne 0) { Fail "Failed to package dist/." }

& scp -i $SshKey -q $localTar "${Target}:$remoteTar"
if ($LASTEXITCODE -ne 0) { Fail "Upload failed." }
Remove-Item $localTar -Force
Write-Host "    Uploaded to ${Target}:$remoteTar"

# ---------------------------------------------------------------- deploy ----

# Compare by checksum (-c) rather than size+mtime: a Windows-produced tarball
# gives every file fresh timestamps and arbitrary permission bits, so the
# default quick check would report the entire site as changed on every run.
# Forcing perms to D755/F644 keeps them stable too, which leaves --itemize-changes
# listing only files whose contents actually differ.
$rsyncFlags = "-rlc --delete --itemize-changes --perms --chmod=D755,F644 --no-owner --no-group --no-times --exclude='.well-known' --exclude='.git'"
if ($DryRun) { $rsyncFlags = "$rsyncFlags --dry-run" }

# Base64-encode the remote script so no quoting survives the trip through
# PowerShell, ssh, and bash to mangle it.
$remoteScript = @"
set -e
rm -rf '$remoteDir'
mkdir -p '$remoteDir'
tar xzf '$remoteTar' -C '$remoteDir'
rsync $rsyncFlags '$remoteDir/' '$RemotePath/'
"@

if (-not $DryRun) {
    $remoteScript += "`nchown -R $($cfg.RemoteOwner) '$RemotePath/'"
}
$remoteScript += "`nrm -rf '$remoteDir' '$remoteTar'"

$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($remoteScript -replace "`r`n", "`n")))

if ($DryRun) {
    Step "Dry run - previewing changes (nothing will be modified)"
}
else {
    Step "Syncing to $RemotePath"
}

& ssh -i $SshKey $Target "echo $encoded | base64 -d | bash"
if ($LASTEXITCODE -ne 0) { Fail "Deploy failed on the server." }

if ($DryRun) {
    Write-Host ""
    Write-Host "Dry run complete - the server was not modified." -ForegroundColor Yellow
    Write-Host "Legend: '>f+++++++++' adds a file, '>fc........' changes one," -ForegroundColor DarkGray
    Write-Host "        '*deleting' removes one. No lines above means the server is up to date." -ForegroundColor DarkGray
    exit 0
}

# ---------------------------------------------------------------- verify ----

if ($cfg.SiteUrl) {
    Step "Verifying $($cfg.SiteUrl)"
    try {
        $response = Invoke-WebRequest -Uri $cfg.SiteUrl -UseBasicParsing -TimeoutSec 30
        Write-Host "    HTTP $($response.StatusCode)" -ForegroundColor Green
    }
    catch {
        Write-Host "    WARNING: could not reach the site: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Deployed $sha to $($cfg.SshHost):$RemotePath" -ForegroundColor Green
