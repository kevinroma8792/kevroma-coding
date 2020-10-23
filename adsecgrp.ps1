function DetachSecGrp
{
    [CmdletBinding()]
	Param
	(

	)

    ## Set Access Key, Secret Key, Region
    #$AccessKey = Read-Host -Prompt 'AccessKey'
    #$SecretKey = Read-Host -Prompt 'SecretKey'
    #$Region = Read-Host -Prompt 'Region'

    Write-Verbose "Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region"
    #Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region

    ## Enter Security Group ID
    $SecurityGroup = Read-Host -Prompt 'Enter Security Group ID'

    ForEach ($Instance in $(Get-EC2Instance | Select-Object -ExpandProperty Instances))
    {
       If ($SecurityGroup -in $($Instance | Select-Object -ExpandProperty SecurityGroups).GroupId)
       {
         $Groups = {$($Instance | Select-Object -ExpandProperty SecurityGroups).GroupId}.Invoke()
         $Groups.Remove($SecurityGroup)
         Edit-EC2InstanceAttribute -InstanceId $Instance.InstanceId -Group $Groups
       }
    }

    ## EXPLANATION...Please ask me if not clear..
    ## You cannot delete a security group if still attach to EC2 instance..
    ## So need to detach first..
    ## This command "Edit-EC2InstanceAttribute" can be used to do that.. but this is EDIT not DETACH security group... there is a difference..
    ## The other command you can use is "modify-network-interface-attribute" but I prefer using "Edit-EC2InstanceAttribute"..
    ##
    ## For Each Instance in this command "Get-EC2Instance | Select-Object -ExpandProperty Instances"
    ## It will start the IF loop...
    ## So IF $SecurityGroup input (Security Group ID) is listed in this "$($Instance | Select-Object -ExpandProperty SecurityGroups).GroupId"
    ## then it will do...
    ## $Groups = {$($Instance | Select-Object -ExpandProperty SecurityGroups).GroupId}.Invoke() /// invoking the Security Group ID OF the Instance specified to variable $Groups that we will use on Edit-EC2InstanceAttribute command
    ## then $Groups.Remove($SecurityGroup) /// so we are removing the $SecurityGroup input (sg-03c2d658b011a403c) by using the .Remove psobject on the invoked $Groups
    ## then run Edit-EC2InstanceAttribute command to set $Groups
}


function AttachSecGrp
{
    [CmdletBinding()]
	Param
	(
     [string]$SecurityGroup1,
     [string]$SecurityGroup2,
     [string]$SecurityGroup3,
     [string]$SecurityGroup4,
     [string]$SecurityGroup5
	)

    ## Set Access Key, Secret Key, Region
    #$AccessKey = Read-Host -Prompt 'AccessKey'
    #$SecretKey = Read-Host -Prompt 'SecretKey'
    #$Region = Read-Host -Prompt 'Region'

    #Write-Verbose "Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region"
    #Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region

    $ENIList = Read-Host -Prompt 'Enter file path of EC2 IP list'

    ForEach ($InstanceIP in Get-Content $ENIList)
    {
         $NetworkInterfaceId = aws ec2 describe-network-interfaces --filter Name=private-ip-address,Values=$InstanceIP --query 'NetworkInterfaces[].NetworkInterfaceId' --output text | Out-String
         aws ec2 modify-network-interface-attribute --network-interface-id $NetworkInterfaceId.Trim() --groups $SecurityGroup1 $SecurityGroup2 $SecurityGroup3 $SecurityGroup4 $SecurityGroup5
    }
}
