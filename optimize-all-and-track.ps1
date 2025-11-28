# Optimize all images and create tracking log
$sourceFolder = ".\images"
$maxWidth = 1600
$quality = 75
$logFile = ".\optimized-images.log"

Write-Host "Optimizing all images in place..." -ForegroundColor Cyan
Write-Host ""

$imageFiles = Get-ChildItem -Path $sourceFolder -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' }
$count = 0
$totalOriginal = 0
$totalOptimized = 0

foreach ($file in $imageFiles) {
    $count++
    $inputPath = $file.FullName
    $tempPath = Join-Path $sourceFolder "_temp_$($file.Name)"
    $originalSize = $file.Length
    
    Write-Host "[$count/$($imageFiles.Count)] $($file.Name)..." -NoNewline
    
    try {
        magick convert "$inputPath" -resize "${maxWidth}x>" -quality $quality -strip "$tempPath" 2>$null
        
        $newSize = (Get-Item $tempPath).Length
        $savings = [math]::Round((($originalSize - $newSize) / $originalSize) * 100, 1)
        
        Move-Item $tempPath $inputPath -Force
        Add-Content -Path $logFile -Value $file.Name
        
        $totalOriginal += $originalSize
        $totalOptimized += $newSize
        
        Write-Host " Saved ${savings}% ($([math]::Round($originalSize/1KB,0))KB to $([math]::Round($newSize/1KB,0))KB)" -ForegroundColor Green
        
    } catch {
        Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
        if (Test-Path $tempPath) { Remove-Item $tempPath }
    }
}

Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
Write-Host "Files: $count" -ForegroundColor White
Write-Host "Original: $([math]::Round($totalOriginal/1MB,2)) MB" -ForegroundColor White
Write-Host "Optimized: $([math]::Round($totalOptimized/1MB,2)) MB" -ForegroundColor White  
Write-Host "Saved: $([math]::Round(($totalOriginal-$totalOptimized)/1MB,2)) MB ($([math]::Round((($totalOriginal-$totalOptimized)/$totalOriginal)*100,1))%)" -ForegroundColor Yellow
Write-Host ""
