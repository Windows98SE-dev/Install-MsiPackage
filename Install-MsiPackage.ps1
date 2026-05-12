<#
    .SYNOPSIS
        Installs .msi Packages
    .DESCRIPTION
        Allows the installation of .msi packages through the use of PowerShell 5.1+ and msiexec, the function allows for parsing msi packages and installation parameters
    .EXAMPLE
        Install-MsiPackage C:\temp\PowerShell-7.6.0-win-x64.msi
    .EXAMPLE
        Install-MsiPackage -Path C:\temp\OpenHashTab_Machine_x64.msi -installOptions "/quiet /norestart"
#>
function Install-MsiPackage
{
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory, Position=0)]
        [String]$Path,
        [Parameter()]
        [String]$installOptions = "/passive /norestart"
    )
    if (Test-Path $Path -ErrorAction SilentlyContinue) {
        if ((Get-ChildItem $Path -ErrorAction SilentlyContinue).Extension -eq ".msi") {
            $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/package", $Path, $installOptions -PassThru
            $exitCode = $proc.LastExitCode
            if ($exitCode -eq 0) {
                Write-Host "Installation completed successfully." -ForegroundColor Green
            }
            elseif ($exitCode -eq 3010) {
                Write-Host "Installation completed successfully but a reboot is required." -ForegroundColor Yellow
                $rebootNowValid = $false
                while (-not $rebootNowValid) {
                    $rebootNow = Read-Host "Do you want to reboot now? (Y/N)"
                    if ($rebootNow.ToUpper() -eq "Y" -or $rebootNow.ToUpper() -eq "N") {
                        $rebootNowValid = $true
                    }
                }
                if ($rebootNow.ToUpper() -eq "Y") {
                    Restart-Computer
                }
            }
            elseif ($exitCode -eq 1654) {
                Write-Error "This installation package is not supported by this operating system or CPU architecture."
            }
            else {
                Write-Error "Installation failed with exit code $exitCode."
            }
        }
    }
    else {
        Write-Error "The file specified is not an .msi package"
    }

    else {
        Write-Error "The specified file does not exist."
    }
}

Install-MsiPackage