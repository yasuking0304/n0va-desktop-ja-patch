# powershell -NoProfile -ExecutionPolicy Unrestricted .\patch.ps1
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
        Exit;
    }
}
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\人工桌面") {
    $desktopDir = (Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders").GetValue("Desktop")
    $iconFile = $desktopDir+'\人工桌面.lnk'
    $iconUsnameFile = $desktopDir+'\N0va Desktop.lnk'
    $insDir = (Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\人工桌面").GetValue("InstallPath")
    $langDir = $insDir+'\language'
    $srcFile = $langDir+'\en-us.qm'
    $destFile = $langDir+'\en-us-original.qm'
    $patchFile = '.\asset\language\ja-jp.qm'
    $backupFile = '.\asset\language\en-us.qm'
    if (Test-Path -Path $destFile -PathType Leaf) {
        echo "オリジナルの en-us.qmファイルはバックアップ済みです`r`n" 
    }
    else {
        Copy-Item -Path $srcFile -Destination $destFile
        echo "オリジナルの en-us.qmファイルを en-us-original.qm の名前で退避しましたr`n" 
    }
    Copy-Item -Path $destFile -Destination $backupFile
    $Input = Read-Host "リソースファイルを置き換えます。`r`n変更する場合は Enterキー、変更しない場合は「n」を入力後 Enterキーを押してください`r`n"
    if ($Input -eq 'n' -or $Input -eq 'N') {
        $Input = Read-Host "更新は行いません。Enterキーを押して終了してください"
        Exit
    }
    Copy-Item -Path $patchFile -Destination $srcFile
    $isRunning = 0
    try {
        $_item = (Get-Process -Name "N0vaDesktop" -ErrorAction Stop)
        $isRunning = 1
    } catch [Exception] {
        $isRunning = 0
    }
    if (Test-Path -Path $iconFile -PathType Leaf) {
        $Input = Read-Host "リンクファイル名「人工桌面」を 「N0va Desktop」に置き換えますか？ `r`n変更する場合は Enterキー、変更しない場合は「n」を入力後 Enterキーを押してください`r`n"
        if ($Input -eq 'n' -or $Input -eq 'N') {
            if ($isRunning) {
                $Input = Read-Host "更新は行いません。Enterキーを押して終了し、そのあとでタスクトレイの`r`n「N0va Desktop」アイコンを右クリックして「Exit」したあとで再び「N0va Desktop」を`r`n実行してください"
            } else {
                $Input = Read-Host "更新は行いません。Enterキーを押して終了してください"
            }
            Exit
        }
        Rename-Item -Path $iconFile $iconUsnameFile
    }
    if ($isRunning) {
        $Input = Read-Host "Enterキーを押して終了し、そのあとでタスクトレイの`r`n「N0va Desktop」アイコンを右クリックして「Exit」したあとで再び「N0va Desktop」を`r`n実行してください"
    } else {
        $Input = Read-Host "更新を行いました。Enterキーを押して終了してください"
    }
}
else {
    echo "N0va Desktopはインストールされていません`r`n"
    $Input = Read-Host "Enterキーを押して終了してください"
}
