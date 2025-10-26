#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

# Enable Docker BuildKit
$env:DOCKER_BUILDKIT = '1'

# detect architecture
if (Get-Command uname -ErrorAction SilentlyContinue) {
    $arch = (uname -m).Trim()
} else {
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
}

switch ($arch) {
    'x86_64' { $platform = 'linux/amd64' }
    'amd64'  { $platform = 'linux/amd64' }
    'aarch64'{ $platform = 'linux/arm64' }
    'arm64'  { $platform = 'linux/arm64' }
    default  {
        Write-Warning "Unknown arch '$arch', defaulting to linux/amd64"
        $platform = 'linux/amd64'
    }
}

Write-Output "Building hadoop:base for platform: $platform"
& docker buildx build --network host --progress=plain --debug --platform=$platform --load -t hadoop:base -f ./docker/Dockerfiles/Dockerfile.base .

# Build additional Dockerfiles in docker/Dockerfiles named Dockerfile.<name>
Get-ChildItem -Path ./docker/Dockerfiles -Filter 'Dockerfile.*' -File | ForEach-Object {
    if ($_.Name -eq 'Dockerfile.base') { return }
    $name = $_.Name -replace '^Dockerfile\.', ''
    $tag = "hadoop:$name"
    Write-Output "Building $tag from $($_.FullName) for platform: $platform"
    & docker buildx build --network host --progress=plain --debug --platform=$platform --load -t $tag -f $_.FullName .
}

# Start compose (will use built images)
& docker compose up -d --build
```// filepath: /Users/trytry/coding/hdfs_local/run.ps1
#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

# Enable Docker BuildKit
$env:DOCKER_BUILDKIT = '1'

# detect architecture
if (Get-Command uname -ErrorAction SilentlyContinue) {
    $arch = (uname -m).Trim()
} else {
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
}

switch ($arch) {
    'x86_64' { $platform = 'linux/amd64' }
    'amd64'  { $platform = 'linux/amd64' }
    'aarch64'{ $platform = 'linux/arm64' }
    'arm64'  { $platform = 'linux/arm64' }
    default  {
        Write-Warning "Unknown arch '$arch', defaulting to linux/amd64"
        $platform = 'linux/amd64'
    }
}

Write-Output "Building hadoop:base for platform: $platform"
& docker buildx build --network host --progress=plain --debug --platform=$platform --load -t hadoop:base -f ./docker/Dockerfiles/Dockerfile.base .

# Build additional Dockerfiles in docker/Dockerfiles named Dockerfile.<name>
Get-ChildItem -Path ./docker/Dockerfiles -Filter 'Dockerfile.*' -File | ForEach-Object {
    if ($_.Name -eq 'Dockerfile.base') { return }
    $name = $_.Name -replace '^Dockerfile\.', ''
    $tag = "hadoop:$name"
    Write-Output "Building $tag from $($_.FullName) for platform: $platform"
    & docker buildx build --network host --progress=plain --debug --platform=$platform --load -t $tag -f $_.FullName .
}

# Start compose (will use built images)
& docker compose up -d --build