@echo off

rem I'm a comment

set file=""
set vlcExe=""
set vlcParams= --qt-start-minimized --fullscreen  --play-and-exit --no-video-title-show --no-video-deco --video-on-top --zoom=1.0 --dummy-quiet -I dummy
set fileFormats= *.webm *.mp4 *.ogg *.mov *.avi *.flv *.wmv
set delay=15

set path64="C:\Program Files\VideoLAN\VLC"
set path32="C:\Program Files (x86)\VideoLAN\VLC"

echo Searching for vlc.exe in %path64% and %path32%

rem Check if vlc.exe exists in the 64-bit path
cd %path64%
for /f "delims=" %%f in ('dir /b/s vlc.exe') do set "vlcExe=%%f"e

rem If vlc.exe is not found in the 64-bit path, check the 32-bit path
if not exist "%vlcExe%" (
    cd %path32%
    for /f "delims=" %%f in ('dir /b/s vlc.exe') do set "vlcExe=%%f"e
)

rem If vlc.exe is not found in either path, exit the script
if not exist "%vlcExe%" (
    echo No valid vlc.exe found in %path64% and %path32%
    pause
    exit
)

rem If vlc.exe is found, continue with the script it will be stored in the vlcExe variable
echo vlc-player found %vlcExe%

rem Change the current directory to the directory where the script is located
rem %~dp0 is a special variable that expands to the drive letter and path of the batch file
cd %~dp0

rem Check if there are any video files in the current directory
for /f "delims=" %%f in ('dir /b %fileFormats%') do set "file=%%f"
if not exist "%file%" (
    echo No valid video file found in %~dp0
    pause
    exit
)

rem If video files are found, start playing them in VLC one by one
:VIDEOPARTY
for %%f in (%fileFormats%) do (
    echo Playing %%f
    start "" "%vlcExe%" %vlcParams% "%%f"
    call :waitForVideoToFinish
    timeout /t %delay% /nobreak >nul
)

goto VIDEOPARTY

:waitForVideoToFinish
rem Wait for VLC to finish playing the video
ping -n 1 127.0.0.1 >nul
timeout /t 1 /nobreak >nul
echo "checking if VLC is still running"

rem Check if VLC is still running
tasklist /nh /fi "imagename eq vlc.exe" | find /i "vlc.exe" >nul

rem  The %errorlevel% variable is automatically set by the system to the exit code of the most recently executed command. If the `find` command found a match, it will exit with an error level of 0, otherwise it will exit with an error level of 1. So, `if %errorlevel% equ 0` is checking if the `find` command found a match, which would mean that a process with the image name `vlc.exe` is currently running.
if %errorlevel% equ 0 (
    rem VLC is still running, wait for a while and check again
    goto :waitForVideoToFinish
)
rem VLC has finished playing the video
exit /b