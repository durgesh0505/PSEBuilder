# Create Test Image for PowerShell Executor Builder Demo
# This script creates a simple test image (image.png) for the demo application

Add-Type -AssemblyName System.Drawing

try {
    # Create a simple test image
    $width = 400
    $height = 300
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # Fill background with light blue
    $backgroundBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::LightBlue)
    $graphics.FillRectangle($backgroundBrush, 0, 0, $width, $height)

    # Create font and brushes
    $font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::DarkBlue)
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::Navy, 3)

    # Draw border
    $graphics.DrawRectangle($borderPen, 5, 5, $width - 10, $height - 10)

    # Draw text
    $text1 = "PowerShell Executor Builder"
    $text2 = "Test Image Resource"
    $text3 = "Successfully Loaded!"

    $graphics.DrawString($text1, $font, $textBrush, 50, 80)
    $graphics.DrawString($text2, $font, $textBrush, 80, 120)
    $graphics.DrawString($text3, $font, $textBrush, 90, 160)

    # Draw some shapes
    $shapeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Green)
    $graphics.FillEllipse($shapeBrush, 50, 200, 60, 60)
    $graphics.FillRectangle($shapeBrush, 150, 200, 60, 60)
    $graphics.FillPolygon($shapeBrush, @(
        [System.Drawing.Point]::new(280, 200),
        [System.Drawing.Point]::new(310, 260),
        [System.Drawing.Point]::new(250, 260)
    ))

    # Save as PNG
    $outputPath = Join-Path $PSScriptRoot "image.png"
    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    Write-Host "Test image created successfully: $outputPath" -ForegroundColor Green

    # Cleanup
    $graphics.Dispose()
    $bitmap.Dispose()
    $backgroundBrush.Dispose()
    $font.Dispose()
    $textBrush.Dispose()
    $borderPen.Dispose()
    $shapeBrush.Dispose()

} catch {
    Write-Host "Error creating test image: $($_.Exception.Message)" -ForegroundColor Red
}