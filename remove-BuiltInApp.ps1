<#
.SYNOPSIS
    Remove a built-in app from Windows 10.
.DESCRIPTION
    This script can be used to remove a single built in app. 
    For a more detailed list of applications available in each version of Windows 10, refer to the documentation here:
    https://docs.microsoft.com/en-us/windows/application-management/apps-in-windows-10

    This script was created as a fork of other work. If you would like to comprehensively remove applications from Windows environments, 
    please visit the creator's github. 
    https://github.com/MSEndpointMgr/ConfigMgr/blob/master/Operating%20System%20Deployment/Invoke-RemoveBuiltinApps.ps1
.EXAMPLE
    .\remove-BuiltinApp.ps1
.NOTES
    FileName:    remove-BuiltinApp.ps1
    Author:      Blake Fox
    Contact:     bfox@adaptivedge.com

    Version history:
    1.0.0 -  Fork of https://github.com/MSEndpointMgr/ConfigMgr/blob/master/Operating%20System%20Deployment/Invoke-RemoveBuiltinApps.ps1
#>

Begin {
    
    #establish the app to be removed via its common package name
    $App = "microsoft.windowscommunicationsapps"
}

Process {

    # Functions
    function Write-LogEntry {
        param(
            [parameter(Mandatory=$true, HelpMessage="Value added to the RemovedApps.log file.")]
            [ValidateNotNullOrEmpty()]
            [string]$Value,

            [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
            [ValidateNotNullOrEmpty()]
            [string]$FileName = "RemovedApps.log"
        )
        # Determine log file location
        $LogFilePath = Join-Path -Path $env:windir -ChildPath "Temp\$($FileName)"

        # Add value to log file
        try {
            Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to append log entry to $($FileName) file"
        }
    }

    # Initial logging
    Write-LogEntry -Value "Starting built-in AppxPackage removal"
    Write-LogEntry -Value "Processing appx package: $App..."

    #remove the application
    $AppPackageFullName = Get-AppxPackage -Name $App | Select-Object -ExpandProperty PackageFullName -First 1
    if ($AppPackageFullName -ne $null) {
        try {
            Remove-AppxPackage -Package $AppPackageFullName -ErrorAction Stop | Out-Null
            Write-LogEntry -Value "AppxPackage for $($App) removed"
        }
        catch [System.Exception]{
            Write-LogEntry -Value "Removing AppxPackage '$AppPackageFullName' failed: $($Exception.Message)"
        }
    }
    else {
        Write-LogEntry -Value "Unable to locate AppxPackage for current app: $($App)"
    }
}
