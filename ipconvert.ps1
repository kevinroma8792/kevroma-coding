function ipconvert
{
    [CmdletBinding()]
	Param
	(
		
	)
    
    $EC2IP = Read-Host -Prompt "Enter EC2 IP list"

    ForEach($IP in Get-Content $EC2IP)
    {
    $InstanceID = aws ec2 describe-instances --filter Name=private-ip-address,Values=$IP --query 'Reservations[].Instances[].InstanceId' --output text | Out-String
    Edit-EC2InstanceAttribute -InstanceId $InstanceID.Trim() -Group <security_groupid> #put your security group id
    }
}
