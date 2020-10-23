function sepm-gethardwarekey
{
	[CmdletBinding()]
	Param
	(
	    [string]$groupid	
	)
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

    #Credentials to convert to token header
    $username = Read-Host "Username"
    $password = Read-Host "Password" -AsSecureString
    $pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    $cred= @{
    username = $username
    password = $pw
    domain = ""
    }

    #Converts $cred array to json to send to SEPM
    $auth = $cred | ConvertTo-Json

    #Authentication
    $authrequest = Invoke-RestMethod -Uri https://localhost:8446/sepm/api/v1/identity/authenticate -Method Post -Body $auth -ContentType 'application/json'

    #Access token from SEPM Authentication
    $access_token = $authrequest.token

    #Format HTTP header
    $header =@{Authorization='Bearer '+$access_token}

    # API: GET - Computers list hardware key
    $result = Invoke-RestMethod -Uri https://localhost:8446/sepm/api/v1/groups/$groupid/computers -Headers $header
    $result.content | select hardwareKey
}

function sepm-moveserver
{
	[CmdletBinding()]
	Param
	(
	    [string]$jsonpath	
	)
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

    #Credentials to convert to token header
    $username = Read-Host "Username"
    $password = Read-Host "Password" -AsSecureString
    $pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    $cred= @{
    username = $username
    password = $pw
    domain = ""
    }

    #Converts $cred array to json to send to SEPM
    $auth = $cred | ConvertTo-Json

    #Authentication
    $authrequest = Invoke-RestMethod -Uri https://localhost:8446/sepm/api/v1/identity/authenticate -Method Post -Body $auth -ContentType 'application/json'

    #Access token from SEPM Authentication
    $access_token = $authrequest.token

    #Format HTTP header
    $header =@{Authorization='Bearer '+$access_token}

    # API: PATCH - Move computers to another group
    Invoke-RestMethod -Uri https://localhost:8446/sepm/api/v1/computers -Method Patch -InFile $jsonpath -ContentType 'application/json' -Headers $header
    
    ###########################################################################
    # Example JSON file to move clients to specified group:
    # Put in notepad:
    #[
    #               {
    #              "group": {
    #                             "id": "A4335B05B53347EF89B7F74C9A0ABABC"
    #              },
    #              "hardwareKey": "7C3636C6FB9D2A3BDEF30CBC67880774"
    #              }
    #]
    ###########################################################################
    #############################
    # List of SEPM Group IDs #
    #############################
    # List your SEPM Group IDs first
}

