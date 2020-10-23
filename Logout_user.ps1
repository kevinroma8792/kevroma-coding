function Logout
{
    [CmdletBinding()]
	Param
	(
    [string]$user,
    [string]$serverlist
	)

$computers=get-content $serverlist # Put Server Ip into File

 foreach ($computer in $computers) #For Each Server
{
   #foreach($ServerLine in @(qwinsta /server:$computer Username)
    foreach($ServerLine in @(qwinsta /server:$computer $user) -split "\n") #Each Server Line , change account name manually like XXXXXX
    {
        #SESSIONNAME USERNAME  ID  STATE  TYPE  DEVICE

        $Parsed_Server = [System.Collections.ArrayList]@($ServerLine -split '\s+')
        $Parsed_Server.Remove('USERNAME')
        $Parsed_Server.Remove('ID')
        $Parsed_Server.Remove('STATE')
        $Parsed_Server.Remove('TYPE')
        $Parsed_Server.Remove('DEVICE')
        $Parsed_Server.Remove('SESSIONNAME')
        $Parsed_Server.Remove('Disc')
        #$Parsed_Server[2] #USERNAME
        $a = $Parsed_Server[2]
    }
    logoff $a /server:$computer
    echo $computer
    qwinsta /server:$computer XXXXXX
}

}
