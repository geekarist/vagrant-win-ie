winrm quickconfig -q
powershell Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value True
powershell Set-Item WSMan:\localhost\Service\Auth\Basic -Value True
