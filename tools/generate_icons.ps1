#!/usr/bin/env pwsh
<#
Generate PNG icons from `assets/storebill_icon.svg`.

Usage:
  Open PowerShell and run:
    pwsh .\tools\generate_icons.ps1

Requires ImageMagick (`magick`) or Inkscape (`inkscape`) installed and on PATH.
#>

$ErrorActionPreference = 'Stop'

$svg = Join-Path $PSScriptRoot '..\assets\storebill_icon.svg'
$out512 = Join-Path $PSScriptRoot '..\assets\storebill_512.png'
$out1024 = Join-Path $PSScriptRoot '..\assets\storebill_1024.png'

Write-Host "SVG source: $svg"

if (Test-Path $svg -PathType Leaf) {
  if (Get-Command magick -ErrorAction SilentlyContinue) {
    Write-Host "Using ImageMagick (magick) to generate PNGs..."
    magick convert "$svg" -resize 512x512 "$out512"
    magick convert "$svg" -resize 1024x1024 "$out1024"
    Write-Host "Generated: $out512`nGenerated: $out1024"
    exit 0
  }

  if (Get-Command inkscape -ErrorAction SilentlyContinue) {
    Write-Host "Using Inkscape to generate PNGs..."
    inkscape "$svg" --export-filename="$out512" --export-width=512 --export-height=512
    inkscape "$svg" --export-filename="$out1024" --export-width=1024 --export-height=1024
    Write-Host "Generated: $out512`nGenerated: $out1024"
    exit 0
  }

  Write-Error "Neither ImageMagick (magick) nor Inkscape found on PATH. Install one of them and re-run this script."
  exit 2
} else {
  Write-Error "SVG source not found: $svg"
  exit 1
}
