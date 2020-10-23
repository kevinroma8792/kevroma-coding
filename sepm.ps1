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
    $authrequest = Invoke-RestMethod -Uri https://10.12.7.224:8446/sepm/api/v1/identity/authenticate -Method Post -Body $auth -ContentType 'application/json'

    #Access token from SEPM Authentication
    $access_token = $authrequest.token

    #Format HTTP header
    $header =@{Authorization='Bearer '+$access_token}

    # API: GET - Computers list hardware key
    $result = Invoke-RestMethod -Uri https://10.12.7.224:8446/sepm/api/v1/groups/$groupid/computers -Headers $header
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
    $authrequest = Invoke-RestMethod -Uri https://10.12.7.224:8446/sepm/api/v1/identity/authenticate -Method Post -Body $auth -ContentType 'application/json'

    #Access token from SEPM Authentication
    $access_token = $authrequest.token

    #Format HTTP header
    $header =@{Authorization='Bearer '+$access_token}

    # API: PATCH - Move computers to another group
    Invoke-RestMethod -Uri https://10.12.7.224:8446/sepm/api/v1/computers -Method Patch -InFile $jsonpath -ContentType 'application/json' -Headers $header
    
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
    # List of SEPM IM Group IDs #
    #############################
    # My Company - B30492600A0C07E04ED18E5AF0726506
    # My Company \ AWS-SF Group - 2B91BC100A0C07E04FB6A059A2B7E2B3
    # My Company \ Cleanroom - 7489B6AC0A0C07E03715968D0BE52C8E
    # My Company \ Default Group - 8EBE318E0A0C07E073E2EEE46636DB00
    # My Company \ Esport Group - 9C94BF300A0C07E0290DD7FFCB470190
    # My Company \ Ghost Buster Group - 283099F40A0C07E0314D05C02CBE29EF
    # My Comapny \ Hyper-V Host Group - 989FFEC20A0C07E00C71A22D37E99F3A
    # My Company \ IM_Default-Group - 2B3FE4510A0C07E00A7221F7D8E5C82E
    # My Company \ IMONE Group - EF4B3F530A0C07E041A83A38D6F9203E
    # My Company \ Narra Group - 731677B40A0C07E02D793EB64717ABF9
    # My Company \ OCT Group - F3EC8E870A0C07E023469057E368BFA9
    # My Company \ Sunflower Group - DF575E690A0C07E0228F4E3EC8570A00
    # My Company \ Yabo Group - BD88F7BB0A0C07E0497FB0E93D64192E
}

