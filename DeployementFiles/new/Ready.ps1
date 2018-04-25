# Ce script est execut� par les machines WinPE fra�chement d�marr�es
# ATTENTION ! Ce script est lanc� depuis X:\Windows\System32\ soyez donc pr�cis dans les chemins que vous utilisez
# Par piti� n'utilisez pas de chemins relatifs mais uniquement des absolus, il y a des stagiaires qui souffrent autrement
# Pour une meilleure compr�hension du syst�me de d�ploiement, se r�f�rer au plan dans [ajouter chemin documentation ]

New-Item -Path "X:\scripts" -ItemType Directory
Copy-Item N:\IPXE\*.ps1 x:\scripts\ 
Start-Process N:\IPXE\VNC\winvnc.exe

while($true)
{
    If (Test-Connection ipxe.technocite.lan -Count 1 -Quiet) {break} 
    Else { Write-Host "Aucune connexion avec ipxe.technocite.lan" -ForegroundColor Red; Start-Sleep -Seconds 1}
}

While($true)
{
    If (Test-Path X:\deployement.ps1) 
    {  
        Write-Host "En route vers N:\IPXE" -BackgroundColor Green
        Write-Host "Construction de X:\deployement.ps1" -BackgroundColor Green
        Set-Location N:\IPXE
        powershell X:\deployement.ps1
        break
    }

    Else 
    {
        try 
        {
            $url = "http://ipxe.technocite.lan/javascripts/ipxe2018.php?code=1"
            $output = "X:\deployement.ps1"

            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($url, $output)   
        }
        catch 
        {
            Write-Host "Impossible de r�cup�rer le fichier via http://ipxe.technocite.lan/javascripts/ipxe.php" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}