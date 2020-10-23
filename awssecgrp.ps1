function AWSSecGrp
{
    [CmdletBinding()]
	Param
	(

	)
    $ErrorActionPreference = "SilentlyContinue"
    ## Set Access Key, Secret Key, Region
    #$AccessKey = Read-Host -Prompt 'AccessKey'
    #$SecretKey = Read-Host -Prompt 'SecretKey'
    #$Region = Read-Host -Prompt 'Region'

    #Write-Verbose "Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region"
    #Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region

    ## Search Private IP
    #$IP = Read-Host -Prompt 'Enter EC2 Instance IP'

    ## Get Security Group Name
    #Write-Verbose "Here are all the Security Group attached to this EC2 IP:"
    #Get-EC2NetworkInterface | Select-Object PrivateIpAddress,Groups | findstr "$IP"

    ## Get Security Group ID
    ### Where {$_ -match '^([^ \t]+).*'} | Foreach {$matches[1]} ### This part below use REGEX to find exact string in command output
    $SecGroupName = Read-Host -Prompt 'Enter Security Group Name'
    #$SecGroupID = Get-EC2SecurityGroup | Select-Object GroupId,GroupName,Description | findstr "$SecGroupName" | Where {$_ -match '^([^ \t]+).*'} | Foreach {$matches[1]}
    Write-Verbose "This is the Security group ID:"
    Get-EC2SecurityGroup | Select-Object GroupId,GroupName,Description | findstr "$SecGroupName" | Where {$_ -match '^([^ \t]+).*'} | Foreach {$matches[1]}
    $SecGroupID = Read-Host -Prompt 'Enter Security Group ID'

    ## Set Security Group Port and Source IP
    [int[]]$FromPort = Read-Host -Prompt 'Incoming Ports (From)'.split(',') | % {iex $_}
    [int[]]$ToPort = Read-Host -Prompt 'Incoming Ports (To)'.split(',') | % {iex $_}
    [string[]]$SourceIPPath = Read-Host -Prompt 'Enter file path of Source IP list'
    [string[]]$Description = Read-Host -Prompt 'Enter Description'
    foreach($SourceIP in Get-Content $SourceIPPath)
    {
        if($SourceIP -match $regex)
        {
          do
              {

              for ($a = 0; $a -lt $FromPort.count; $a++)
              {
              $FromPorts = $FromPort[$a]
              $ToPorts = $ToPort[$a]
              #Remove comment below if you switch to add Security Group policy: source is Group ID
              $ug = New-Object Amazon.EC2.Model.UserIdGroupPair
              $ug.GroupId = "$SourceIP"
              $ug.Description = "$Description"

              #This is for add Security Group Policy: source is IP
              #Put comment from here
              #$IpRange = New-Object -TypeName Amazon.EC2.Model.IpRange
              #$IpRange.CidrIp = "$SourceIP"
              #$IpRange.Description = "$Description"
              #to here if you switch to Group ID

              $IpPermission = New-Object Amazon.EC2.Model.IpPermission
              $IpPermission.IpProtocol = "tcp"
              $IpPermission.ToPort = $ToPorts
              $IpPermission.FromPort = $FromPorts

              #This is for source is IP, Put comment if you switch to Group ID
              #$IpPermission.Ipv4Ranges = $IpRange

              #This is for source is Group ID, Remove comment if you switch to Group ID
              $IpPermission.UserIdGroupPair = $ug
              Grant-EC2SecurityGroupIngress -GroupId "$SecGroupID" -IpPermission $IpPermission
              }

              $i++
              }while($i -lt $Port.count)
        }
    }
}
