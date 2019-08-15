# Written by: Matt Elsberry - 08/15/2019
$DirLoc = "c:\temp" # Directory where the temprorary files will be moved
$RSATLocation = "\\MyServer\SupportFiles\Microsoft_Related\Server_Remote_Tools_Windows10" # Network share where the RSAT .MSU files are located.
# Download them all from here: https://www.microsoft.com/en-gb/download/details.aspx?id=45520

# ----------------- DO NOT MODIFY BELOW THIS LINE ----------------

$XMLDir = "$DirLoc\ex"
$ReleaseID = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseID')
IF ($ReleaseID -lt 1709)
    {
	Write-Host "You have Build version $ReleaseID and need version 1709 or greater to continue."
	Write-Host "Ending the script."
	Pause
	Exit
	}
$UpdateCheck = Get-HotFix -ComputerName $env:computername -Id KB2693643 -erroraction 'silentlycontinue'
$DoFilesExist = Test-Path $RSATLocation\WindowsTH-RSAT_WS_$ReleaseID-x64.msu
IF ($DoFilesExist -eq $False)
	{
	Write-Host "Your .MSU Files are not in $RSATLocation You should downlaod them and place them there first"
	Write-Host "Place the MSU files and then try re-running the script"
	pause
	exit
	}
If ($UpdateCheck -eq $null)
	{
	mkdir "$DirLoc\ex" -erroraction 'silentlycontinue'
	mkdir "$XMLDir" -erroraction 'silentlycontinue'
	$XMLdata = @"
	<?xml version="1.0" encoding="UTF-8"?>  
<unattend xmlns="urn:schemas-microsoft-com:setup" description="Auto unattend" author="pkgmgr.exe">  
  <servicing>  
    <package action="stage">  
      <assemblyIdentity buildType="release" language="neutral" name="Microsoft-Windows-RemoteServerAdministrationTools-Client-Package-TopLevel" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" version="10.0.16299.2"/>  
      <source location="." permanence="temporary"/>  
    </package>  
  </servicing>  
</unattend>
"@
	$XMLdata | out-file "$XMLDir\unattend_x64.xml"
	expand -f:* $RSATLocation\WindowsTH-RSAT_WS_$ReleaseID-x64.msu $DirLoc\
	Set-Location -Path $DirLoc
	expand -f:* WindowsTH-KB2693643-x64.cab $XMLDir\
	Set-Location -Path $XMLDir
	dism /online /apply-unattend="unattend_x64.xml"
	Set-Location -Path $DirLoc
	dism /online /Add-Package /PackagePath:"WindowsTH-KB2693643-x64.cab" -wait
	Remove-Item -Force -Recurse -Path $DirLoc	
	}
Else
	{
	$Reboot = Read-Host -Prompt 'PowerShell needs to uninstall KB2693643, which will require a reboot, Do you want to continue? (Y/N)'
		If ($Reboot -eq "Y")
		{
		$Reboot = ""
		Start-Process wusa.exe -ArgumentList '/KB:2693643 /uninstall /quiet /norestart' -Wait		
		$Reboot = Read-Host -Prompt 'Uninstallation is finished, do you wish to reboot now? (Y/N)'
			If ($Reboot -eq "Y")
			{
			Write-Host "Your computer will now reboot, please run the script again once it reboots, in order to finish"
			pause
			Restart-Computer
			}
			Else
			{
			Write-Host You need to restart your computer and run the script again to finish.
			}
		}
		Else
		{
		Write-Host "Ending the script, re-run it when you are ready to proceed"
		}
	}	

