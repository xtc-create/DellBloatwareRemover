# Remove Dell Bloatware & Waves Audio on Windows 11

$remediationscript = @"
REM ------------------- Dell & Waves Cleanup for Windows 11 -------------------

REM Dell Command | Update
echo "Uninstalling Dell Command | Update..."
MsiExec.exe /X{5669AB71-1302-4412-8DA1-CB69CD7B7324} /quiet
MsiExec.exe /X{4CCADC13-F3AE-454F-B724-33F6D4E52022} /quiet
MsiExec.exe /X{EC542D5D-B608-4145-A8F7-749C02BE6D94} /quiet
MsiExec.exe /X{41D2D254-D869-4CD8-B440-5DF49083C4BA} /quiet

REM Dell Update
echo "Uninstalling Dell Update..."
MsiExec.exe /I{D8AE5F9D-647C-49B4-A666-1C20B44EC0E1} /quiet

REM Dell Digital Delivery
echo "Uninstalling Dell Digital Delivery..."
MsiExec.exe /X{CC5730C7-C867-43BD-94DA-00BB3836906F} /quiet

REM Dell Optimizer
echo "Uninstalling Dell Optimizer..."
"C:\Program Files (x86)\InstallShield Installation Information\{286A9ADE-A581-43E8-AA85-6F5D58C7DC88}\DellOptimizer.exe" -remove -runfromtemp -silent 2> nul

REM Dell SupportAssist
echo "Uninstalling Dell SupportAssist and related plugins..."
"C:\Program Files\Dell\SupportAssistAgent\bin\SupportAssistUninstaller.exe" /S 2> nul

REM Dell Power Manager
echo "Uninstalling Dell Power Manager..."
MsiExec.exe /X{18469ED8-8C36-4CF7-BD43-0FC9B1931AF8} /quiet

REM Waves Audio Service
echo "Stopping and removing Waves Audio Service..."
sc stop "Waves Audio Service" 2> nul
sc delete "Waves Audio Service" 2> nul

REM Delete leftover Waves folders
rmdir /s /q "C:\Program Files\Waves" 2> nul
rmdir /s /q "C:\Program Files (x86)\Waves" 2> nul
rmdir /s /q "C:\ProgramData\Waves Audio" 2> nul
rmdir /s /q "C:\ProgramData\Waves" 2> nul

REM Remove Waves drivers from DriverStore
echo "Removing Waves drivers from DriverStore..."
for /f "tokens=*" %%i in ('pnputil /enum-drivers ^| findstr /i waves') do (
    echo Deleting driver %%i
    for /f "tokens=2 delims=:" %%a in ("%%i") do (
        pnputil /delete-driver %%a /uninstall /force 2> nul
    )
)

REM Waves Audio Drivers Removal (specific INF names)
echo "Removing specific Waves drivers..."
$wavesDrivers = @(
    "dellaudioextwaves.inf",
    "hdx_dellcsmbext_waves_ma11.inf",
    "wavesdmic_agc.inf",
    "wavesapo12de.inf"
)
foreach ($driver in $wavesDrivers) {
    Write-Host "Attempting to uninstall driver: $driver"
    pnputil /delete-driver $driver /uninstall /force 2> nul
}

REM Dell Foundation Services
echo "Uninstalling Dell Foundation Services..."
MsiExec.exe /X{BDB50421-E961-42F3-B803-6DAC6F173834} /quiet

REM Dell Protected Workspace
echo "Uninstalling Dell Protected Workspace..."
MsiExec.exe /X{E2CAA395-66B3-4772-85E3-6134DBAB244E} /quiet

echo "Cleanup finished!"
"@

# Save the script as a temporary batch file and execute it
$bat = "$env:SystemRoot\Temp\dell_waves_cleanup.bat"
Set-Content -Value $remediationscript -Path $bat -Encoding Ascii
Start-Process $bat -Wait -PassThru
