param(
  [string]$artifactPath,
  [string]$iisServer,
  [string]$appPoolName,
  [string]$targetPath,
  [string]$warmupUrl
)

Write-Host "Copying artifact to IIS server..."
Copy-Item -Path $artifactPath -Destination "\\$iisServer\$targetPath" -Recurse -Force

Write-Host "Stopping App Pool..."
Invoke-Command -ComputerName $iisServer -ScriptBlock {
  Import-Module WebAdministration
  Stop-WebAppPool -Name $using:appPoolName
}

Write-Host "Replacing folder contents..."
Invoke-Command -ComputerName $iisServer -ScriptBlock {
  Remove-Item "$using:targetPath\*" -Recurse -Force
  Copy-Item "$using:artifactPath\*" "$using:targetPath" -Recurse -Force
}

Write-Host "Starting App Pool..."
Invoke-Command -ComputerName $iisServer -ScriptBlock {
  Start-WebAppPool -Name $using:appPoolName
}

Write-Host "Warming up IIS site..."
Invoke-WebRequest -Uri $warmupUrl -UseBasicParsing
