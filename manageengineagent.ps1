function ManageEngineAgent
{
	[CmdletBinding()]
	Param
	(
		
	)
    [string[]]$ManageEngineAgent = Read-Host -Prompt 'Enter installer path of ManageEngine agent'
    [string[]]$SourceIPPath = Read-Host -Prompt 'Enter file path of Linux IP list'
    foreach($SourceIP in Get-Content $SourceIPPath) {
    if($SourceIP -match $regex){
         Write-Host "IP is $SourceIP"
         $username = Read-Host -Prompt "Enter username"
         scp $ManageEngineAgent\* $username@${SourceIP}:/./tmp
         ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes256-cbc $username@$SourceIP -o StrictHostKeyChecking=no "cd /./tmp; chmod +x DesktopCentral_LinuxAgent.bin; sudo su -; ./DesktopCentral_LinuxAgent.bin"
        }
    }   
}
