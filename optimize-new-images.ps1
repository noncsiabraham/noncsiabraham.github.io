# Optimize Only New/Unoptimized Images
# This script only processes images that haven't been optimized yet

$sourceFolder = ".\images"
$maxWidth = 1600
$quality = 75
$logFile = ".\optimized-images.log"

# Create/read log of optimized images
if (Test-Path $logFile) {
    $optimizedFiles = Get-Content $logFile
} else {
    $optimizedFiles = @()
}

Write-Host "Checking for new images to optimize..." -ForegroundColor Cyan
Write-Host ""

$imageFiles = Get-ChildItem -Path $sourceFolder -Include *.jpg,*.jpeg,*.png,*.JPG,*.JPEG,*.PNG -File
$newImages = $imageFiles | Where-Object { $_.Name -notin $optimizedFiles }

if ($newImages.Count -eq 0) {
    Write-Host "No new images to optimize!" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($newImages.Count) new image(s) to optimize" -ForegroundColor Yellow
Write-Host ""

$count = 0
$totalSaved = 0

foreach ($file in $newImages) {
    $count++
    $inputPath = $file.FullName
    $tempPath = Join-Path $sourceFolder "_temp_$($file.Name)"
    $originalSize = (Get-Item $inputPath).Length
    
    Write-Host "[$count/$($newImages.Count)] Optimizing: $($file.Name)..." -NoNewline
    
    try {
        # Optimize to temporary file
        magick convert "$inputPath" -resize "${maxWidth}x>" -quality $quality -strip "$tempPath" 2>$null
        
        $newSize = (Get-Item $tempPath).Length
        $savings = [math]::Round((($originalSize - $newSize) / $originalSize) * 100, 1)
        
        # Replace original with optimized
        Move-Item $tempPath $inputPath -Force
        
        # Add to log
        Add-Content -Path $logFile -Value $file.Name
        
        $totalSaved += ($originalSize - $newSize)
        
        Write-Host " Saved ${savings}% " -ForegroundColor Yellow -NoNewline
        Write-Host "($([math]::Round($originalSize/1KB, 0))KB to $([math]::Round($newSize/1KB, 0))KB)" -ForegroundColor Gray
        
    } catch {
        Write-Host " Error" -ForegroundColor Red
        if (Test-Path $tempPath) { Remove-Item $tempPath }
    }
}

Write-Host ""
Write-Host "Optimization Complete!" -ForegroundColor Green
Write-Host "Files optimized: $count" -ForegroundColor White
Write-Host "Total saved: $([math]::Round($totalSaved/1MB, 2)) MB" -ForegroundColor Green
Write-Host ""
