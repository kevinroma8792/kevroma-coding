function set-udnsARecord {

param(
[string]$zone,
[string]$domainlist,
[string]$IP
)

$username = Read-Host "Username"
$password = Read-Host "Password" -AsSecureString
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$uri = "https://restapi.ultradns.com/v2/authorization/token"
$body= "grant_type=password&username=$username&password=$pw"
$result = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $result.access_token

  foreach($domain in Get-Content $domainlist)
    {
      $ttl = 300
      $url = "https://restapi.ultradns.com/v2/zones/$zone./rrsets/A/$domain"
      $method = "POST"
      $body = @{
	  "ttl"= $ttl
	  "rdata"= @("$IP")
      }
      $result = Invoke-RestMethod -Method $method -Uri $url -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers @{"Authorization" = "Bearer $token"}
      $result.message -eq "Successful"
    }
}

function set-udnscnameRecord {

param(
[string]$zone,
[string]$cnamelist,
[string]$destinationUrl
)

$username = Read-Host "Username"
$password = Read-Host "Password" -AsSecureString
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$uri = "https://restapi.ultradns.com/v2/authorization/token"
$body= "grant_type=password&username=$username&password=$pw"
$result = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $result.access_token

  foreach($cname in Get-Content $cnamelist)
    {
      $ttl = 300
      $url = "https://restapi.ultradns.com/v2/zones/$zone./rrsets/CNAME/$cname"
      $method = "POST"
      $body = @{
	  "ttl"= $ttl
	  "rdata"= @("$destinationUrl.")
      }
      $result = Invoke-RestMethod -Method $method -Uri $url -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers @{"Authorization" = "Bearer $token"}
      $result.message -eq "Successful"
    }
}

function update-udnscnameRecord {

param(
[string]$zone,
[string]$cnamelist,
[string]$destinationUrl
)

$username = Read-Host "Username"
$password = Read-Host "Password" -AsSecureString
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$uri = "https://restapi.ultradns.com/v2/authorization/token"
$body= "grant_type=password&username=$username&password=$pw"
$result = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $result.access_token

  foreach($cname in Get-Content $cnamelist)
    {
      $ttl = 300
      $url = "https://restapi.ultradns.com/v2/zones/$zone./rrsets/CNAME/$cname"
      $method = "PATCH"
      $body = @{
	  "ttl"= $ttl
	  "rdata"= @("$destinationUrl.")
      }
      $result = Invoke-RestMethod -Method $method -Uri $url -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers @{"Authorization" = "Bearer $token"}
      $result.message -eq "Successful"
    }
}


function update-udnsARecord {

param(
[string]$zone,
[string]$domainlist,
[string]$IP
)

$username = Read-Host "Username"
$password = Read-Host "Password" -AsSecureString
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$uri = "https://restapi.ultradns.com/v2/authorization/token"
$body= "grant_type=password&username=$username&password=$pw"
$result = Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $result.access_token

  foreach($domain in Get-Content $domainlist)
    {
      $ttl = 300
      $url = "https://restapi.ultradns.com/v2/zones/$zone./rrsets/A/$domain"
      $method = "PATCH"
      $body = @{
	  "ttl"= $ttl
	  "rdata"= @("$IP")
      }
      $result = Invoke-RestMethod -Method $method -Uri $url -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers @{"Authorization" = "Bearer $token"}
      $result.message -eq "Successful"
    }
}
