#
#	Writes an event to OperationsManager event log to ask for
#       immediate rediscovery
#
#		System requirements: Powershell >= 2.0 / .NET >= 2.0
#
#		Parameters
#			$computerName		
#			$storename			e.g. My
#			$storeProvider		SystemRegistry | System | File | LDAP
#			$storeType			LocalMachine | CurrentUser | Services | Users
#
# Version 1.0 - 22. May 2015 - initial            - Raphael Burri - raburri@bluewin.ch

#region parameters
param([string]$computerName = "localhost",
[string]$storeName = "My",
[string]$storeProvider = "SystemRegistry",
[string]$storeType = "LocalMachine"

)
#endregion


#region variables and constants
# get script name
# SCOM agent calls them dynamically, assigning random names
#$scriptName = $MyInvocation.MyCommand.Name
$scriptName = "Certificate_DiscoveryDemand_Script_V1.ps1"
$userName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

#see on input parameters - default to LocalSystem store My (personal computer store), SystemRegistry provider (registry) and LocalSystem storetype
if ($storeName -eq "") { $storeName = "My"}

#PoSh 2.0 was shipped with 2008R2/Win7. In order to have as little dependency on later updates
#     as possible this script only uses 2.0 cmdlets
$minimalPSVersion = "2.0"
#endregion

# Get access to the scripting API
$scomAPI = new-object -comObject "MOM.ScriptAPI"

# check if Powershell >= 2.0 is running
if( ($PSVersionTable.PSCompatibleVersions) -contains $minimalPSVersion)
	{
	#Write-Host Powershell installed: ( $PSVersionTable.PSVersion.ToString() )
	#Write-Host      It is compatible with version $minimalPSVersion required by this script
	}
else
	{
	#Write-Host Powershell installed: $PSVersionTable.PSVersion.ToString() `t`t`t`t`t`t`t`t -BackgroundColor red 
	#Write-Host `tIt is not compatible with version $minimalPSVersion required by this script `t -BackgroundColor red
	exit
	}


function main
	{
	Write-EventLogEntry -EventLogName 'Operations Manager' -EventSourceName 'Health Service Script' -EventId 121 -EventSeverity 'Information' -EventDescription ("
Task to ask for re-discovery was run.

Computer: %3
Store Name: %4
Store Provider: " + $storeProvider + "
Store Type: " + $storeType) -EventParameter1 $ScriptName -EventParameter2 $computerName -EventParameter3 $storeName
		
	Write-Output ("Asked for re-discovery of the certificate store by writing local event.")	
	}

Function Write-EventLogEntry
{
	param ([string]$EventLogName, [string]$EventSourceName, $EventId ,[string]$EventSeverity, [string]$EventDescription, [string]$EventParameter1, [string]$EventParameter2, [string]$EventParameter3) 
	# using .NET objects as they allow event parameters
	$newEvent = new-object System.Diagnostics.Eventinstance($EventId, 0, [system.diagnostics.eventlogentrytype]::[string]$EventSeverity) 
	[system.diagnostics.EventLog]::WriteEvent([string]$EventSourceName, $newEvent, $EventDescription, $EventParameter1, $EventParameter2, $EventParameter3)
}

#call main function
Main