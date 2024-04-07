@echo off

set file=""
set vlcExe=""
set vlcParams= --qt-start-minimized --fullscreen  --play-and-exit --no-video-title-show --no-video-deco --video-on-top --zoom=1.0 --dummy-quiet -I dummy
set fileFormats= *.webm *.mp4 *.ogg *.mov *.avi *.flv *.wmv
set delay=3

set path64="C:\Program Files\VideoLAN\VLC"
set path32="C:\Program Files (x86)\VideoLAN\VLC"

echo Searching for vlc.exe in %path64% and %path32%

cd %path64%
for /f "delims=" %%f in ('dir /b/s vlc.exe') do set "vlcExe=%%f"e

if not exist "%vlcExe%" (
    cd %path32%
    for /f "delims=" %%f in ('dir /b/s vlc.exe') do set "vlcExe=%%f"e
)

if not exist "%vlcExe%" (
    echo No valid vlc.exe found in %path64% and %path32%
    pause
    exit
)

echo vlc-player found %vlcExe%
cd %~dp0
for /f "delims=" %%f in ('dir /b %fileFormats%') do set "file=%%f"
if not exist "%file%" (
    echo No valid video file found in %~dp0
    pause
    exit
)


:VIDEOPARTY
for %%f in (%fileFormats%) do (
    start "" "%vlcExe%" %vlcParams% "%%f"
    call :waitForVideoToFinish
    timeout /t %delay% /nobreak >nul
)

goto VIDEOPARTY

:waitForVideoToFinish
rem Wait for VLC to finish playing the video
ping -n 1 127.0.0.1 >nul
timeout /t 1 /nobreak >nul
echo "pinging"
tasklist /nh /fi "imagename eq vlc.exe" | find /i "vlc.exe" >nul
if %errorlevel% equ 0 (
    rem VLC is still running, wait for a while and check again
    goto :waitForVideoToFinish
)
rem VLC has finished playing the video
exit /b