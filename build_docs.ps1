$ErrorActionPreference = "Stop"

$notebooks = @(
    "01_unitary_transform.ipynb",
    "02_cholesky_decomposition.ipynb",
    "03_jacobi_evd.ipynb",
    "04_cordic.ipynb",
    "index.ipynb"
)

$titles = @{
    "01_unitary_transform.html"         = "Unitary Transform"
    "02_cholesky_decomposition.html"    = "Cholesky Decomposition"
    "03_jacobi_evd.html"                = "Jacobi Rotation for EVD"
    "04_cordic.html"                    = "CORDIC"
    "index.html"                    = "index"
}

$inputDir = ".\notebooks"
$outputDir = ".\docs"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

foreach ($notebook in $notebooks) {
    $path = Join-Path $inputDir $notebook

    if (-not (Test-Path $path)) {
        Write-Warning "Skipping missing notebook: $path"
        continue
    }

    Write-Host "Converting $notebook..."

    jupyter nbconvert `
        --to html `
        --template classic `
        $path `
        --output-dir $outputDir

    if ($LASTEXITCODE -ne 0) {
        throw "Conversion failed for $notebook"
    }
}

Write-Host "All notebook pages were generated in $outputDir"


Get-ChildItem .\docs\*.html | ForEach-Object {

    $content = Get-Content $_.FullName -Raw

    # Fix published image paths
    $content = $content.Replace(
        '../docs/images/',
        'images/'
    )

    # Set browser tab title
    if ($titles.ContainsKey($_.Name)) {

        $pageTitle = $titles[$_.Name]

        $content = $content -replace `
            '<title>.*?</title>', `
            "<title>$pageTitle</title>"
    }

    [System.IO.File]::WriteAllText(
        $_.FullName,
        $content,
        [System.Text.UTF8Encoding]::new($false)
    )
}