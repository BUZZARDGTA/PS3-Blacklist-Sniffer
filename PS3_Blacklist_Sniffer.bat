::------------------------------------------------------------------------------
:: NAME
::     PS3_Blacklist_Sniffer.bat - PS3 Blacklist Sniffer
::
:: DESCRIPTION
::     Track your blacklisted people new usernames and IPs.
::     Detect blacklisted people who are trying
::     to connect in or who are already in to your session.
::
:: REQUIREMENTS
::     Windows 8, 8.1, 10, 11 (x86/x64)
::     Wireshark (with Npcap/Winpcap installed)
::     webMAN MOD ((PS3 Notification) not obligatory)
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::
:: CREDITS
::     @Rosalyn - *giving me the force*
::     @NotYourDope - Helped me for generating the PS3 console notifications.
::     @NotYourDope - Helped me for English translations.
::     @Simi - Helped me for some English translations.
::     @Grub4K - Creator of the timer algorithm.
::     @Grub4K - Quick analysis of the source code to improve it.
::     @Grub4K and @Sintrode
::     Helped me solve and understand a Batch bug with "FOR" loop variables.
::     @sintrode and https://www.dostips.com/forum/viewtopic.php?t=6560
::     ^^ "How to put inner quotes in outer quotes in "FOR" loop?"
::
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
@echo off
cls
>nul chcp 65001
setlocal DisableDelayedExpansion
pushd "%~dp0"
for /f %%A in ('copy /z "%~nx0" nul') do set "\R=%%A"
for /f %%A in ('forfiles /m "%~nx0" /c "cmd /c echo(0x08"') do (
    set "\B=%%A"
)
set "@MSGBOX=(if not exist "lib\msgbox.vbs" (call :MSGBOX_GENERATION)) & "
set "@ADMINISTRATOR_MANIFEST_REQUIRED=mshta vbscript:Execute^("msgbox ""!TITLE! does not have enough permissions to write '!?!' to your disk at this location."" ^& Chr(10) ^& Chr(10) ^& ""Run '%~nx0' as administrator and try again."",69648,""!TITLE!"":close"^) & exit"
set "@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME=(mshta vbscript:Execute^("msgbox ""The custom PATH you entered for '?' in 'Settings.ini' is invalid or !TITLE! does not have enough permissions to write to your disk at this location."" ^& Chr(10) ^& Chr(10) ^& ""Run '%~nx0' as administrator and try again."",69648,""!TITLE!"":close"^) & exit)"
setlocal EnableDelayedExpansion
set "@LOOKUP_WINDOWS_VERSIONS=`10.0`6.3`6.2`6.1`"
set "@LOOKUP_PSN_LENGTH=`136`1160`"
set "@LOOKUP_IPLOOKUP_FIELDS=`status`message`continent`continentCode`country`countryCode`region`regionName`city`district`zip`lat`lon`timezone`offset`currency`isp`org`as`asname`reverse`mobile`proxy`hosting`query`proxy_2`type`"
(set \N=^
%=leave unchanged=%
)
if defined ProgramFiles(x86) (
    set "PATH=!PATH!;lib\Curl\x64"
) else (
    set "PATH=!PATH!;lib\Curl\x32"
)
for %%A in (
    "VERSION"
    "last_version"
) do (
    if defined %%A (
        set old_%%A=!%%A!
    )
)
if "%~nx0"=="[UPDATED]_PS3_Blacklist_Sniffer.bat" (
    for /f "tokens=2delims=," %%A in ('tasklist /v /fo csv /fi "imagename eq cmd.exe" ^| find /i "PS3 Blacklist Sniffer"') do (
        >nul 2>&1 taskkill /f /pid "%%~A" /t
    )
    >nul move /y "%~nx0" "PS3_Blacklist_Sniffer.bat" && (
        start "" "PS3_Blacklist_Sniffer.bat" && (
            exit
        )
    )
)
set VERSION=v2.1.0 - 04/01/2022
set TITLE=PS3 Blacklist Sniffer !VERSION:~0,6!
title !TITLE!
echo:
for /f "tokens=4-7delims=[.] " %%A in ('ver') do (
    if /i "%%A"=="version" (
        set "WINDOWS_VERSION=%%B.%%C"
    ) else (
        set "WINDOWS_VERSION=%%A.%%B"
    )
)
if "!@LOOKUP_WINDOWS_VERSIONS:`%WINDOWS_VERSION%`=!"=="!@LOOKUP_WINDOWS_VERSIONS!" (
    %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "Your computer does not reach the minimum Windows version compatible with !TITLE!.!\N!!\N!You need Windows 7 or higher." 69648 "!TITLE!"
    exit
)
echo Searching for a new update ...
call :UPDATER
>nul 2>&1 sc query npcap || (
    >nul 2>&1 sc query npf || (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not detect the 'Npcap' or 'WinpCap' driver installed on your system.!\N!!\N!Redirecting you to Npcap download page." 69648 "!TITLE!"
        start "" "https://nmap.org/npcap/"
        exit
    )
)
for %%A in (
    "ARP.EXE"
    "curl.exe"
) do (
    >nul 2>&1 where "%%~A" || (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find '%%~A' executable in your system PATH.!\N!!\N!Your system does not meet the minimum software requirements to use !TITLE!." 69648 "!TITLE!"
        exit
    )
)
:SETUP
echo:
echo Applying your custom settings from 'Settings.ini' ...
for %%A in (
    "@WINDOWS_TSHARK_STDERR"
    "@PS3_IP_ADDRESS"
    "@PS3_MAC_ADDRESS"
    "@PS3_NOTIFICATIONS_ABOVE_SOUND"
    "settings_number"
    "generate_new_settings_file"
    "notepad_pid"
    "ps3_connected_notification"
) do (
    if defined %%~A (
        set %%~A=
    )
)
for %%A in (
    "WINDOWS_TSHARK_PATH"
    "WINDOWS_TSHARK_STDERR"
    "WINDOWS_BLACKLIST_PATH"
    "WINDOWS_RESULTS_LOGGING"
    "WINDOWS_RESULTS_LOGGING_PATH"
    "WINDOWS_NOTIFICATIONS"
    "WINDOWS_NOTIFICATIONS_TIMER"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER"
    "PS3_IP_AND_MAC_ADDRESS_AUTOMATIC"
    "PS3_IP_ADDRESS"
    "PS3_MAC_ADDRESS"
    "PS3_PROTECTION"
    "PS3_NOTIFICATIONS"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND"
    "PS3_NOTIFICATIONS_ABOVE"
    "PS3_NOTIFICATIONS_ABOVE_ICON"
    "PS3_NOTIFICATIONS_ABOVE_SOUND"
    "PS3_NOTIFICATIONS_ABOVE_TIMER"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER"
    "PS3_NOTIFICATIONS_BOTTOM"
    "PS3_NOTIFICATIONS_BOTTOM_SOUND"
    "PS3_NOTIFICATIONS_BOTTOM_TIMER"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER"
    "DETECTION_TYPE_DYNAMIC_IP_PRECISION"
) do (
    if defined %%~A (
        set %%~A=
    )
    if exist "Settings.ini" (
        set first_1=1
        for /f "tokens=1*delims==" %%B in ('findstr /bc:"%%~A=" "Settings.ini"') do (
            set /a settings_number+=1
            if defined first_1 (
                set first_1=
                if "%%~B"=="WINDOWS_TSHARK_PATH" (
                    set "%%~B=%%~C"
                    call :CREATE_WINDOWS_TSHARK_PATH
                )
                if "%%~B"=="WINDOWS_TSHARK_STDERR" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                            if "%%~C"=="false" (
                                set "@%%~B=2^>nul "
                            )
                        )
                    )
                )
                if "%%~B"=="WINDOWS_BLACKLIST_PATH" (
                    set "%%~B=%%~C"
                    call :CREATE_WINDOWS_BLACKLIST_FILE
                )
                if "%%~B"=="WINDOWS_RESULTS_LOGGING" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="WINDOWS_RESULTS_LOGGING_PATH" (
                    set "%%~B=%%~C"
                    call :CREATE_WINDOWS_RESULTS_LOGGING_FILE
                )
                if "%%~B"=="WINDOWS_NOTIFICATIONS" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="WINDOWS_NOTIFICATIONS_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="PS3_IP_AND_MAC_ADDRESS_AUTOMATIC" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_IP_ADDRESS" (
                    set "x=%%~C"
                    call :CHECK_IP x && (
                        set "%%~B=%%~C"
                    )
                )
                if "%%~B"=="PS3_MAC_ADDRESS" (
                    set "x=%%~C"
                    call :CHECK_MAC x && (
                        set "%%~B=%%~C"
                    )
                )
                if "%%~B"=="PS3_PROTECTION" (
                    for %%D in (false Reload_Game Exit_Game Restart_PS3 Shutdown_PS3) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON" (
                    for /l %%D in (0,1,50) do (
                        if "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_ABOVE" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_ICON" (
                    for /l %%D in (0,1,50) do (
                        if "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="DETECTION_TYPE_DYNAMIC_IP_PRECISION" (
                    for %%D in (1 2 3) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
            )
        )
    ) else (
        set generate_new_settings_file=1
    )
)
if not "!settings_number!"=="28" (
    set generate_new_settings_file=1
)
if not defined WINDOWS_TSHARK_PATH (
    call :CREATE_WINDOWS_TSHARK_PATH
)
for %%A in (
    "WINDOWS_TSHARK_STDERR=true"
    "WINDOWS_BLACKLIST_PATH=Blacklist.ini"
    "WINDOWS_RESULTS_LOGGING=true"
    "WINDOWS_RESULTS_LOGGING_PATH=Logs.txt"
    "WINDOWS_NOTIFICATIONS=true"
    "WINDOWS_NOTIFICATIONS_TIMER=0"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL=true"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER=120"
    "PS3_IP_AND_MAC_ADDRESS_AUTOMATIC=true"
    "PS3_PROTECTION=false"
    "PS3_NOTIFICATIONS=true"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON=22"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=5"
    "PS3_NOTIFICATIONS_ABOVE=true"
    "PS3_NOTIFICATIONS_ABOVE_ICON=23"
    "PS3_NOTIFICATIONS_ABOVE_SOUND=3"
    "PS3_NOTIFICATIONS_ABOVE_TIMER=0"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL=true"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER=120"
    "PS3_NOTIFICATIONS_BOTTOM=true"
    "PS3_NOTIFICATIONS_BOTTOM_SOUND=8"
    "PS3_NOTIFICATIONS_BOTTOM_TIMER=0"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL=true"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER=3"
    "DETECTION_TYPE_DYNAMIC_IP_PRECISION=3"
) do (
    for /f "tokens=1*delims==" %%B in ("%%~A") do (
        if not defined %%~B (
            set "%%~B=%%~C"
            set generate_new_settings_file=1
        )
    )
)
if %PS3_NOTIFICATIONS%==true (
    if %PS3_NOTIFICATIONS_ABOVE%==false (
        if %PS3_NOTIFICATIONS_BOTTOM%==false (
            set PS3_NOTIFICATIONS=false
            set generate_new_settings_file=1
        )
    )
)
if defined generate_new_settings_file (
    echo:
    echo Correct reconstruction of 'Settings.ini' ...
    call :CREATE_SETTINGS_FILE
    goto :SETUP
)
title Capture network interface selection - !TITLE!
:CHOOSE_INTERFACE
cls
echo:
"!WINDOWS_TSHARK_PATH!" -D
set x=
for /f "tokens=2delims=()" %%A in ('"!WINDOWS_TSHARK_PATH!" -D') do (
    set /a x+=1
    set "Interface_!x!=%%A"
)
echo:
set CAPTURE_INTERFACE=
set /p "CAPTURE_INTERFACE=Select your desired capture network interface (1,1,!x!): "
for /l %%A in (1,1,!x!) do (
    if "%%A"=="!CAPTURE_INTERFACE!" (
        goto :START
    )
)
goto :CHOOSE_INTERFACE
:START
cls
title Cleaning temporary files - !TITLE!
echo:
echo Cleaning incorrect, invalid or unnecessary temporary !TITLE! files ...
if exist "lib\tmp\_blacklisted_psn_hexadecimal.tmp" (
    del /f /q "lib\tmp\_blacklisted_psn_hexadecimal.tmp"
)
<nul set /p="Checking temporary file 'blacklisted_psn_hexadecimal.tmp' ...!\R!"
if exist "!WINDOWS_BLACKLIST_PATH!" (
    if exist "lib\tmp\blacklisted_psn_hexadecimal.tmp" (
        for /f "usebackqtokens=1,2delims==" %%A in ("lib\tmp\blacklisted_psn_hexadecimal.tmp") do (
            set first_6=1
            for /f "usebackqdelims==" %%C in ("!WINDOWS_BLACKLIST_PATH!") do (
                if defined first_6 (
                    if "%%~A"=="%%~C" (
                        set first_6=
                        >nul 2>&1 findstr /bc:"%%~A=%%~B" "lib\tmp\_blacklisted_psn_hexadecimal.tmp" || (
                            >>"lib\tmp\_blacklisted_psn_hexadecimal.tmp" (
                                echo %%~A=%%~B
                            )
                        )
                    )
                )
            )
        )
        >nul move /y "lib\tmp\_blacklisted_psn_hexadecimal.tmp" "lib\tmp\blacklisted_psn_hexadecimal.tmp"
        set first_6=
    )
)
for %%A in ("lib\tmp\dynamic_iplookup_*.tmp") do (
    <nul set /p="Deleting temporary file '%%~nxA' ...                                        !\R!"
    del /f /q "%%~A"
)
for %%A in ("lib\tmp\blacklisted_iplookup_*.tmp") do (
    <nul set /p="Checking temporary file '%%~nxA' ...                                        !\R!"
    if defined files_to_delete (
        set files_to_delete=
    )
    for /f "usebackqtokens=1,2delims==" %%B in ("lib\tmp\%%~nxA") do (
        if not "%%~B"=="" (
            if not "%%~C"=="" (
                if "%%~B"=="proxy_2" (
                    if "%%~C"=="N/A" (
                        set "files_to_delete=%%~A"
                    )
                )
                if defined files_to_delete (
                    if "%%~B"=="type" (
                        if "%%~C"=="N/A" (
                            <nul set /p="Deleting temporary file '%%~nxA' ...                                        !\R!"
                            del /f /q "%%~A"
                        )
                    )
                )
            )
        )
    )
)
if defined files_to_delete (
    set files_to_delete=
)
if exist "!WINDOWS_BLACKLIST_PATH!" (
    for %%A in ("lib\tmp\blacklisted_iplookup_*.tmp") do (
        <nul set /p="Checking temporary file '%%~nxA' ...                                        !\R!"
        set first_0=1
        set "x=%%~nA"
        for /f "usebackqtokens=1,2delims==" %%B in ("!WINDOWS_BLACKLIST_PATH!") do (
            if defined first_0 (
                if not "%%~B"=="" (
                    if not "%%~C"=="" (
                        if not "!x:%%~C=!"=="!x!" (
                            set first_0=
                        )
                    )
                )
            )
        )
        if defined first_0 (
            <nul set /p="Deleting temporary file '%%~nxA' ...                                        !\R!"
            del /f /q "%%~A"
        )
    )
)
title Initializing addresses and establishing connection to your PS3 console - !TITLE!
echo:
if !PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!==true (
    echo Initializing addresses and establishing connection to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    set /a search_ps3_ip_address=1, first_2=1
    call :PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
    if defined PS3_IP_ADDRESS (
        call :CHECK_WEBMAN_MOD_CONNECTION PS3_IP_ADDRESS PS3_MAC_ADDRESS && (
            set search_ps3_ip_address=
            set first_2=
        )
    )
    for /f "tokens=1,2" %%A in ('ARP -a') do (
        if not "%%~A"=="" (
            if not "%%~B"=="" (
                set "x1=%%~A"
                call :CHECK_IP x1 && (
                    set "local_ip_!x1!=1"
                    set "x2=%%~B"
                    set "x2=!x2:-=:!"
                    if defined search_ps3_ip_address (
                        call :CHECK_MAC x2 && (
                            if defined first_2 (
                                set first_2=
                                echo PS3 console IP and MAC addresses not found.
                                echo Attempting the automatic detection of your PS3 console ...
                                echo:
                            )
                            echo Trying connection on local: "!x1!"
                            call :CHECK_WEBMAN_MOD_CONNECTION x1 x2 && (
                                set search_ps3_ip_address=
                                set "PS3_IP_ADDRESS=!x1!"
                                set "PS3_MAC_ADDRESS=!x2!"
                                call :CREATE_SETTINGS_FILE
                            )
                        )
                    )
                )
            )
        )
    )
    for %%A in (
        "search_ps3_ip_address"
        "first_2"
        "x1"
        "x2"
    ) do (
        set %%~A=
    )
) else if defined PS3_IP_ADDRESS (
    echo Establishing connection to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    call :CHECK_WEBMAN_MOD_CONNECTION PS3_IP_ADDRESS PS3_MAC_ADDRESS
)
title Computing ascii PSN usernames to hexadecimal in memory - !TITLE!
:LOOP_BLACKLIST_FILE_EMPTY
cls
echo:
if defined ps3_connected_notification (
    echo Successfully connected to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
) else (
    echo Error: Unable to connect to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    echo Make sure you have the following:
    echo - Your PS3 console must be turned on.
    echo - If you have a HEN jailbreaked console, make sure HEN is enabled.
    echo - webMAN MOD is correctly configured on your PS3 console.
    if not defined PS3_IP_ADDRESS (
        echo PS3 notifications disabled for this session.
    )
)
echo:
for %%A in (
    "blacklisted_psn_invalid_"
    "blacklisted_ip_invalid_"
) do (
    >nul 2>&1 set %%~A && (
        for /f "delims==" %%B in ('set %%~A') do (
            set "%%~B="
        )
    )
)
if exist "!WINDOWS_BLACKLIST_PATH!" (
    echo Computing ascii PSN usernames to hexadecimal in memory and
    echo checking "!WINDOWS_BLACKLIST_PATH!" PSN Usernames and IP Addresses ...
    for /f "usebackqtokens=1,2delims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
        for %%C in (
            "blacklisted_psn_disp"
            "blacklisted_ip_disp"
            "invalid_result_found"
        ) do (
            if defined %%~C (
                set %%~C=
            )
        )
        if not "%%~A"=="" (
            set "blacklisted_psn=%%~A"
            set "blacklisted_ip=%%~B"
            set "blacklisted_psn_disp=!blacklisted_psn:~0,16!"
            if not "%%~B"=="" (
                set "blacklisted_ip_disp=!blacklisted_ip:~0,15!"
            )
            <nul set /p="Processing blacklisted entry [!blacklisted_psn_disp!=!blacklisted_ip_disp!] ...                              !\R!"
            call :ASCII_TO_HEXADECIMAL || (
                set /a "blacklisted_psn_invalid_%%~A=1", invalid_result_found=1
                <nul set /p="Blacklisted entry [!blacklisted_psn_disp!=!blacklisted_ip_disp!] does not contain a valid PSN username."
                echo:
            )
            if not "%%~B"=="" (
                call :CHECK_IP blacklisted_ip || (
                    set /a "blacklisted_ip_invalid_%%~A=1", invalid_result_found=1
                    <nul set /p="Blacklisted entry [!blacklisted_psn_disp!=!blacklisted_ip_disp!] does not contain a valid IP address."
                    echo:
                )
            )
        )
    )
    if defined invalid_result_found (
        set invalid_result_found=
    ) else (
        <nul set /p=".!\B!                                                                   "
    )
    for %%A in (
        "blacklisted_psn"
        "blacklisted_psn_disp"
        "blacklisted_ip"
        "blacklisted_ip_disp"
    ) do (
        set %%~A=
    )
) else (
    call :CREATE_WINDOWS_BLACKLIST_FILE
    goto :LOOP_BLACKLIST_FILE_EMPTY
)
echo:
>nul 2>&1 set blacklisted_psn_invalid_ && (
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo Unable to perform the username search for this entrie^(s^) in your 'WINDOWS_BLACKLIST_PATH' setting.
    echo Please ensure the username is correct, and check for the following errors:
    echo PSN usernames must consist of 3-16 characters, and only contain: [a-z] [A-Z] [0-9] [-] [_]
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo:
)
>nul 2>&1 set blacklisted_ip_invalid_ && (
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo Unable to perform the username search for this entrie^(s^) in your 'WINDOWS_BLACKLIST_PATH' setting.
    echo Please ensure the IP Address is correct, and check for the following errors:
    echo The IP address must be composed of 4 octets of a number from 0 to 255 each separated by a dot.
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo:
)
:WAIT_FILE_SAVED_WINDOWS_BLACKLIST_PATH
>nul 2>&1 set blacklisted_psn_hexadecimal_ || (
    if defined notepad_pid (
        tasklist /v /fo csv /fi "pid eq !notepad_pid!" | >nul find /i "notepad.exe" || (
            set notepad_pid=
        )
    )
    if not defined notepad_pid (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find any valid users in your 'WINDOWS_BLACKLIST_PATH' setting.!\N!!\N!Add your first entry to start scanning." 69648 "!TITLE!"
        start "" "!WINDOWS_BLACKLIST_PATH!"
        for /f "tokens=2delims=," %%A in ('tasklist /v /fo csv /fi "imagename eq notepad.exe" ^| find /i "notepad.exe"') do (
            set "notepad_pid=%%~A"
        )
    )
    if exist "!WINDOWS_BLACKLIST_PATH!" (
        for /f "usebackqdelims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
            if not "%%~A"=="" (
                goto :LOOP_BLACKLIST_FILE_EMPTY
            )
        )
    ) else (
        call :CREATE_WINDOWS_BLACKLIST_FILE
    )
    goto :WAIT_FILE_SAVED_WINDOWS_BLACKLIST_PATH
)
if defined PS3_IP_ADDRESS (
    set "@PS3_IP_ADDRESS=dst or src host !PS3_IP_ADDRESS! and "
    if "!VERSION:~1,3!" lss "!last_version:~1,3!" (
        >nul curl -fkLs "http://%PS3_IP_ADDRESS%/notify.ps3mapi?msg=!TITLE: =+!:%%0D%%0AA+newer+version+is+detected+(v!last_version:~0,3!).&icon=21&snd=5"
    )
)
if defined PS3_MAC_ADDRESS (
    set "@PS3_MAC_ADDRESS=ether dst or src !PS3_MAC_ADDRESS! and "
)
set "CAPTURE_FILTER=!@PS3_IP_ADDRESS!!@PS3_MAC_ADDRESS!ip and udp and not broadcast and not multicast and not port 443 and not port 80 and not port 53 and not net 3.237.117.0/24 and not net 52.40.62.0/24 and not net 162.244.52.0/23 and not net 185.34.107.0/24"
if defined CAPTURE_FILTER (
    if "!CAPTURE_FILTER:~-5!"==" and " (
        set "CAPTURE_FILTER=!CAPTURE_FILTER:~0,-5!"
    )
)
title Sniffin' my babies IPs.   ^|IP:!PS3_IP_ADDRESS!^|   ^|MAC:!PS3_MAC_ADDRESS!^|   ^|Interface:!Interface_%CAPTURE_INTERFACE%!^| - !TITLE!
echo Started capturing on network interface "!Interface_%CAPTURE_INTERFACE%!" ...
echo:
for /l %%? in () do (
    if exist "!WINDOWS_TSHARK_PATH!" (
        if exist "!WINDOWS_BLACKLIST_PATH!" (
            for %%A in (
                "blacklisted_found_"
                "skip_static_"
                "skip_lookup_"
                "skip_dynamic_"
                "skip_ps3_protection"
            ) do (
                >nul 2>&1 set %%~A && (
                    for /f "delims==" %%B in ('set %%~A') do (
                        set "%%~B="
                    )
                )
            )
            for /f "usebackqtokens=1,2delims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
                if not "%%~A"=="" (
                    if not defined blacklisted_psn_hexadecimal_%%~A (
                        set "blacklisted_psn=%%~A"
                        call :ASCII_TO_HEXADECIMAL
                    )
                )
            )
            for /f "tokens=1-8" %%A in ('^"%@WINDOWS_TSHARK_STDERR%"!WINDOWS_TSHARK_PATH!" -q -Q -i !CAPTURE_INTERFACE! -f "!CAPTURE_FILTER!" -Y "frame.len^>^=68 and frame.len^<^=1160" -Tfields -Eseparator^=/s -e ip.src_host -e ip.src -e udp.srcport -e ip.dst_host -e ip.dst -e udp.dstport -e data -e frame.len -a duration:1^"') do (
                if not "%%~A"=="" (
                    if not "%%~B"=="" (
                        if not "%%~C"=="" (
                            if not "%%~D"=="" (
                                if not "%%~E"=="" (
                                    if not "%%~F"=="" (
                                        if not "%%~G"=="" (
                                            if not "%%~H"=="" (
                                                set "hexadecimal_packet=%%~G"
                                                set "frame_len=%%~H"
                                                if defined local_ip_%%~B (
                                                    set "reverse_ip=%%~D"
                                                    set "ip=%%~E"
                                                    set "port=%%~F"
                                                    set "way=src"
                                                    call :BLACKLIST_SEARCH
                                                ) else (
                                                    set "reverse_ip=%%~A"
                                                    set "ip=%%~B"
                                                    set "port=%%~C"
                                                    set "way=dst"
                                                    call :BLACKLIST_SEARCH
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ) else (
            call :CREATE_WINDOWS_BLACKLIST_FILE
        )
    ) else (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find your 'WINDOWS_TSHARK_PATH' setting on your system.!\N!!\N!Redirecting you to Wireshark download page.!\N!!\N!You can also define your own PATH in the 'Settings.ini' file." 69648 "!TITLE!"
        exit
    )
)
exit /b

:BLACKLIST_SEARCH
if defined local_ip_%ip% (
    exit /b 0
)
if defined blacklisted_found_%ip% (
    exit /b 0
)
if defined skip_static_%ip% (
    if defined skip_lookup_%ip% (
        if defined skip_dynamic_%ip% (
            exit /b 0
        )
    )
)
if "%ip:~0,8%"=="192.168." (
    set "local_ip_%ip%=1"
    exit /b 0
) else if "%ip:~0,3%"=="10." (
    set "local_ip_%ip%=1"
    exit /b 0
) else if "%ip:~0,4%"=="172." (
    for /l %%A in (16,1,31) do (
        if "%ip:~4,3%"=="%%~A." (
            set "local_ip_%ip%=1"
            exit /b 0
        )
    )
) else if "%ip:~0,4%"=="100." (
    for /l %%A in (64,1,99) do (
        if "%ip:~4,3%"=="%%~A." (
            set "local_ip_%ip%=1"
            exit /b 0
        )
    )
    for /l %%A in (100,1,127) do (
        if "%ip:~4,4%"=="%%~A." (
            set "local_ip_%ip%=1"
            exit /b 0
        )
    )
)
set psn_ascii=
if not defined skip_lookup_%ip% (
    set "skip_lookup_%ip%=1"
    if not "!@LOOKUP_PSN_LENGTH:`%frame_len%`=!"=="!@LOOKUP_PSN_LENGTH!" (
        if not "!hexadecimal_packet:FF83FFFEFFFE=!"=="!hexadecimal_packet!" (
            if not "!hexadecimal_packet:707333=!"=="!hexadecimal_packet!" (
                set "psn_hexadecimal=!hexadecimal_packet:*FF83FFFEFFFE=!"
                if !way!==src (
                    set "psn_hexadecimal=!psn_hexadecimal:~72,32!"
                ) else (
                    set "psn_hexadecimal=!psn_hexadecimal:~8,32!"
                )
                set "psn_hexadecimal=!psn_hexadecimal:00=!"
                if defined blacklisted_psn_ascii_!psn_hexadecimal! (
                    for %%A in ("^!blacklisted_psn_ascii_!psn_hexadecimal!^!") do (
                        set "blacklisted_psn=%%~A"
                    )
                    set "blacklisted_detection_type=PSN Username"
                    call :BLACKLISTED_FOUND
                    exit /b 0
                )
                call :HEXADECIMAL_TO_ASCII
            )
        )
    )
)
if not defined skip_static_%ip% (
    set "skip_static_%ip%=1"
    for /f "tokens=1,2delims==" %%A in ('find "=%ip%" "!WINDOWS_BLACKLIST_PATH!"') do (
        if "%ip%"=="%%~B" (
            set "blacklisted_psn=%%~A"
            set "blacklisted_detection_type=Static IP"
            call :BLACKLISTED_FOUND
            exit /b 0
        )
    )
)
if not defined skip_dynamic_%ip% (
    set "skip_dynamic_%ip%=1"
    call :DETECTION_TYPE_FORM_PRECISION ip dynamic_ip
    >nul 2>&1 set skip_dynamic_try_ && (
        for /f "delims==" %%A in ('set skip_dynamic_try_') do (
            set "%%~A="
        )
    )
    for /f "tokens=1,2delims==" %%A in ('find "=!dynamic_ip!" "!WINDOWS_BLACKLIST_PATH!"') do (
        if not "%%~A"=="" (
            if not "%%~B"=="" (
                set "x=%%~A"
                if not "!x:~0,2!"==";;" (
                    if not defined skip_dynamic_try_%%~B (
                        set "skip_dynamic_try_%%~B=1"
                        set "x=%%~B"
                        call :DETECTION_TYPE_FORM_PRECISION x blacklisted_dynamic_ip
                        if "!dynamic_ip!"=="!blacklisted_dynamic_ip!" (
                            if not exist "lib\tmp\dynamic_iplookup_%ip%.tmp" (
                                call :IPLOOKUP dynamic %ip%
                            )
                            if not exist "lib\tmp\blacklisted_iplookup_%%~B.tmp" (
                                call :IPLOOKUP blacklisted %%~B
                            )
                            if defined dynamic_iplookup_dif (
                                set dynamic_iplookup_dif=
                            )
                            for /f "usebackqtokens=1,2delims==" %%C in ("lib\tmp\dynamic_iplookup_%ip%.tmp") do (
                                for /f "usebackqtokens=1,2delims==" %%E in ("lib\tmp\blacklisted_iplookup_%%~B.tmp") do (
                                    if "%%~C"=="%%~E" (
                                        if not "%%~C%%~D"=="%%~E%%~F" (
                                            if not "%%~C"=="status" (
                                                if not "%%~C"=="message" (
                                                    if not "%%~C"=="reverse" (
                                                        if not "%%~C"=="query" (
                                                            if not "%%~C"=="proxy_2" (
                                                                if not "%%~C"=="type" (
                                                                    set dynamic_iplookup_dif=1
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                            echo hi
                            if not defined dynamic_iplookup_dif (
                                echo hilol
                                set "blacklisted_psn=%%~A"
                                set "blacklisted_detection_type=Dynamic IP (bad accuracy*)"
                                call :BLACKLISTED_FOUND
                                exit /b 0
                            )
                        )
                    )
                )
            )
        )
    )
)
exit /b 1

:BLACKLISTED_FOUND
for /f "tokens=2delims==." %%A in ('wmic os get LocalDateTime /value') do (
    set "datetime=%%A"
    set "datetime=!datetime:~0,-10!-!datetime:~-10,2!-!datetime:~-8,2!_!datetime:~-6,2!-!datetime:~-4,2!-!datetime:~-2!"
    set "hourtime=!datetime:~11,2!:!datetime:~14,2!"
)
if not defined blacklisted_found_%ip% (
    set blacklisted_found_%ip%=1
)
if defined psn_ascii (
    call :BLACKLIST_WRITE psn_ascii
)
call :BLACKLIST_WRITE blacklisted_psn
if not defined blacklisted_iplookup_%ip% (
    call :IPLOOKUP blacklisted %ip%
)
set blacklisted_psn_list_counter=1
set "@blacklisted_psn_list=[%blacklisted_psn%]"
set "@ps3_blacklisted_psn_list=%%5B%blacklisted_psn%%%5D"
for /f "delims==" %%A in ('find "%blacklisted_psn%=" "!WINDOWS_BLACKLIST_PATH!"') do (
    if "%%~A"=="%blacklisted_psn%" (
        if "!@blacklisted_psn_list:[%%~A]=!"=="!@blacklisted_psn_list!" (
            set /a blacklisted_psn_list_counter+=1
            set "@blacklisted_psn_list=!@blacklisted_psn_list!, [%%~A]"
            set "@ps3_blacklisted_psn_list=!@ps3_blacklisted_psn_list!,+%%5B%%~A%%5D"
        )
    )
)
for /f "tokens=1,2delims==" %%A in ('find "=%ip%" "!WINDOWS_BLACKLIST_PATH!"') do (
    if "%%~B"=="%ip%" (
        if "!@blacklisted_psn_list:[%%~A]=!"=="!@blacklisted_psn_list!" (
            set /a blacklisted_psn_list_counter+=1
            set "@blacklisted_psn_list=!@blacklisted_psn_list!, [%%~A]"
            set "@ps3_blacklisted_psn_list=!@ps3_blacklisted_psn_list!,+%%5B%%~A%%5D"
        )
    )
)
if !blacklisted_psn_list_counter! gtr 1 (
    set "@ps3_psn_plurial_asterisk=%%2A"
    set "@psn_plurial_asterisk=*"
) else (
    set @ps3_psn_plurial_asterisk=
    set @psn_plurial_asterisk=
)
echo User!@psn_plurial_asterisk!:!@blacklisted_psn_list! ^| ReverseIP:%reverse_ip% ^| IP:%ip% ^| Port:%port% ^| Time:!datetime! ^| Country:!blacklisted_iplookup_countrycode_%ip%! ^| Detection Type: !blacklisted_detection_type!
:LOOP_WINDOWS_RESULTS_LOGGING_PATH
if %WINDOWS_RESULTS_LOGGING%==true (
    >>"%WINDOWS_RESULTS_LOGGING_PATH%" (
        echo User!@psn_plurial_asterisk!:!@blacklisted_psn_list! ^| ReverseIP:%reverse_ip% ^| IP:%ip% ^| Port:%port% ^| Time:!datetime! ^| Country:!blacklisted_iplookup_countrycode_%ip%! ^| Detection Type: !blacklisted_detection_type!
    ) || (
        call :CREATE_WINDOWS_RESULTS_LOGGING_FILE
        goto :LOOP_WINDOWS_RESULTS_LOGGING_PATH
    )
)
if %WINDOWS_NOTIFICATIONS%==true (
    if defined skip_windows_notifications (
        set skip_windows_notifications=
    )
    if %WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL%==true (
        if defined windows_notifications_packets_interval_%ip%_t1 (
            call :TIMER_T2 windows_notifications_packets_interval_%ip%
        ) else (
            set windows_notifications_packets_interval_%ip%_seconds=%WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER%
        )
        if !windows_notifications_packets_interval_%ip%_seconds! lss %WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER% (
            set skip_windows_notifications=1
        )
        call :TIMER_T1 windows_notifications_packets_interval_%ip%
    )
    if not defined skip_windows_notifications (
        if defined windows_notifications_%ip%_t1 (
            call :TIMER_T2 windows_notifications_%ip%
        ) else (
            set windows_notifications_%ip%_seconds=%WINDOWS_NOTIFICATIONS_TIMER%
        )
        if !windows_notifications_%ip%_seconds! geq %WINDOWS_NOTIFICATIONS_TIMER% (
            set windows_notifications_%ip%_t1=
            %@MSGBOX% start /b cscript //nologo "lib\msgbox.vbs" "##### Blacklisted user detected at !hourtime:~0,5! #####!\N!!\N!User!@psn_plurial_asterisk!: !@blacklisted_psn_list!!\N!IP: %ip%!\N!Port: %port%!\N!Country Code: !blacklisted_iplookup_countrycode_%ip%!!\N!Detection Type: !blacklisted_detection_type!!\N!!\N!############# IP Lookup ##############!\N!!\N!Reverse IP: !blacklisted_iplookup_reverse_%ip%!!\N!Continent: !blacklisted_iplookup_continent_%ip%!!\N!Country: !blacklisted_iplookup_country_%ip%!!\N!City: !blacklisted_iplookup_city_%ip%!!\N!Organization: !blacklisted_iplookup_org_%ip%!!\N!ISP: !blacklisted_iplookup_isp_%ip%!!\N!AS: !blacklisted_iplookup_as_%ip%!!\N!AS Name: !blacklisted_iplookup_asname_%ip%!!\N!Proxy: !blacklisted_iplookup_proxy_2_%ip%!!\N!Type: !blacklisted_iplookup_type_%ip%!!\N!Mobile (cellular) connection: !blacklisted_iplookup_mobile_%ip%!!\N!Proxy, VPN or Tor exit address: !blacklisted_iplookup_proxy_%ip%!!\N!Hosting, colocated or data center: !blacklisted_iplookup_hosting_%ip%!" 69680 "!TITLE!"
            if not defined windows_notifications_%ip%_t1 (
                call :TIMER_T1 windows_notifications_%ip%
            )
        )
    )
)
if defined PS3_IP_ADDRESS (
    if not defined skip_ps3_protection (
        set skip_ps3_protection=1
        if not %PS3_PROTECTION%==false (
            if %PS3_PROTECTION%==Reload_Game (
                >nul curl -fks "http://%PS3_IP_ADDRESS%/xmb.ps3$reloadgame" && (
                    if %PS3_NOTIFICATIONS%==true (
                        >nul timeout /t 25 /nobreak
                    )
                )
            ) else if %PS3_PROTECTION%==Exit_Game (
                >nul curl -fks "http://%PS3_IP_ADDRESS%/xmb.ps3$exit" && (
                    if %PS3_NOTIFICATIONS%==true (
                        >nul timeout /t 15 /nobreak
                    )
                )
            ) else if %PS3_PROTECTION%==Restart_PS3 (
                >nul curl -fks "http://%PS3_IP_ADDRESS%/restart.ps3" && (
                    exit /b
                )
            ) else if %PS3_PROTECTION%==Shutdown_PS3 (
                >nul curl -fks "http://%PS3_IP_ADDRESS%/shutdown.ps3" && (
                    exit /b
                )
            )
        )
    )
    if %PS3_NOTIFICATIONS%==true (
        if %PS3_NOTIFICATIONS_ABOVE%==true (
            if defined skip_ps3_notifications_above (
                set skip_ps3_notifications_above=
            )
            if %PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL%==true (
                if defined ps3_notifications_above_packets_interval_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_above_packets_interval_%ip%
                ) else (
                    set ps3_notifications_above_packets_interval_%ip%_seconds=%PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER%
                )
                if !ps3_notifications_above_packets_interval_%ip%_seconds! lss %PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER% (
                    set skip_ps3_notifications_above=1
                )
                call :TIMER_T1 ps3_notifications_above_packets_interval_%ip%
            )
            if not defined skip_ps3_notifications_above (
                if defined ps3_notifications_above_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_above_%ip%
                ) else (
                    set ps3_notifications_above_%ip%_seconds=%PS3_NOTIFICATIONS_ABOVE_TIMER%
                )
                if !ps3_notifications_above_%ip%_seconds! geq %PS3_NOTIFICATIONS_ABOVE_TIMER% (
                    set ps3_notifications_above_%ip%_t1=
                    for /l %%A in (1,1,3) do (
                        if not %PS3_NOTIFICATIONS_ABOVE_SOUND%==false (
                            set first_3=1
                            if defined first_3 (
                                set "@PS3_NOTIFICATIONS_ABOVE_SOUND=&snd=%PS3_NOTIFICATIONS_ABOVE_SOUND%"
                                set first_3=
                            ) else (
                                set @PS3_NOTIFICATIONS_ABOVE_SOUND=
                            )
                        )
                        >nul curl -fkLs "http://%PS3_IP_ADDRESS%/notify.ps3mapi?msg=Blacklisted+user!@ps3_psn_plurial_asterisk!+%%5B%blacklisted_psn%%%5D+detected%%3A%%0D%%0AIP%%3A+%ip%%%0D%%0APort%%3A+%port%%%0D%%0ACountry%%3A+!blacklisted_iplookup_countrycode_%ip%!&icon=!PS3_NOTIFICATIONS_ABOVE_ICON!!@PS3_NOTIFICATIONS_ABOVE_SOUND!"
                    )
                    if not defined ps3_notifications_above_%ip%_t1 (
                        call :TIMER_T1 ps3_notifications_above_%ip%
                    )
                )
            )
        )
        if %PS3_NOTIFICATIONS_BOTTOM%==true (
            if defined skip_ps3_notifications_bottom (
                set skip_ps3_notifications_bottom=
            )
            if %PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL%==true (
                if defined ps3_notifications_bottom_packets_interval_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_bottom_packets_interval_%ip%
                ) else (
                    set ps3_notifications_bottom_packets_interval_%ip%_seconds=%PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER%
                )
                if !ps3_notifications_bottom_packets_interval_%ip%_seconds! lss %PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER% (
                    set skip_ps3_notifications_bottom=1
                )
                call :TIMER_T1 ps3_notifications_bottom_packets_interval_%ip%
            )
            if not defined skip_ps3_notifications_bottom (
                if defined ps3_notifications_bottom_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_bottom_%ip%
                ) else (
                    set ps3_notifications_bottom_%ip%_seconds=%PS3_NOTIFICATIONS_BOTTOM_TIMER%
                )
                if !ps3_notifications_bottom_%ip%_seconds! geq %PS3_NOTIFICATIONS_BOTTOM_TIMER% (
                    set ps3_notifications_bottom_%ip%_t1=
                    >nul curl -fkLs "http://%PS3_IP_ADDRESS%/popup.ps3*Blacklisted+user!@ps3_psn_plurial_asterisk!%%3A+!@ps3_blacklisted_psn_list!+connected..."
                    if not %PS3_NOTIFICATIONS_BOTTOM_SOUND%==false (
                        >nul curl -fkLs "http://%PS3_IP_ADDRESS%/beep.ps3?%PS3_NOTIFICATIONS_BOTTOM_SOUND%"
                    )
                    if not defined ps3_notifications_bottom_%ip%_t1 (
                        call :TIMER_T1 ps3_notifications_bottom_%ip%
                    )
                )
            )
        )
    )
)
exit /b

:TIMER_T1
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "%1_t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"
exit /b

:TIMER_T2
for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "%1_t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100, %1_tDiff=%1_t2-%1_t1, %1_tDiff+=((~(%1_tDiff&(1<<31))>>31)+1)*8640000, %1_seconds=%1_tDiff/100"
exit /b

:BLACKLIST_WRITE
>nul findstr /bc:"!%1!=%ip%" "!WINDOWS_BLACKLIST_PATH!" || (
    >>"!WINDOWS_BLACKLIST_PATH!" (
        echo !%1!=%ip%
    ) || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=WINDOWS_BLACKLIST_PATH%
)
exit /b

:DETECTION_TYPE_FORM_PRECISION
for /f "tokens=1-3delims=." %%A in ("!%1!") do (
    if %DETECTION_TYPE_DYNAMIC_IP_PRECISION%==1 (
        set "%2=%%~A"
    ) else if %DETECTION_TYPE_DYNAMIC_IP_PRECISION%==2 (
        set "%2=%%~A.%%~B"
    ) else if %DETECTION_TYPE_DYNAMIC_IP_PRECISION%==3 (
        set "%2=%%~A.%%~B.%%~C"
    )
)
exit /b

:ASCII_TO_HEXADECIMAL
if not "%blacklisted_psn:~16%"=="" (
    exit /b 1
)
if "%blacklisted_psn:~2%"=="" (
    exit /b 1
)
for /f "delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" %%A in ("%blacklisted_psn%") do (
    exit /b 1
)
if defined blacklisted_psn_hexadecimal_%blacklisted_psn% (
    exit /b 0
) else (
    if exist "lib\tmp\blacklisted_psn_hexadecimal.tmp" (
        for /f "tokens=1,2delims==" %%A in ('find "%blacklisted_psn%=" "lib\tmp\blacklisted_psn_hexadecimal.tmp"') do (
            if "%%~A"=="%blacklisted_psn%" (
                if not "%%~B"=="" (
                    set "blacklisted_psn_hexadecimal_%blacklisted_psn%=%%~B"
                    call :CHECK_PSN_HEXADECIMAL && (
                        set blacklisted_psn_ascii_!blacklisted_psn_hexadecimal_%blacklisted_psn%!=%blacklisted_psn%
                        exit /b 0
                    )
                )
            )
        )
    )
)
set "blacklisted_psn_hexadecimal_%blacklisted_psn%="
set "blacklisted_psn_ascii=%blacklisted_psn%"
:_ASCII_TO_HEXADECIMAL
if defined blacklisted_psn_ascii (
    for %%A in (
        "a`61"
        "b`62"
        "c`63"
        "d`64"
        "e`65"
        "f`66"
        "g`67"
        "h`68"
        "i`69"
        "j`6A"
        "k`6B"
        "l`6C"
        "m`6D"
        "n`6E"
        "o`6F"
        "p`70"
        "q`71"
        "r`72"
        "s`73"
        "t`74"
        "u`75"
        "v`76"
        "w`77"
        "x`78"
        "y`79"
        "z`7A"
        "A`41"
        "B`42"
        "C`43"
        "D`44"
        "E`45"
        "F`46"
        "G`47"
        "H`48"
        "I`49"
        "J`4A"
        "K`4B"
        "L`4C"
        "M`4D"
        "N`4E"
        "O`4F"
        "P`50"
        "Q`51"
        "R`52"
        "S`53"
        "T`54"
        "U`55"
        "V`56"
        "W`57"
        "X`58"
        "Y`59"
        "Z`5A"
        "0`30"
        "1`31"
        "2`32"
        "3`33"
        "4`34"
        "5`35"
        "6`36"
        "7`37"
        "8`38"
        "9`39"
        "-`2D"
        "_`5F"
    ) do (
        for /f "tokens=1,2delims=`" %%B in ("%%~A") do (
            if "!blacklisted_psn_ascii:~0,1!"=="%%~B" (
                set "blacklisted_psn_hexadecimal_%blacklisted_psn%=!blacklisted_psn_hexadecimal_%blacklisted_psn%!%%~C"
            )
        )
    )
    set "blacklisted_psn_ascii=!blacklisted_psn_ascii:~1!"
    goto :_ASCII_TO_HEXADECIMAL
)
set blacklisted_psn_ascii_!blacklisted_psn_hexadecimal_%blacklisted_psn%!=%blacklisted_psn%
for %%A in ("lib\tmp\blacklisted_psn_hexadecimal.tmp") do (
    if not exist "%%~dpA" (
        md "%%~dpA" || (
            set "?=%%~dpA"
            %@ADMINISTRATOR_MANIFEST_REQUIRED%
        )
    )
    >>"%%~A" (
        echo %blacklisted_psn%=!blacklisted_psn_hexadecimal_%blacklisted_psn%!
    ) || (
        set "?=%%~A"
        %@ADMINISTRATOR_MANIFEST_REQUIRED%
    )
)
exit /b 0

:CHECK_PSN_HEXADECIMAL
if not "!blacklisted_psn_hexadecimal_%blacklisted_psn%:~32!"=="" (
    exit /b 1
)
if "!blacklisted_psn_hexadecimal_%blacklisted_psn%:~5!"=="" (
    exit /b 1
)
for /f "delims=abcdefABCDEF0123456789" %%A in ("!blacklisted_psn_hexadecimal_%blacklisted_psn%!") do (
    exit /b 1
)
exit /b 0

:HEXADECIMAL_TO_ASCII
for /f "delims=abcdefABCDEF0123456789" %%A in ("%psn_hexadecimal%") do (
    exit /b 1
)
set "_psn_hexadecimal=%psn_hexadecimal%"
:_HEXADECIMAL_TO_ASCII
if defined _psn_hexadecimal (
    for %%A in (
        "61`a"
        "62`b"
        "63`c"
        "64`d"
        "65`e"
        "66`f"
        "67`g"
        "68`h"
        "69`i"
        "6A`j"
        "6B`k"
        "6C`l"
        "6D`m"
        "6E`n"
        "6F`o"
        "70`p"
        "71`q"
        "72`r"
        "73`s"
        "74`t"
        "75`u"
        "76`v"
        "77`w"
        "78`x"
        "79`y"
        "7A`z"
        "41`A"
        "42`B"
        "43`C"
        "44`D"
        "45`E"
        "46`F"
        "47`G"
        "48`H"
        "49`I"
        "4A`J"
        "4B`K"
        "4C`L"
        "4D`M"
        "4E`N"
        "4F`O"
        "50`P"
        "51`Q"
        "52`R"
        "53`S"
        "54`T"
        "55`U"
        "56`V"
        "57`W"
        "58`X"
        "59`Y"
        "5A`Z"
        "30`0"
        "31`1"
        "32`2"
        "33`3"
        "34`4"
        "35`5"
        "36`6"
        "37`7"
        "38`8"
        "39`9"
        "2D`-"
        "5F`_"
    ) do (
        for /f "tokens=1,2delims=`" %%B in ("%%~A") do (
            if /i "!_psn_hexadecimal:~0,2!"=="%%~B" (
                set "psn_ascii=!psn_ascii!%%~C"
            )
        )
    )
    set "_psn_hexadecimal=!_psn_hexadecimal:~2!"
    goto :_HEXADECIMAL_TO_ASCII
)
exit /b 0

:IPLOOKUP
set "%1_iplookup_%2=1"
if exist "lib\tmp\%1_iplookup_%2.tmp" (
    for /f "usebackqtokens=1,2delims==" %%A in ("lib\tmp\%1_iplookup_%2.tmp") do (
        set first_5=1
        if defined first_5 (
            if /i not "!@LOOKUP_IPLOOKUP_FIELDS:`%%~A`=!"=="!@LOOKUP_IPLOOKUP_FIELDS!" (
                set first_5=
                set "%1_iplookup_%%~A_%2=%%~B"
            )
        )
    )
    if defined first_5 (
        set first_5=
    )
) else (
    for /f "tokens=1,2delims=</" %%A in ('curl -fkLs "http://ip-api.com/xml/%2?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query"') do (
        set "x=%%~A%%~B"
        set "x=!x:~2!"
        for /f "tokens=1,2delims=>" %%C in ("!x!") do (
            if not "%%~C"=="" (
                if not "%%~D"=="" (
                    if /i not "!@LOOKUP_IPLOOKUP_FIELDS:`%%~C`=!"=="!@LOOKUP_IPLOOKUP_FIELDS!" (
                        set "%1_iplookup_%%~C_%2=%%~D"
                    )
                )
            )
        )
    )
    if "%~1"=="blacklisted" (
        for /f "tokens=1,2delims=:" %%A in ('curl -fkLs "https://proxycheck.io/v2/%2?vpn=1&port=1"') do (
            set "x=%%~A:%%~B"
            set "x=!x:"=!"
            if "!x:~-1!"=="," (
                set "x=!x:~,-1!"
            )
            set "x=!x:proxy=proxy_2!"
            set "x=!x:no=false!"
            set "x=!x:yes=true!"
            for /f "tokens=1,2delims=: " %%C in ("!x!") do (
                if not "%%~C"=="" (
                    if not "%%~D"=="" (
                        if /i not "!@LOOKUP_IPLOOKUP_FIELDS:`%%~C`=!"=="!@LOOKUP_IPLOOKUP_FIELDS!" (
                            set "%1_iplookup_%%~C_%2=%%~D"
                        )
                    )
                )
            )
        )
    )
    for %%A in ("lib\tmp\%1_iplookup.tmp") do (
        if not exist "%%~dpA" (
            md "%%~dpA" || (
                set "?=%%~dpA"
                %@ADMINISTRATOR_MANIFEST_REQUIRED%
            )
        )
    )
    for %%A in (%@LOOKUP_IPLOOKUP_FIELDS:`=,%) do (
        if not defined %1_iplookup_%%~A_%2 (
            set "%1_iplookup_%%~A_%2=N/A"
        )
        >>"lib\tmp\%1_iplookup_%2.tmp" (
            echo %%~A=!%1_iplookup_%%~A_%2!
        ) || (
            set "?=%%~A"
            %@ADMINISTRATOR_MANIFEST_REQUIRED%
        )
    )
)
call :CHECK_COUNTRYCODE %1 %2 || (
    for /f "tokens=1,2delims=:, " %%A in ('curl -fkLs "https://ipinfo.io/%2/json"') do (
        if /i "%%~A"=="country" (
            set "%1_iplookup_countrycode_%2=%%~B"
            call :CHECK_COUNTRYCODE %1 %2 || (
                set "%1_iplookup_countrycode_%2="
            )
        )
    )
)
exit /b

:CHECK_COUNTRYCODE
if defined %1_iplookup_countrycode_%2 (
    if not "!%1_iplookup_countrycode_%2:~1!"=="" (
        if "!%1_iplookup_countrycode_%2:~2!"=="" (
            exit /b 0
        )
    )
)
exit /b 1

:GET_WINDOWS_TSHARK_PATH
for %%A in (
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Wireshark.exe"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\Wireshark.exe"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Wireshark"
    "HKLM\SOFTWARE\Classes\wireshark-capture-file\DefaultIcon"
    "HKLM\SOFTWARE\Classes\wireshark-capture-file\Shell\open\command"
    "HKCR\wireshark-capture-file\Shell\open\command"
    "HKCR\wireshark-capture-file\DefaultIcon"
) do (
    for /f "delims=,%%" %%B in ('2^>nul reg query "%%~A" ^| find /i "REG_SZ" ^| find /i "Wireshark.exe"') do (
        set "WINDOWS_TSHARK_PATH=%%~B"
        set "WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH:*REG_SZ=!"
        set "WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH:\Wireshark.exe=\tshark.exe!"
        call :CHECK_PATH WINDOWS_TSHARK_PATH && (
            exit /b 0
        )
    )
)
exit /b 1

:CREATE_WINDOWS_TSHARK_PATH
call :CHECK_PATH WINDOWS_TSHARK_PATH && (
    >nul 2>&1 "!WINDOWS_TSHARK_PATH!" -v && (
        exit /b
    )
)
call :GET_WINDOWS_TSHARK_PATH && (
    set generate_new_settings_file=1
    exit /b
)
%@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find your 'WINDOWS_TSHARK_PATH' setting on your system.!\N!!\N!Redirecting you to Wireshark download page.!\N!!\N!You can also define your own PATH in the 'Settings.ini' file." 69648 "!TITLE!"
start "" "https://www.wireshark.org/#download"
if exist "Settings.ini" (
    start "" "Settings.ini"
)
exit

:CREATE_WINDOWS_BLACKLIST_FILE
call :CHECK_PATH WINDOWS_BLACKLIST_PATH || (
    for %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
        if not exist "%%~dpA" (
            md "%%~dpA" || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=WINDOWS_BLACKLIST_PATH%
        )
        >"%%~A" (
            echo ;;-----------------------------------------------------------------------
            echo ;;Lines starting with ";;" symbols are commented lines.
            echo ;;
            echo ;;This is the blacklist file for 'PS3 Blacklist Sniffer' configuration.
            echo ;;
            echo ;;Please leave their exact ^<PSN USERNAME^>.
            echo ;;This makes it possible to perform the username search
            echo ;;if they changed their ^<IP ADDRESS^>.
            echo ;;
            echo ;;Your blacklist MUST be formatted in the following way in order to work:
            echo ;;^<PSN USERNAME^>=^<IP ADDRESS^>
            echo ;;-----------------------------------------------------------------------
        ) || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=WINDOWS_BLACKLIST_PATH%
    )
)
exit /b

:CREATE_WINDOWS_RESULTS_LOGGING_FILE
call :CHECK_PATH WINDOWS_RESULTS_LOGGING_PATH || (
    for %%A in ("!WINDOWS_RESULTS_LOGGING_PATH!") do (
        if not exist "%%~dpA" (
            md "%%~dpA" || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=WINDOWS_RESULTS_LOGGING_PATH%
        )
        >"%%~A" (
            set x=
        ) || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=WINDOWS_RESULTS_LOGGING_PATH%
    )
)
exit /b

:CREATE_SETTINGS_FILE
>"Settings.ini" (
    echo ;;-----------------------------------------------------------------------------
    echo ;;Lines starting with ";;" symbols are commented lines.
    echo ;;
    echo ;;This is the settings file for 'PS3 Blacklist Sniffer' configuration.
    echo ;;
    echo ;;If you do not know what to choose, the program automatically
    echo ;;analyzes it and will regenerate this file if it contains errors.
    echo ;;
    echo ;;^<PATH^>
    echo ;;The Windows path where your file is located.
    echo ;;
    echo ;;^<WINDOWS_TSHARK_STDERR^>
    echo ;;The 'tshark.exe' error text output from the console.
    echo ;;
    echo ;;^<NOTIFICATIONS^>
    echo ;;Get notified when a blacklisted user is found.
    echo ;;
    echo ;;^<WINDOWS_RESULTS_LOGGING^>
    echo ;;Logs the results of the command prompt console on your computer disk.
    echo ;;
    echo ;;^<IP_ADDRESS^>
    echo ;;Your PS3 console IP address. You can obtain it from your PS3 console:
    echo ;;Settings^>Network Settings^>Settings and Connection Status List^>IP Address
    echo ;;Valid example value: 'x.x.x.x'
    echo ;;
    echo ;;^<MAC_ADDRESS^>
    echo ;;Your PS3 console MAC address. You can obtain it from your PS3 console:
    echo ;;Settings^>Network Settings^>Settings and Connection Status List^>MAC Address
    echo ;;Valid example value:'xx:xx:xx:xx:xx:xx'
    echo ;;
    echo ;;^<PROTECTION^>
    echo ;;Action to perform when a blacklisted user is found.
    echo ;;Set it to 'false' to disable it or pick one from:
    echo ;;'Reload_Game'
    echo ;;'Exit_Game'
    echo ;;'Restart_PS3'
    echo ;;'Shutdown_PS3'
    echo ;;
    echo ;;^<PACKETS_INTERVAL^>
    echo ;;Time interval between which this will not display a notification
    echo ;;if the packets are still received from the blacklisted user.
    echo ;;
    echo ;;^<TIMER^>
    echo ;;Time interval between which this will display a notification.
    echo ;;Your PS3 console may crash if you send it too many notifications.
    echo ;;If you are having this problem, I recommend that you increase
    echo ;;the number of the ^<TIMER^> causing spamming.
    echo ;;
    echo ;;^<ICON^>
    echo ;;The icon to display for your PS3 console notifications.
    echo ;;However, the icons only works on the XMB home screen.
    echo ;;
    echo ;;^<SOUND^>
    echo ;;The notification sound for your PS3 console when a blacklisted user is found.
    echo ;;Valid values are '0-9' and 'false' to disable.
    echo ;;
    echo ;;^<DETECTION_TYPE^>
    echo ;;The detection types used to lookup and detect the blacklisted users.
    echo ;;Those can be: 'PSN_USERNAME', 'STATIC_IP' and 'DYNAMIC_IP'.
    echo ;;
    echo ;;^<DETECTION_TYPE_DYNAMIC_IP_PRECISION^>
    echo ;;The chosen number of octet^(s^) that will be used for the Dynamic IP lookup.
    echo ;;Valid values are '1-3'.
    echo ;;-----------------------------------------------------------------------------
    echo WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH!
    echo WINDOWS_TSHARK_STDERR=!WINDOWS_TSHARK_STDERR!
    echo WINDOWS_BLACKLIST_PATH=!WINDOWS_BLACKLIST_PATH!
    echo WINDOWS_RESULTS_LOGGING=!WINDOWS_RESULTS_LOGGING!
    echo WINDOWS_RESULTS_LOGGING_PATH=!WINDOWS_RESULTS_LOGGING_PATH!
    echo WINDOWS_NOTIFICATIONS=!WINDOWS_NOTIFICATIONS!
    echo WINDOWS_NOTIFICATIONS_TIMER=!WINDOWS_NOTIFICATIONS_TIMER!
    echo WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL=!WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL!
    echo WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER=!WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER!
    echo PS3_IP_AND_MAC_ADDRESS_AUTOMATIC=!PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!
    echo PS3_IP_ADDRESS=!PS3_IP_ADDRESS!
    echo PS3_MAC_ADDRESS=!PS3_MAC_ADDRESS!
    echo PS3_PROTECTION=!PS3_PROTECTION!
    echo PS3_NOTIFICATIONS=!PS3_NOTIFICATIONS!
    echo PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON!
    echo PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!
    echo PS3_NOTIFICATIONS_ABOVE=!PS3_NOTIFICATIONS_ABOVE!
    echo PS3_NOTIFICATIONS_ABOVE_ICON=!PS3_NOTIFICATIONS_ABOVE_ICON!
    echo PS3_NOTIFICATIONS_ABOVE_SOUND=!PS3_NOTIFICATIONS_ABOVE_SOUND!
    echo PS3_NOTIFICATIONS_ABOVE_TIMER=!PS3_NOTIFICATIONS_ABOVE_TIMER!
    echo PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL=!PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL!
    echo PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER=!PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER!
    echo PS3_NOTIFICATIONS_BOTTOM=!PS3_NOTIFICATIONS_BOTTOM!
    echo PS3_NOTIFICATIONS_BOTTOM_SOUND=!PS3_NOTIFICATIONS_BOTTOM_SOUND!
    echo PS3_NOTIFICATIONS_BOTTOM_TIMER=!PS3_NOTIFICATIONS_BOTTOM_TIMER!
    echo PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL=!PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL!
    echo PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER=!PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER!
    echo DETECTION_TYPE_DYNAMIC_IP_PRECISION=!DETECTION_TYPE_DYNAMIC_IP_PRECISION!
) || (
    set "?=Settings.ini"
    %@ADMINISTRATOR_MANIFEST_REQUIRED%
)
exit /b

:PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
if defined PS3_MAC_ADDRESS (
    if not defined PS3_IP_ADDRESS (
        call :PS3_IP_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION PS3_MAC_ADDRESS PS3_IP_ADDRESS && (
            call :CREATE_SETTINGS_FILE
            exit /b
        )
    )
) else if defined PS3_IP_ADDRESS (
    if not defined PS3_MAC_ADDRESS (
        call :PS3_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION PS3_IP_ADDRESS PS3_MAC_ADDRESS && (
            call :CREATE_SETTINGS_FILE
            exit /b
        )
    )
)
if defined PS3_IP_ADDRESS (
    if defined PS3_MAC_ADDRESS (
        for /f "tokens=1,2" %%A in ('ARP -a') do (
            if "%%~A"=="!PS3_IP_ADDRESS!" (
                if not "%%~B"=="!PS3_MAC_ADDRESS::=-!" (
                    set PS3_MAC_ADDRESS=
                    call :CREATE_SETTINGS_FILE
                    exit /b
                )
            )
        )
    )
)
exit /b

:PS3_IP_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
set "%1=!%1::=-!"
for /f "tokens=1,2" %%A in ('ARP -a') do (
    if "!%1!"=="%%~B" (
        set "%2=%%~A"
        set "%1=!%1:-=:!"
        exit /b 0
    )
)
set "%1=!%1:-=:!"
exit /b 1

:PS3_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
for /f "tokens=1,2" %%A in ('ARP -a') do (
    if "!%1!"=="%%~A" (
        set "%2=%%~B"
        set "%2=!%2:-=:!"
        exit /b 0
    )
)
exit /b 1

:CHECK_WEBMAN_MOD_CONNECTION
if !PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!==false (
        set @PS3_NOTIFICATIONS_ABOVE_SOUND=
) else (
    set "@PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=&snd=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!"
)
for /f %%A in ('curl -fksw "%%{response_code}" "http://!%1!/notify.ps3mapi?msg=!TITLE: =+!+successfully+connected+to+your+PS3+console%%2E&icon=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON!!@PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!" -o NUL') do (
    if "%%~A"=="200" (
        set ps3_connected_notification=1
        set "PS3_IP_ADDRESS=!%1!"
        set "PS3_MAC_ADDRESS=!%2!"
        if !PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!==true (
            call :PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
        )
        exit /b 0
    ) else (
        exit /b 1
    )
)
exit /b 1

:CHECK_NUMBER
if not defined %1 (
    exit /b 1
)
for /f "delims=0123456789" %%A in ("!%1!") do (
    exit /b 1
)
:CHECK_NUMBER_STRIP_STARTING_0
if "!%1:~0,1!"=="0" (
    if not "!%1:~1,1!"=="" (
        if not "!%1:~1,1!"=="0" (
            set first_4=1
            for /l %%A in (1,1,9) do (
                if defined first_4 (
                    if not "!%1:~1,1!"=="%%~A" (
                        set generate_new_settings_file=1
                        set "%1=!%1:~1!"
                        set first_4=
                        goto :CHECK_NUMBER_STRIP_STARTING_0
                    )
                )
            )
        ) else (
            if "!%1:~1,1!"=="0" (
                set generate_new_settings_file=1
                set "%1=!%1:~1!"
                goto :CHECK_NUMBER_STRIP_STARTING_0
            )
        )
    )
)
exit /b 0

:MSGBOX_GENERATION
for %%A in ("lib\msgbox.vbs") do (
    if not exist "%%~dpA" (
        md "%%~dpA" || (
            set "?=%%~dpA"
            %@ADMINISTRATOR_MANIFEST_REQUIRED%
        )
    )
    >"%%~A" (
        echo MsgBox WScript.Arguments^(0^),WScript.Arguments^(1^),WScript.Arguments^(2^)
    ) || (
        set "?=%%~A"
        %@ADMINISTRATOR_MANIFEST_REQUIRED%
    )
)
exit /b

:CHECK_PATH
if not defined %1 exit /b 1
set "%1=!%1:"=!"
set "%1=!%1:/=\!"
:CHECK_PATH_STRIP_WHITE_SPACES
if "!%1:~0,1!"==" " (
set "%1=!%1:~1!"
goto :CHECK_PATH_STRIP_WHITE_SPACES
)
:_CHECK_PATH_STRIP_WHITE_SPACES
if "!%1:~-1!"==" " (
set "%1=!%1:~0,-1!"
goto :_CHECK_PATH_STRIP_WHITE_SPACES
)
:CHECK_PATH_STRIP_SLASHES
if "!%1:~-2!"=="\\" (
set "%1=!%1:~0,-1!"
goto :CHECK_PATH_STRIP_SLASHES
)
if exist "!%1!" exit /b 0
exit /b 1

:CHECK_IP
if not defined %1 exit /b 1
if "!%1!"=="!%1:~0,6!" exit /b 1
if not "!%1!"=="!%1:..=!" exit /b 1
for /f "tokens=1-5delims=." %%A in ("!%1!") do (
if not "%%E"=="" exit /b 1
call :CHECK_BETWEEN0AND255 "%%~A" || exit /b 1
call :CHECK_BETWEEN0AND255 "%%~B" || exit /b 1
call :CHECK_BETWEEN0AND255 "%%~C" || exit /b 1
call :CHECK_BETWEEN0AND255 "%%~D" || exit /b 1
)
exit /b 0

:CHECK_BETWEEN0AND255
if "%~1"=="" exit /b 1
for /f "delims=0123456789" %%A in ("%~1") do exit /b 1
if %~1 lss 0 exit /b 1
if %~1 gtr 255 exit /b 1
exit /b 0

:CHECK_MAC
if not defined %1 exit /b 1
if "!%1!"=="!%1:~0,16!" exit /b 1
if not "!%1!"=="!%1:::=!" exit /b 1
for /f "tokens=1-7delims=:" %%A in ("!%1!") do (
if not "%%G"=="" exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~A" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~B" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~C" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~D" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~E" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~F" || exit /b 1
)
exit /b 0

:CHECK_BETWEEN0ANDZ
if "%~1"=="" exit /b 1
set "x=%~1"
if not "!x:~1!"=="" if "!x:~2!"=="" for /f "delims=0123456789abcdefABCDEF" %%A in ("%~1") do exit /b 1
exit /b 0

:UPDATER
for /f %%A in ('curl.exe -fkLs "https://raw.githubusercontent.com/Illegal-Services/PS3-Blacklist-Sniffer/version/version.txt"') do (
    set "last_version=%%~A"
)
if not defined last_version (
    exit /b
)
if "!VERSION:~1,5!" geq "!last_version:~1,5!" (
    exit /b
)
if defined OLD_VERSION (
    if defined OLD_LASTVERSION (
        if "!OLD_VERSION!"=="!VERSION!" (
            if "!OLD_LASTVERSION!"=="!last_version!" (
                exit /b
            )
        )
    )
)
>"lib\msgbox_updater.vbs" (
echo Dim Response
echo Response=MsgBox^(WScript.Arguments^(0^),WScript.Arguments^(1^),WScript.Arguments^(2^)^)
echo If Response=vbYes then
echo wscript.quit 6
echo End If
echo wscript.quit 7
)
cscript //nologo "lib\msgbox_updater.vbs" "New version found. Do you want to update ?!\N!!\N!Current version: !VERSION!!\N!Latest version   : !last_version!" 69668 "!TITLE! Updater"
if not "!errorlevel!"=="6" (
    exit /b
)
curl.exe --create-dirs -f#kLo "[UPDATED]_PS3_Blacklist_Sniffer.bat" "https://raw.githubusercontent.com/Illegal-Services/PS3-Blacklist-Sniffer/main/PS3_Blacklist_Sniffer.bat" || (
    exit /b
)
if not exist "[UPDATED]_PS3_Blacklist_Sniffer.bat" (
    exit /b
)
start "" "[UPDATED]_PS3_Blacklist_Sniffer.bat" && (
    exit
)
exit /b