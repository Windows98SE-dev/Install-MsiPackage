<#
    .SYNOPSIS
        Installs .msi Packages
    .DESCRIPTION
        Allows the installation of .msi packages through msiexec. Parses the MSI path and accepts msiexec options.
    .EXAMPLE
        Install-MsiPackage C:\temp\PowerShell-7.6.0-win-x64.msi
    .EXAMPLE
        Install-MsiPackage -Path C:\temp\OpenHashTab_Machine_x64.msi -installOptions "/quiet /norestart"
#>
function Install-MsiPackage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Path,

        [Parameter()]
        [String]$installOptions = "/passive /norestart"
    )

    if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        Write-Error "The specified file does not exist."
        return
    }

    if ([IO.Path]::GetExtension($Path).ToLower() -ne ".msi") {
        Write-Error "The file specified is not an .msi package"
        return
    }

    $argList = @("/package", "`"$Path`"", $installOptions)
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $argList -PassThru
    $proc.WaitForExit()
    $exitCode = $proc.ExitCode

    switch ($exitCode) {
        0 {
            Write-Host "Installation completed successfully." -ForegroundColor Green
        }
        3010 {
            Write-Host "Installation completed successfully but a reboot is required." -ForegroundColor Yellow
            $rebootNowValid = $false
            while (-not $rebootNowValid) {
                $rebootNow = Read-Host "Do you want to reboot now? (Y/N)"
                if ($rebootNow.ToUpper() -in @("Y","N")) { 
                    $rebootNowValid = $true 
                }
            }
            if ($rebootNow.ToUpper() -eq "Y") { 
                Restart-Computer 
            }
        }
        1654 {
            Write-Error "This installation package is not supported by this operating system or CPU architecture."
        }
        default {
            Write-Error "Installation failed with exit code $exitCode."
        }
    }
}

Install-MsiPackage