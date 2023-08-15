**NOTICE**
THIS IS A COLLECTION OF DASHBOARDS, REPORTS AND OTHER RESOURCES I HAVE EITHER CREATED MYSELF OR WORKED 
WITH OTHERS TO DEVELOP.

THESE ARE NOT SUPPORTED OR VERIFIED TO WORK BY LOOP1 OR ANY OF THEIR PARTNERS. USE OF ANY FILES HERE IN 
ARE FREE TO ANYONE BUT I ENCOURAGE YOU TO IMPORT INTO A DEV ENVIRONMENT PRIOR TO DOING ANYHING IN PRODUCTION.

To see a preview of the dashboards, please visit the Screenshot Folder.

Import Instructions:

Powershell 7 is REQUIRED to import the formatted JSONs into your SolarWinds Orion Database. 

Click the following link to download and install the latest version of PowerShell 7
https://tinyurl.com/25hr5996

The following commands must be ran to configure PowerShell 7 to talk with your Orion Database:
Step 1: Install-Module -Name SwisPowerShell
Step 2: Import-Module -Name SwisPowerShell (not always required)

Connecting to your database Server

Run the following command to connect to your Orion Database. Please be sure to edit the command to reflect the correct information.
$SwisConnection = Connect-Swis -Hostname "PrimaryPollerFQDN (or IP Address)" -UserName "Username" -Password "AccountPassword"

Test the connection to your database

Run the following command to test your connection
Get-SwisData -SwisConnection $SwisConnection -Query "SELECT TOP 10 Caption, IPAddress, ObjectSubType FROM Orion.Nodes"

Download PowerShell script

Run the following to download the needed PowerShell scripts
Start-BitsTransfer -Source "https://raw.githubusercontent.com/solarwinds/OrionSDK/master/Samples/PowerShell/functions/func_ModernDashboards.ps1" -Destination ".\func_ModernDashboards.ps1"

Load the script
. .\func_ModernDashboards.ps1

Import the JSON
Import-ModernDashboard -SwisConnection $SwisConnection -Path C:\Path\To\Dashboard.json