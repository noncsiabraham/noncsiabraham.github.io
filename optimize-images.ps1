# Image Optimization Script for Web
# This script resizes and compresses images for optimal web performance

# Configuration
$sourceFolder = ".\images"
$outputFolder = ".\images-optimized"
$maxWidth = 1600           # Maximum width in pixels
$quality = 75              # JPEG quality (1-100, lower = smaller file)

# Create output folder if it doesn't exist
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
    Write-Host "✓ Created output folder: $outputFolder" -ForegroundColor Green
}

# Check if ImageMagick is installed
try {
    $magickVersion = magick -version 2>$null
    if (-not $magickVersion) {
        throw "ImageMagick not found"
    }
} catch {
    Write-Host "❌ ImageMagick is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install ImageMagick first:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://imagemagick.org/script/download.php#windows" -ForegroundColor Cyan
    Write-Host "2. Run the installer (choose 'Install legacy utilities' option)" -ForegroundColor Cyan
    Write-Host "3. Restart PowerShell and run this script again" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Alternative: Use the manual method below" -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting image optimization..." -ForegroundColor Cyan
Write-Host "Source: $sourceFolder" -ForegroundColor Gray
Write-Host "Output: $outputFolder" -ForegroundColor Gray
Write-Host "Max width: ${maxWidth}px, Quality: ${quality}%" -ForegroundColor Gray
Write-Host ""

# Process all image files
$imageFiles = Get-ChildItem -Path $sourceFolder -Include *.jpg,*.jpeg,*.png,*.JPG,*.JPEG,*.PNG -File
$count = 0
$totalSize = 0
$optimizedSize = 0

foreach ($file in $imageFiles) {
    $count++
    $inputPath = $file.FullName
    $outputPath = Join-Path $outputFolder $file.Name
    $originalSize = (Get-Item $inputPath).Length
    
    Write-Host "[$count/$($imageFiles.Count)] Processing: $($file.Name)..." -NoNewline
    
    try {
        # Resize and compress
        # -resize: shrinks only if larger than max width, maintains aspect ratio
        # -quality: compression level
        # -strip: removes metadata to reduce file size
        magick convert "$inputPath" -resize "${maxWidth}x>" -quality $quality -strip "$outputPath" 2>$null
        
        $newSize = (Get-Item $outputPath).Length
        $savings = [math]::Round((($originalSize - $newSize) / $originalSize) * 100, 1)
        
        $totalSize += $originalSize
        $optimizedSize += $newSize
        
        Write-Host " ✓ " -ForegroundColor Green -NoNewline
        Write-Host "Saved ${savings}% " -ForegroundColor Yellow -NoNewline
        Write-Host "($([math]::Round($originalSize/1KB, 0))KB → $([math]::Round($newSize/1KB, 0))KB)" -ForegroundColor Gray
        
    } catch {
        Write-Host " ✗ Error" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Optimization Complete!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Files processed: $count" -ForegroundColor White
Write-Host "Original size:   $([math]::Round($totalSize/1MB, 2)) MB" -ForegroundColor White
Write-Host "Optimized size:  $([math]::Round($optimizedSize/1MB, 2)) MB" -ForegroundColor White
Write-Host "Total saved:     $([math]::Round(($totalSize - $optimizedSize)/1MB, 2)) MB ($([math]::Round((($totalSize - $optimizedSize) / $totalSize) * 100, 1))%)" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review optimized images in '$outputFolder'" -ForegroundColor Cyan
Write-Host "2. If satisfied, replace original images:" -ForegroundColor Cyan
Write-Host "   Copy-Item '$outputFolder\*' '$sourceFolder' -Force" -ForegroundColor Gray
Write-Host "3. Update your HTML if needed" -ForegroundColor Cyan
Write-Host ""
