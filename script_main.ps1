
#######Step 1###########
#######Importing the credentials from a file#################

Set-Variable -Name "counter" 
[string]$user= (Get-Content -Path .\paramimport.txt -TotalCount 6)[-5];
[string]$pass= (Get-Content -Path .\paramimport.txt -TotalCount 6)[-3];
[string]$tenant1= (Get-Content -Path .\paramimport.txt -TotalCount 6)[-1];

$pair = "${user}:${pass}" 
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [Convert]::ToBase64String($bytes)
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
write-host ( " the pair value is as follow {0}" -f $encodedCredentials ) 

$pair
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [Convert]::ToBase64String($bytes)
$Accept = "application/json"
$headers = @{ "Authorization" ="Basic $base64"; "aw-tenant-code"=$tenant1; "Content-Type"='application/json' ; "Accept"= "application/json"} 

#Defining temporary variables
$headers
$pagecount = 0;
$array1 = @()
$total = 0

#Defining URL that have to be accessed.
#Note the Instance name is Obfuscated as it is unique. The rest of URL is the same for all Customers using these APIs. 
$url= 'https://XXXX.awmdm.com/api/mdm/devices/bulksettings'
$urlbase='https://XXXX.awmdm.com/api/mdm/devices/search?platform=Apple&page=0'
$Output = Invoke-RestMethod -uri $urlbase -Method Get -Headers $headers -UseBasicParsing 

#500 is the limit of one response. This is just dividing with the total output to determine the loop
$total = ($Output.Total / 500)

$total1 = [math]::floor($total)

do {

$Output = Invoke-RestMethod -uri $url1 -Method Get -Headers $headers -UseBasicParsing 
$url1='https://XXXX.awmdm.com/api/mdm/devices/search?platform=Apple&page=' + $pagecount


$pagecount =$pagecount + 1;
#Just checking the value
$pagecount

#Adding a loop
for($oo= 0; $oo -lt $Output.Devices.Length;$oo++) {

#if (( $Output.Devices[$oo].LocationGroupId[0].Name -ieq "FullXXX") -or ($Output.Devices[$oo].LocationGroupId[0].Name -ieq "FullXXX") -or ($Output.Devices[$oo].LocationGroupId[0].Name -ieq "XXXX") ) {
 $Appledata = New-Object PSObject
 $Appledata | Add-Member  -type NoteProperty -name "Serial Number" -Value $($Output.Devices[$oo].SerialNumber)
 $Appledata | Add-Member  -type NoteProperty -name "IMEI" -Value $($Output.Devices[$oo].Imei)
 $Appledata | Add-Member  -type NoteProperty -name "User Name" -Value $($Output.Devices[$oo].UserName)
 $Appledata | Add-Member  -type NoteProperty -name "User Mail" -Value $($Output.Devices[$oo].UserEmailAddress)
 $Appledata | Add-Member  -type NoteProperty -name "Model" -Value $($Output.Devices[$oo].Model)
 $Appledata | Add-Member  -type NoteProperty -name "OS" -Value $($Output.Devices[$oo].OperatingSystem)
 
 #$Appledata | Add-Member  -type NoteProperty -name "MacAddress" -Value $($Output.Devices[$oo].MacAddress)
 $Appledata | Add-Member  -type NoteProperty -name "Ownership" -Value $($Output.Devices[$oo].Ownership)
 #$Appledata | Add-Member  -type NoteProperty -name "PhoneNumber" -Value $($Output.Devices[$oo].PhoneNumber)
[DateTime]$datecheck = $Output.Devices[$oo].LastEnrolledOn;
$Appledata | Add-Member  -type NoteProperty -name "Enrollment Date" -Value $($datecheck.ToString('dd.MM.yyyy'))
 # $Appledata | Add-Member  -type NoteProperty -name "DeviceLastSeen" -Value $($dd.Devices[$oo].LastSeen)
  #[DateTime]$datacheck = Get-Date;
  [DateTime]$datecheck1 = $Output.Devices[$oo].LastSeen;
 $Appledata | Add-Member  -type NoteProperty -name "Device Last Seen" -Value $($datecheck1.ToString('dd.MM.yyyy'))
 $Appledata | Add-Member  -type NoteProperty -name "Organization Group Name" -Value $($Output.Devices[$oo].LocationGroupName)
 ##############################
 ##############################
 
 [DateTime]$DaysSinceLastSeenTemp = $Output.Devices[$oo].LastSeen
 $dft1 = Get-Date
 $qwert = $dft1.Date - $DaysSinceLastSeenTemp.Date
 #$qwert.TotalDays
 $Appledata | Add-Member  -type NoteProperty -name "Last seen(days)" -Value $($qwert.TotalDays)

#Write-Output "The $dft value is "
 #Write-Output "The $Dft2 value is "
 # [DateTime]$TempDate =  [datetime]::Today
 #$Tempdate
 #[DateTime]$DaysSinceLastSeen = New-TimeSpan -Start $DaysSinceLastSeenTemp -End $(Get-Date)
 #$DaysSinceLastSeen.DateTim
 #$Appledata | Add-Member  -type NoteProperty -name "OrganizationGroupName" -Value $($Output.Devices[$oo].LocationGroupName)
 #locationgroupname

 $array1 +=$Appledata
 }
                        #   }
#######################################################
#######################################################
#######################################################
#} while ($pagecount -le $total1)

##} while ($pagecount -le $total1)
} while ($pagecount -le $total1)

###################################
####do while whereas total < $Output.Total
################ Total Devices = XXXX

$array1 | Export-Csv -Path .\iosdata.csv -Delimiter ',' -NoTypeInformation