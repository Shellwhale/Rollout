# R�cup�ration de l'architecture choisie
param([string]$arch)



# Le script doit �tre lanc� depuis le dossier Rollout
if (-Not ((Get-Item -Path ".\").name -contains 'Rollout' ) ) 
{
    Write-Host "Ce script doit �tre lanc� depuis le r�pertoire Rollout"
    exit    
}

# Titre de la fen�tre
$host.ui.RawUI.WindowTitle = "Rollout"




# Si elle est autre que amd64 ou x86, arr�t du script
If (-Not ($arch -contains 'amd64' -Or $arch -contains 'x86'))
{
    Write-Host ".\rollout.ps1 <amd64/x86>"
    exit
}
# Titre de la fen�tre
$host.ui.RawUI.WindowTitle = "Rollout $arch"

# Installation de BurntToast si il n'est pas d�j� pr�sent 
if (-Not(Test-Path C:\Users\$env:USERNAME\Documents\WindowsPowerShell\modules\BurntToast)){Copy-Item ./Modules/BurntToast C:\Users\$env:USERNAME\Documents\WindowsPowerShell\modules\BurntToast}

# D�ploiement d'un WinPE via ADK � la racine selon l'architecture choisie
Get-Content "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" | Out-File "$env:temp\DandISetEnv$arch.bat" -encoding ASCII
Add-Content -Path $env:temp\DandISetEnv$arch.bat -Value "copype $arch C:\$arch"
cmd.exe /c $env:temp\DandISetEnv$arch.bat

# Montage de l'image � la racine selon l'architecture choisie 
Dism /Mount-Image /ImageFile:"C:\$arch\media\sources\boot.wim" /Index:1 /MountDir:"C:\$arch\mount"

# Configuration de la r�gion sur fr-BE
Dism /image:c:\$arch\mount /Set-SysLocale:fr-BE
Dism /image:c:\$arch\mount /Set-UserLocale:fr-BE
Dism /image:c:\$arch\mount /Set-InputLocale:fr-BE

# Ajout des fichiers StartNet.cmd et Start.ps1
Remove-Item C:\$arch\mount\Windows\System32\StartNet.cmd
Copy-Item DeployementFiles\StartNet.cmd C:\$arch\mount\Windows\System32\
Copy-Item DeployementFiles\Start.ps1 C:\$arch\mount\Windows\System32\

# Ajout des packages 

Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-WMI.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-NetFX.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-Scripting.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-PowerShell.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-StorageWMI.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-DismCmdlets.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-WinReCfg.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-WinReCfg_en-us.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\WinPE-SecureBootCmdlets.cab"
Dism /Add-Package /Image:"C:\$arch\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\$arch\WinPE_OCs\en-us\WinPE-SecureBootCmdlets_en-us.cab"

# D�montage et sauvegarde de l'image
Dism /Unmount-Image /MountDir:C:\$arch\mount /Commit

# D�placement du WinPE vers le dossier Winbox
Move-Item C:\$arch .\Winbox\
$logo = "$PWD\Ressources\logo.jpg"
New-BurntToastNotification -Text "Rollout", "Une Winbox $arch est pr�te  Terrible !" -AppLogo $logo