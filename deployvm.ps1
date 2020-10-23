function DeployVM
{
	[CmdletBinding()]
	Param
	(
		
	)
	
    ## Static stuff - only change at first
    
    Write-Host "##################################################"
    Write-Host "## Deploy Hyper-V VM Automation - code by Kevin ##"
    Write-Host "##################################################"
 
    ## set server code name
    Write-Host "   "
    $Code = Read-Host -Prompt "Server Code (ex.IPM-TW-SERVER)"

    ## set count of servers and this count will also put to server name
    ## ex. Start from which server number: 80
    ## ex. End to which server number: 85
    Write-Host "## Example --"
    Write-Host "## Start Server Number: 80"
    Write-Host "## End Server Number: 85"
    Write-Host "## TEST-SERVER80, TEST-SERVER81, TEST-SERVER82... TEST-SERVER85"
    $start = Read-Host -Prompt "Start Server Number"
    $end = Read-Host -Prompt "End Server Number"
    $convertarray=($start..$end).ForEach({ '{0:D2}' -f $_ }) -join ','
    [string[]]$numbers =$convertarray.Split(",")
    
    ## set memory size
    $mem = Read-Host -Prompt "Enter Memory (ex.2GB)"
    $Memory = [Int64]$mem.Replace('GB','') * 1GB
    
    ## set number of cpu
    $CPUCores = Read-Host -Prompt "Enter CPU Cores"
    
    ## set virtual switch
    Write-Host "Here are all the Virtual Switch:"
    Get-vmswitch | Select-Object Name, Notes
    $Switch = Read-Host -Prompt "Enter Virtual Switch"

    ## set vlan id
    $vlan= Read-Host -Prompt "Enter VLAN ID"

    ## mount vhd template
    ## for network share, you can use IP (ex. Enter Path of VHD Template: \\10.10.10.10\Template\sample.vhdx)
    $vhdtemplate = Read-Host -Prompt "Enter Path of VHD Template"
    Mount-VHD $vhdtemplate
    
    ## variable for new vhd path (ex. Enter New VHD path: E:\test)
    $HDDPath= Read-Host -Prompt "Enter New VHD path for all New VM"

    ## looping.. pls ignore
    $numberscount = 0
	
    ## looping part
	for ($i = 0; $i -lt $numbers.count; $i++)
	{ 

    ## variable for vm number
    $vmnumber = $numbers[$numberscount]

    ## variable for vm name
	$VMName = "$Code$vmnumber"

    ## Write-Verbose is to see the action on your screen haha.."
    ## variable for hdd name
    $HDDName = "$HDDPath\$Code\$VMName.vhdx"
    Write-Verbose "The VM Number is: $vmnumber"
    Write-Verbose "The VM Name is: $VMName"
    Write-Verbose "The HDD Name is: $HDDName"
    
    ## start vm creation
	Write-Verbose "Starting VM Creation Process..."
	Write-Verbose "Commands to run..."

    ## create vm name, switch, memory using variables.. set generation
	Write-Verbose "New-VM -Name $VMName -SwitchName ""$Switch"" -MemoryStartupBytes $Memory -Generation 1"
    ## New-VM is create command
	New-VM -Name $VMName -SwitchName "$Switch" -MemoryStartupBytes $Memory -Generation 1
	
    ## edit processor and change memory to static
    Write-Verbose "Set-VM -Name $VMName -ProcessorCount $CPUCores -StaticMemory:$true"
	## Set-VM is edit existing vm
    Set-VM -Name $VMName -ProcessorCount $CPUCores -StaticMemory:$true

    ## create vhd from vhd template
    Write-Verbose "New-VHD -Fixed -Path $HDDName -SourceDisk 2"
    ## New-VHD is create new vhd.. -SourceDisk parameter is copy the content of the vhd disk number from Get-Disk
    New-VHD -Fixed -Path $HDDName -SourceDisk 2
    
    ## attach hdd if IDE for Gen1 SCSI for Gen2
    ## Get-VM $VMName | Add-VMHardDiskDrive -ControllerType SCSI -ControllerNumber 0 -Path $HDDName ## use this if Gen2
    Write-Verbose "Add-VMHardDiskDrive -VMName $VMName -ControllerType IDE -ControllerNumber 0 -Path $HDDName"
    ## Add-VMHardDiskDrive is attach the new vhd to the vm.. -ControllerNumber parameter is the IDE number
    Add-VMHardDiskDrive -VMName $VMName -ControllerType IDE -ControllerNumber 0 -Path $HDDName
    
    ## set VLAN ID
    Write-Verbose "Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanID $vlan"
    Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanID $vlan

    ## start VM
    Write-Verbose "Start-VM $VMName"
    Start-VM $VMName

	$numberscount++

	}   

}
