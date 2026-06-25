# SonarCloud local scan script
# Prerequisites:
#   1. Java 17+ installed (JAVA_HOME set)
#   2. sonar-scanner installed — download from:
#      https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/
#   3. SONAR_TOKEN env var set — get it from:
#      SonarCloud → My Account → Security → Generate Tokens
#
# Usage:
#   $env:SONAR_TOKEN = "your_token_here"
#   .\scripts\sonar-scan.ps1

$ErrorActionPreference = "Stop"

# Verify sonar-scanner is available
if (-not (Get-Command sonar-scanner -ErrorAction SilentlyContinue)) {
    Write-Error "sonar-scanner not found in PATH. Download from https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/"
    exit 1
}

# Verify token
if (-not $env:SONAR_TOKEN) {
    Write-Error "SONAR_TOKEN env var not set. Get it from SonarCloud → My Account → Security → Generate Tokens"
    exit 1
}

Write-Host "Running dart analyze..." -ForegroundColor Cyan
Push-Location app
$env:Path = "D:\flutter\bin;$env:Path"
dart analyze --format=json > ..\dart-analyze.json 2>&1
Pop-Location

Write-Host "Running SonarCloud scanner..." -ForegroundColor Cyan
sonar-scanner "-Dsonar.login=$env:SONAR_TOKEN" "-Dsonar.host.url=https://sonarcloud.io"

Write-Host "Done. View results at https://sonarcloud.io/project/overview?id=tatatitutatuay_mealtion" -ForegroundColor Green
