@echo off
setlocal EnableExtensions
title 37abc COMBAT V5 - LOW PING + SMOOTH
color 0A

set "BACKUP=%ProgramData%\37ABC_Combat_V5_Backup"
set "ISADMIN=0"
fltmc >nul 2>&1 && set "ISADMIN=1"

cls
echo ============================================================
echo  37abc COMBAT V5 - LOW PING + SMOOTH
echo  GIU NGUYEN CORE V4 - KHONG TU DONG DONG CMD
echo ============================================================
echo.

if "%ISADMIN%"=="0" (
    color 0E
    echo [CANH BAO] Ban dang mo KHONG co quyen Administrator.
    echo NetworkThrottling / ECN / NIC latency se KHONG ap dung du.
    echo.
    echo De dung FULL V5: dong file nay, chuot phai file CMD ^> Run as administrator.
    echo Neu bam phim bat ky, V5 van chay phan SAFE nhu V4.
    pause >nul
    color 0A
) else (
    echo [ADMIN] OK - co the ap dung FULL network tweak.
)

echo.
if "%ISADMIN%"=="1" (
    if not exist "%BACKUP%" mkdir "%BACKUP%" >nul 2>&1
    if not exist "%BACKUP%\active_scheme.txt" powercfg /getactivescheme > "%BACKUP%\active_scheme.txt" 2>nul
)

echo [1/7] High Performance + Game Mode...
powercfg /setactive SCHEME_MIN >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1

rem High Performance thuong da de CPU min 100%% khi cam sac. Dat lai AC cho chac chan.
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
rem Wireless Adapter Power Saving Mode = Maximum Performance khi cam sac.
powercfg /setacvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

echo [2/7] RSS + TCP Auto-Tuning...
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1

if "%ISADMIN%"=="1" goto FULLTWEAK
goto AFTERFULL

:FULLTWEAK
if not exist "%BACKUP%\SystemProfile.reg" reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "%BACKUP%\SystemProfile.reg" /y >nul 2>&1
if not exist "%BACKUP%\Games.reg" reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "%BACKUP%\Games.reg" /y >nul 2>&1
if not exist "%BACKUP%\nic_advanced.xml" powershell -NoProfile -ExecutionPolicy Bypass -Command "try{Get-NetAdapter -Physical -ErrorAction Stop | ForEach-Object {Get-NetAdapterAdvancedProperty -Name $_.Name -AllProperties -ErrorAction SilentlyContinue} | Export-Clixml -LiteralPath '%BACKUP%\nic_advanced.xml'}catch{}" >nul 2>&1
if not exist "%BACKUP%\nic_power.xml" powershell -NoProfile -ExecutionPolicy Bypass -Command "try{Get-NetAdapter -Physical -ErrorAction Stop | ForEach-Object {Get-NetAdapterPowerManagement -Name $_.Name -ErrorAction SilentlyContinue} | Export-Clixml -LiteralPath '%BACKUP%\nic_power.xml'}catch{}" >nul 2>&1

echo [3/7] Bo network throttling + giam MMCSS reserve...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 10 /f >nul 2>&1

rem Uu tien task Games cua MMCSS.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >nul 2>&1

echo [4/7] Bat ECN de thu giam spike khi duong truyen nghen...
netsh int tcp set global ecncapability=enabled >nul 2>&1

echo [5/7] Giam latency cua card mang neu driver co ho tro...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $ad=Get-NetAdapter -Physical | Where-Object Status -eq 'Up'; foreach($a in $ad){ $ps=Get-NetAdapterAdvancedProperty -Name $a.Name -AllProperties; foreach($p in $ps){ $k=[string]$p.RegistryKeyword; $d=[string]$p.DisplayName; if($k -match 'EEE|EnergyEfficient|GreenEthernet' -or $d -match 'Energy Efficient|Green Ethernet'){ try{Set-NetAdapterAdvancedProperty -Name $a.Name -RegistryKeyword $k -RegistryValue 0 -NoRestart -ErrorAction Stop; Write-Host ('[NIC] EEE OFF: '+$a.Name)}catch{} }; if($k -match 'InterruptModeration' -or $d -match 'Interrupt Moderation'){ try{Set-NetAdapterAdvancedProperty -Name $a.Name -RegistryKeyword $k -RegistryValue 0 -NoRestart -ErrorAction Stop; Write-Host ('[NIC] Interrupt Moderation OFF: '+$a.Name)}catch{} } }; try{Set-NetAdapterPowerManagement -Name $a.Name -AllowComputerToTurnOffDevice Disabled -NoRestart -ErrorAction Stop; Write-Host ('[NIC] Power saving OFF: '+$a.Name)}catch{} }"

:AFTERFULL
echo [6/7] Game process = AboveNormal; background nhe = BelowNormal.
echo [7/7] GPU High Performance se tu gan cho EXE game/Flash neu tim thay path.
echo.
echo ------------------------------------------------------------
echo  MO 37abc BAY GIO.
echo  CMD se giu nguyen kieu loop cua V4, KHONG tu dong dong.
echo  Nhan Ctrl+C de dung monitor.
echo ------------------------------------------------------------
echo.

:loop
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $game=Get-Process | Where-Object {$_.ProcessName -match '37abc|flash|pepper|plugin|projector|ruffle'}; foreach($p in $game){ try{$p.PriorityClass='AboveNormal'; Write-Host ('[GAME ABOVE NORMAL] '+$p.ProcessName+' PID='+$p.Id)}catch{}; try{$path=$p.Path; if($path){$rk='HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'; if(!(Test-Path $rk)){New-Item $rk -Force | Out-Null}; $old=(Get-ItemProperty -Path $rk -Name $path -ErrorAction SilentlyContinue).$path; if($old -ne 'GpuPreference=2;'){New-ItemProperty -Path $rk -Name $path -Value 'GpuPreference=2;' -PropertyType String -Force | Out-Null; Write-Host ('[GPU HIGH NEXT LAUNCH] '+$path)}}}catch{}}; Get-Process -Name SearchIndexer,SearchHost,OneDrive,Widgets,WidgetService -ErrorAction SilentlyContinue | ForEach-Object {try{if($_.PriorityClass -ne 'BelowNormal'){$_.PriorityClass='BelowNormal'}}catch{}}"
timeout /t 2 /nobreak >nul
goto loop
