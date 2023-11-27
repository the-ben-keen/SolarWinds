#   Migration Script Solarwinds Platforms
#   Author:     Holger Mundt
#   Email:      holger.mundt@loop1.com
#   Version:    1.0
#   History:    2023-09 HM - Creation of Script
#               2023-10 HM - Extension and Bugfixing
#######################################


# Functions #
function IsEmpty($str) 
{ 
    $null -eq $str -or $str -eq '' -or $str.GetType() -eq [DBNull] 
}
function WriteLogEntry($Severity, $Message) 
{
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $global:Logfile "`n $now - $Severity : $Message"
}

## Add Definition to Group ##
    function AddDefinitionToGroup($GroupID, $MemberDefinition){
       $Membername = $MemberDefinition.Name
       $InnerDefiniton = $MemberDefinition.Definition

       Invoke-SwisVerb $target "Orion.Container" "AddDefinition" @(
                                # group ID
                                $GroupID,

                                # group member to add
                                ([xml]"
                                   <MemberDefinitionInfo xmlns='http://schemas.solarwinds.com/2008/Orion'>
                                     <Name>$Membername</Name>
                                     <Definition>$InnerDefiniton</Definition>
                                   </MemberDefinitionInfo>"
                                ).DocumentElement
                              ) | Out-Null
        return 
    }
## END Add Definition to Group ##

# PSModules #
if (!(Get-Module | where-object {$_.Name -eq "SWISPowerShell"})) {
    Import-Module "SWISPowerShell"
}
# END PSModules #

# Variables Orion #
$SourceHost = '[Host IP]'
$SourceUser = '[UserID]'
$SourcePass = '[ComplexPassword]'
$SourceCred = New-Object -typename System.Management.Automation.PSCredential -argumentlist @($SourceUser,(ConvertTo-SecureString -String $SourcePass -AsPlainText -Force))

$destinationHost = '192.168.2.200'
$DestinationUser = 'admin'
$DestinationPass = 'ITresor0815!'
$DestinationCred = New-Object -typename System.Management.Automation.PSCredential -argumentlist @($DestinationUser,(ConvertTo-SecureString -String $DestinationPass -AsPlainText -Force))

# Global Variables #
$global:Logfile = "C:\Temp\MigrationLog.txt"

# start Connection #
$global:source = Connect-Swis -Credential $SourceCred -Hostname $SourceHost
#Trusted Connection with Certificate - run script as admin to read the Certificate
#$source = Connect-Swis -Hostname $SourceHost -Trusted

$global:target = Connect-Swis -Credential $DestinationCred -Hostname $destinationHost
#Trusted Connection with Certificate - run script as admin to read the Certificate
#$target = Connect-Swis -Hostname $destinationHost -Trusted

## Start Script ##
#Get All Custom Alerts Canned=true
$AllAlertsToCopy = Get-SwisData $source "SELECT AlertID, Name 
                                         FROM Orion.AlertConfigurations
                                         WHERE Canned = $false" -ErrorAction Stop

# Export all Alerts to xml Object and import it on the destination
Foreach($Alert in $AllAlertsToCopy){
    ## Export to XML Object ##
    write-host "Migrating Alert " + $Alert.Name 
    $xml = ''
    $xml = Invoke-SwisVerb -SwisConnection $source -EntityName 'Orion.AlertConfigurations' -Verb 'Export' -Arguments @($Alert.AlertID, $false,'')

    ## Import XML to new Instance
    $alertID = $false
    $alertID = Invoke-SwisVerb -SwisConnection $target -EntityName 'Orion.AlertConfigurations' -Verb 'Import' -Arguments @($xml, $false,'')
    if($alertID){
        write-host "Alert migrated successfully, new ID is " $alertID
    }
    else{
        write-host "Alert not migrated successfully, check definition for " $Alert.Name
    }
}

