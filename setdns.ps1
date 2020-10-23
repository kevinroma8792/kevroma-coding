$computers = "C:\Users\Kevin\Downloads\servers.txt"
##Get-ADComputer -Filter * | Select -ExpandProperty dnshostname

$Error.clear()

Foreach($COMPUTER in Get-Content $computers)
{
   TRY{
        
        $ErrorActionPreference = "Stop"

        ## Filter network adapter that have IP enabled and have Static IP
        $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $COMPUTER |where{$_.IPEnabled -eq “True” -and $_.DHCPEnabled -ne "True"}
        
        Foreach($NIC in $NICs) 
        {
        
        ## DNS IP addresses
        $DNSServers = "10.12.7.233","10.12.7.212","10.12.7.211" ## the new DNS entries in order - Primary DNS, Secondary DNS, Other DNS
        
        ## Set DNS IP addresses *WARNING!! This is replace, not add!! If replace, need to put ALL DNS IP*
        $NIC.SetDNSServerSearchOrder($DNSServers) | Out-Null
        
        ## Enable setting - register computer IP addresses to DNS server
        $NIC.SetDynamicDNSRegistration(“TRUE”) | Out-Null
        Write-Host "Successfully set on $computer" -f green
       
        }
        
      }

   Catch
      {
        
        ## See which computers have error
        Write-Host "$computer " -BackgroundColor red -NoNewline
        Write-Warning $Error[0]

      }
}