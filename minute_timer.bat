@echo off
REM Set the title of the command prompt window
title Timer

:START
REM Clear the screen
cls

REM Prompt the user to enter the duration in minutes
echo =================================
echo   Windows Timer with Notification
echo =================================
echo.
set /p minutes="Enter time in minutes and press Enter: "

REM Validate if the input is a number
echo %minutes%| findstr /r /c:"^[0-9][0-9]*$" > nul
if errorlevel 1 (
    echo.
    echo Error: Invalid input. Please enter a whole number.
    echo.
    pause
    goto START
)

REM Calculate the total duration in seconds
set /a seconds=%minutes% * 60

echo.
echo Timer started for %minutes% minute(s).
echo Press any key to cancel the timer...
echo.

REM Use PowerShell for the countdown with in-place update
powershell -Command ^
"$seconds = %seconds%; ^
$startPos = [Console]::CursorTop; ^
while ($seconds -gt 0) { ^
    [Console]::SetCursorPosition(0, $startPos); ^
    $mins = [Math]::Floor($seconds / 60); ^
    $secs = $seconds %% 60; ^
    Write-Host ('Time remaining: {0} minutes {1} seconds    ' -f $mins, $secs) -NoNewline; ^
    if ([Console]::KeyAvailable) { ^
        [Console]::SetCursorPosition(0, $startPos); ^
        Write-Host 'Timer cancelled!                                    '; ^
        Write-Host ''; ^
        $null = [Console]::ReadKey($true); ^
        exit 1; ^
    } ^
    Start-Sleep -Seconds 1; ^
    $seconds--; ^
} ^
[Console]::SetCursorPosition(0, $startPos); ^
Write-Host 'Time remaining: 0 minutes 0 seconds    '; ^
exit 0"

if errorlevel 1 (
    pause
    goto START
)

REM Use PowerShell to create and display a desktop notification.
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $global:balloon = New-Object System.Windows.Forms.NotifyIcon; $balloon.Icon = [System.Drawing.SystemIcons]::Information; $balloon.Visible = $true; $balloon.ShowBalloonTip(10000, 'Time\'s Up!', 'Your %minutes% minute timer has finished.', [System.Windows.Forms.ToolTipIcon]::Info);"

REM Clear screen for beep notification
cls
echo =================================
echo        TIMER FINISHED!
echo =================================
echo.
echo Your %minutes% minute timer has finished!
echo.
echo Press any key to stop the alarm and set another timer...
echo.

REM Play beep sound indefinitely until a key is pressed using PowerShell
powershell -Command "while (-not [Console]::KeyAvailable) { [Console]::Beep(1000, 500); Start-Sleep -Milliseconds 500 } $null = [Console]::ReadKey($true)"

REM Loop back to start
goto START