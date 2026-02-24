@echo off
echo Emptying the Recycle Bin...
rd /s /q %systemdrive%\$Recycle.Bin
cls
echo Recycle Bin has been cleared.
pause