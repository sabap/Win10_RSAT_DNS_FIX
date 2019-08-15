# Win10 RSAT DNS Install
Windows 10 DNS manager install RSAT tools

Prerequisites:
 - RSAT_WS_version##.MSU files need to be downloaded from here : https://www.microsoft.com/en-gb/download/details.aspx?id=45520
 - Place the .MSU files in a Network share and set the same path in the script for variable "$RSATLocation" (Line 3)
 - Windows 10 MUST be on build 1709 or higher (Script will check this for you, if it does not meet the req. it won't continue)
 - KB2693643 need to NOT be installed.  (Script will check and uninstall it first before continuing)

Download the .ps1 file and change the two lines on the top to suit your environment.
Run the .ps1 file.
If KB2693643 is found, it will be uninstalled (A reboot will be required and you will need to re-run the script upon reboot)
Script will clean up after isself when it's done.

Easy Peasy, Lemon Squeezy ...  (Enjoy)
