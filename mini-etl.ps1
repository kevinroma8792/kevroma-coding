##################################################################################
# Bending Spoons Challenge
##################################################################################
# 
# Requirements:
# - Git with Powershell (https://gitforwindows.org/)
# - posh-git (https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-PowerShell)
#
# To run script:
# open Powershell as Administrator and go to script directory
#     ex. cd 'C:\users\test\'
#     . .\script.ps1
#  
# To run functions (step by step):
# 1. Git-Clone - clone repository
#      
#      ex. Git-Clone <Param1> <Param2> <Param3>
#                    <$token> <$localFolder> <$repos>
#        
#        Git-Clone "1234567890abcdefghij1234567890abcdefghij" "C:\test\" "name-of-repository"
#      
# 2. Export-Commits - extracting commit logs and transforming based on request
#      
#      ex. Export-Commits <Param1> <Param2> 
#                         <$inputcsv> <$outputcsv>
#
#        Export-Commits "C:\test\input.csv" "C:\test\output.csv"
#
# 3. Create-SQLDB - create microsoft sql database 
#    
#    (install microsoft sql express 2019 edition: https://go.microsoft.com/fwlink/?linkid=866658)
#    (install microsoft sql server management studio: https://aka.ms/ssmsfullsetup)
#
#      ex. Create-SQLDB <Param1> <Param2> <Param3>
#                       <$SQLInstance> <$SQLDatabase> <$SQLTable>
#
#        Create-SQLDB "localhost\SQLEXPRESS" "github" "commits"
#
# 4. Import-CSVtoDB - load csv contents to sql database
#      
#      ex. Import-CSVtoDB <Param1> <Param2> <Param3> <Param4>
#                         <$outputcsv> <$SQLInstance> <$SQLDatabase> <$SQLTable>
#
#        Import-CSVtoDB "C:\test\output.csv" localhost\SQLEXPRESS" "github" "commits"
#
##################################################################################



function Git-Clone{
param(
 [string]$token,
 [string]$localFolder,
 [array]$repos = @("github-challenge-kevroma")
)

$repoLocation = "https://$token@github.com/BendingSpoonsTalent/"

foreach ($gitRepo in $repos) {
	If (Test-Path $localFolder$gitRepo) {
		echo "repo $gitRepo already exists"
	}
	Else {
		echo "git clone $repoLocation$gitRepo $localFolder$gitRepo"
		git clone $repoLocation$gitRepo $localFolder$gitRepo
        cd "$localFolder$gitRepo"
        git checkout $(git rev-list --before="Jun 27 2018" master)
	}
  }
}



function Export-Commits{

param(
 [string]$inputcsv,
 [string]$outputcsv
)

        ############################################################################################
        # Description:
        # This function gets logs based from "git log" formats: https://git-scm.com/docs/pretty-formats,
        # insert headers for existing columns, append new header 'is_external' and its values at the next column
        ############################################################################################

        git log --pretty=format:"%H%x09%cI%x09%aE%x09%b" > $inputcsv

        Import-Csv $inputcsv -Header @("sha","date","author","message") -Delimiter "`t" |
        Select-Object -Property *,
        @{n='is_external';e={if ($_.author -like '*bendingspoons.com*') {'0'} else {'1'}}} |
        Export-Csv $outputcsv -NoTypeInformation

}



function Create-SQLDB{

param(
 [string]$SQLInstance,
 [string]$SQLDatabase,
 [string]$SQLTable
)

##############################################
# Description:
# This function creates a demo database and table required for the Import-CSVtoDB function below
# Script tested using Windows 10, PowerShell 5.1 and SQL Express 2019 instance
##############################################
# Requirements:
# - Set-executionpolicy unrestricted on the computer running the script
# - A SQL server, instance, and credentials to create a database
##############################################
# Prompting for SQL credentials
##############################################
$SQLCredentials = Get-Credential -Message "Enter your SQL username & password"
$SQLUsername = $SQLCredentials.UserName
$SQLPassword = $SQLCredentials.GetNetworkCredential().Password
##############################################
# Checking if SqlServer module is already installed, if not installing it
##############################################
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($SQLModuleCheck -eq $null)
{
Write-Host "SqlServer Module Not Found - Installing"
# Not installed, trusting PS Gallery to remove prompt on install
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Installing module
Install-Module -Name SqlServer –Scope CurrentUser -Confirm:$false -AllowClobber
}
##############################################
# Importing SqlServer module
##############################################
Import-Module SqlServer
##############################################
# Creating SQL Database
##############################################
$SQLCreateDB = "USE master;  
GO  
CREATE DATABASE $SQLDatabase
GO"
Invoke-SQLCmd -Query $SQLCreateDB -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
##############################################
# Creating SQL Table
##############################################
$SQLCreateTable = "USE $SQLDatabase
    CREATE TABLE $SQLTable (
	sha TEXT,
	date TEXT,
        author TEXT,
	message TEXT,
	is_external INT
);"
Invoke-SQLCmd -Query $SQLCreateTable -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
##############################################
# End of function
##############################################
}



function Import-CSVtoDB{

param(
[string]$outputcsv,
[string]$SQLInstance,
[string]$SQLDatabase,
[string]$SQLTable
)

##############################################
# Description:
# This function will import a CSV into a SQL database using the PowerShell SQL Module
# Script tested using Windows 10, PowerShell 5.1 and SQL Express 2019 instance
##############################################
# Requirements:
# - Set-executionpolicy unrestricted on the computer running the script
# - A SQL server, instance, credentials, and the DB already created from the Create-SQLDB function
# - Output CSV file from Export-Commits function
##############################################
# Prompting for SQL credentials
##############################################
$SQLCredentials = Get-Credential -Message "Enter your SQL username & password"
$SQLUsername = $SQLCredentials.UserName
$SQLPassword = $SQLCredentials.GetNetworkCredential().Password
##############################################
# Checking if SqlServer module is already installed, if not installing it
##############################################
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($SQLModuleCheck -eq $null)
{
Write-Host "SqlServer Module Not Found - Installing"
# Not installed, trusting PS Gallery to remove prompt on install
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# Installing module
Install-Module -Name SqlServer –Scope CurrentUser -Confirm:$false -AllowClobber
}
##############################################
# Importing SqlServer module
##############################################
Import-Module SqlServer
##############################################
# Importing CSV and processing data
##############################################
$CSVImport = Import-Csv $outputcsv -Delimiter ","
$CSVRowCount = $CSVImport.Count
##############################################
# ForEach CSV Line Inserting a row into the Temp SQL table
##############################################
"Inserting $CSVRowCount rows from CSV into SQL Table $SQLTable"
# Setting variables for the CSV line, ADD ALL possible CSV columns here
ForEach ($CSVLine in $CSVImport)
{
$CSVsha = $CSVLine.sha
$CSVdate = $CSVLine.date
$CSVauthor = $CSVLine.author
$CSVmessage = $CSVLine.message
$CSVis_external = $CSVLine.is_external
##############################################
# SQL INSERT of CSV Line/Row
##############################################
$SQLInsert = "USE $SQLDatabase
INSERT INTO $SQLTable (sha, date, author, message, is_external)
VALUES('$CSVsha', '$CSVdate', '$CSVauthor', '$CSVmessage','$CSVis_external');"
# Running the INSERT Query
Invoke-SQLCmd -Query $SQLInsert -ServerInstance $SQLInstance -Username $SQLUsername -Password $SQLPassword
# End of ForEach CSV line below
}
# End of ForEach CSV line above
##############################################
# End of function
##############################################
}