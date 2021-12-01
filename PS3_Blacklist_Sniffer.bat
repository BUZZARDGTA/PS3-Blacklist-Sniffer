::------------------------------------------------------------------------------
:: NAME
::     PS3_Blacklist_Sniffer.bat - PS3 Blacklist Sniffer
::
:: DESCRIPTION
::     This script is useful:
::     - If you want to detect one of the blacklisted people that are connecting
::     or connected to your session. (Even if they have an other
::     username in the game. (At the condition that they still have
::     the same IP than the 'Blacklist.ini' given IP.)
::     - If one of the blacklisted people are not in your session but that
::     they tries to join it, you will detect them before they will be there.
::
:: REQUIREMENTS
::     Windows 8, 8.1, 10 (x86/x64)
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
::     @sintrode and https://www.dostips.com/forum/viewtopic.php?t=6560
::     ^^ "How to put inner quotes in outer quotes in "for" loop?"
::
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
@echo off
cls
>nul chcp 65001
setlocal DisableDelayedExpansion
pushd "%~dp0"
set "@MSGBOX=(if not exist "lib\msgbox.vbs" (call :MSGBOX_GENERATION)) & "
set "@ADMINISTRATOR_MANIFEST_REQUIRED=(mshta vbscript:Execute^("msgbox ""!TITLE! does not have enough permissions to write '?' to your disk at this location."" ^& Chr(10) ^& Chr(10) ^& ""Run '%~nx0' as administrator and try again."",69648,""!TITLE!"":close"^) & exit)"
set "@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME=(mshta vbscript:Execute^("msgbox ""The custom PATH you entered for '?' in 'Settings.ini' is invalid or !TITLE! does not have enough permissions to write to your disk at this location."" ^& Chr(10) ^& Chr(10) ^& ""Run '%~nx0' as administrator and try again."",69648,""!TITLE!"":close"^) & exit)"
setlocal EnableDelayedExpansion
set TITLE=PS3 Blacklist Sniffer v1.1
title !TITLE!
(set \N=^
%=leave unchanged=%
)
if defined ProgramFiles(x86) (
    set "PATH=!PATH!;lib\Curl\x64"
) else (
    set "PATH=!PATH!;lib\Curl\x32"
)
>nul 2>&1 sc query npcap || (
    >nul 2>&1 sc query npf || (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not detect the 'Npcap' or 'WinpCap' driver installed on your system.!\N!!\N!Redirecting you to Npcap download page." 69648 "!TITLE!"
        start "" "https://nmap.org/npcap/"
        exit
    )
)
for %%A in ("ARP.EXE" "curl.exe") do (
    >nul 2>&1 where "%%~A" || (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find '%%~A' executable in your system PATH.!\N!!\N!Your system does not meet the minimum software requirements to use !TITLE!." 69648 "!TITLE!"
        exit
    )
)
:SETUP
set ps3_connected_notification=false
set generate_new_settings_file=false
for %%A in (
    "@WINDOWS_TSHARK_STDERR"
    "@PS3_IP_ADDRESS"
    "@PS3_MAC_ADDRESS"
    "@PS3_NOTIFICATIONS_ABOVE_SOUND"
    "settings_number"
    "notepad_pid"
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
    "PS3_NOTIFICATIONS"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND"
    "PS3_NOTIFICATIONS_ABOVE"
    "PS3_NOTIFICATIONS_ABOVE_ICON"
    "PS3_NOTIFICATIONS_ABOVE_SOUND"
    "PS3_NOTIFICATIONS_ABOVE_TIMER"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER"
    "PS3_NOTIFICATIONS_BOTTUM"
    "PS3_NOTIFICATIONS_BOTTUM_SOUND"
    "PS3_NOTIFICATIONS_BOTTUM_TIMER"
    "PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL"
    "PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER"
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
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTUM" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTUM_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTUM_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~B=%%~C"
                        )
                    )
                )
                if "%%~B"=="PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~B=!x!"
                    )
                )
            )
        )
    ) else (
        set generate_new_settings_file=true
    )
)
if not "!settings_number!"=="26" (
    set generate_new_settings_file=true
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
    "PS3_NOTIFICATIONS=true"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON=22"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=5"
    "PS3_NOTIFICATIONS_ABOVE=true"
    "PS3_NOTIFICATIONS_ABOVE_ICON=23"
    "PS3_NOTIFICATIONS_ABOVE_SOUND=3"
    "PS3_NOTIFICATIONS_ABOVE_TIMER=0"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL=true"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER=120"
    "PS3_NOTIFICATIONS_BOTTUM=true"
    "PS3_NOTIFICATIONS_BOTTUM_SOUND=8"
    "PS3_NOTIFICATIONS_BOTTUM_TIMER=0"
    "PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL=true"
    "PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER=1"
) do (
    for /f "tokens=1*delims==" %%B in ("%%~A") do (
        if not defined %%~B (
            set "%%~B=%%~C"
            set generate_new_settings_file=true
        )
    )
)
if !generate_new_settings_file!==true (
    echo:
    echo Correct reconstruction of 'settings.ini' ...
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
        goto :SCAN
    )
)
goto :CHOOSE_INTERFACE
:SCAN
title !TITLE!
cls
echo:
if !PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!==true (
    echo Initializing addresses and establishing connection to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    set first_2=1
    set obtain_valid_addresses=1
    call :PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
    if defined PS3_IP_ADDRESS (
        call :CHECK_WEBMAN_MOD_CONNECTION PS3_IP_ADDRESS PS3_MAC_ADDRESS && (
            set first_2=
            set obtain_valid_addresses=
        )
    )
    for /f "tokens=1,2" %%A in ('ARP -a') do (
        set "x1=%%~A"
        set "x2=%%~B"
        set "x2=!x2:-=:!"
        call :CHECK_IP x1 && (
            set local_ip_!x1!=true
            if defined obtain_valid_addresses (
                call :CHECK_MAC x2 && (
                    if defined first_2 (
                        set first_2=
                        echo PS3 console IP and MAC addresses not found.
                        echo Attempting the automatic detection of your PS3 console ...
                        echo:
                    )
                    echo Trying connection on local: "!x1!"
                    call :CHECK_WEBMAN_MOD_CONNECTION x1 x2 && (
                        set obtain_valid_addresses=
                        set "PS3_IP_ADDRESS=!x1!"
                        set "PS3_MAC_ADDRESS=!x2!"
                        call :CREATE_SETTINGS_FILE
                    )
                )
            )
        )
    )
    for %%A in (first_2 obtain_valid_addresses x1 x2) do set %%A=
) else if defined PS3_IP_ADDRESS (
    echo Establishing connection to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    call :CHECK_WEBMAN_MOD_CONNECTION PS3_IP_ADDRESS PS3_MAC_ADDRESS
)
title Sniffin' my babies IPs.   ^|IP:!PS3_IP_ADDRESS!^|   ^|MAC:!PS3_MAC_ADDRESS!^|   ^|Interface:!Interface_%CAPTURE_INTERFACE%!^| - !TITLE!
:LOOP_BLACKLIST_FILE_EMPTY
cls
echo:
if !ps3_connected_notification!==true (
    echo Successfully connected to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
) else (
    echo Error: Unable to connect to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    echo Make sure that webMAN MOD is correctly configured on your PS3 console.
    if not defined PS3_IP_ADDRESS (
        echo PS3 notifications disabled for this session.
    )
)
echo:
echo Computing decimal PSN usernames to hexadecimal in memory ...
echo:
>nul 2>&1 set invalid_psn_ && (
    for /f "delims==" %%A in ('set invalid_psn_') do (
        set "%%~A="
    )
)
if exist "!WINDOWS_BLACKLIST_PATH!" (
    for /f "usebackqdelims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
        if not "%%~A"=="" (
            if not defined hexadecimal_psn_%%~A (
                if not defined invalid_psn_%%~A (
                    set "blacklisted_psn=%%~A"
                    call :ASCII_TO_HEXADECIMAL || (
                        set "invalid_psn_%%~A=true"
                        echo Blacklisted user ["!blacklisted_psn!"] is not a valid PSN username.
                    )
                )
            )
        )
    )
) else (
    call :CREATE_WINDOWS_BLACKLIST_FILE
    goto :LOOP_BLACKLIST_FILE_EMPTY
)
>nul 2>&1 set invalid_psn_ && (
    echo:
    echo Unable to perform the username search for this PSN username^(s^) in your 'Blacklist.ini' file.
    echo Please ensure the username is correct, and check for the following errors:
    echo PSN usernames must consist of 3-16 characters, and only contain: [a-z] [A-Z] [0-9] [-] [_]
    echo:
)
:WAIT_FILE_SAVED_WINDOWS_BLACKLIST_PATH
>nul 2>&1 set hexadecimal_psn_ || (
    if defined notepad_pid (
        tasklist /v /fo csv /fi "pid eq !notepad_pid!" | >nul find /i "notepad.exe" || (
            set notepad_pid=
        )
    )
    if not defined notepad_pid (
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find any valid users in your 'Blacklist.ini' file.!\N!!\N!Add your first entry to start scanning." 69648 "!TITLE!"
        start "" "Blacklist.ini"
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
)
if defined PS3_MAC_ADDRESS (
    set "@PS3_MAC_ADDRESS=ether dst or src !PS3_MAC_ADDRESS! and "
)
echo Started capturing on network interface "!Interface_%CAPTURE_INTERFACE%!" ...
echo:
set "CAPTURE_FILTER=!@PS3_IP_ADDRESS!!@PS3_MAC_ADDRESS!ip and udp and not broadcast and not multicast and not port 443 and not port 80 and not port 53 and not net 4.68.83.171 and not net 10.0.0.0/8 and not net 20.40.183.0/24 and not net 20.188.217.0/24 and not net 20.193.9.0/24 and not net 44.239.105.0/24 and not net 44.240.54.0/24 and not net 52.25.207.0/24 and not net 52.27.10.0/24 and not net 52.32.157.0/24 and not net 52.33.65.0/24 and not net 52.33.207.0/24 and not net 52.34.172.0/24 and not net 52.36.6.0/24 and not net 52.37.233.0/24 and not net 52.37.45.0/24 and not net 52.37.102.0/24 and not net 52.37.139.0/24 and not net 52.37.199.0/24 and not net 52.37.242.0/24 and not net 52.37.243.0/24 and not net 52.39.46.0/24 and not net 52.40.62.0/24 and not net 52.139.168.0/24 and not net 52.139.169.0/24 and not net 54.68.83.0/24 and not net 80.67.169.0/24 and not net 100.64.0.0/10 and not net 172.16.0.0/12 and not net 185.56.65.0/24 and not net 192.81.241.0/24 and not net 192.81.245.0/24"
if defined CAPTURE_FILTER (
    if "!CAPTURE_FILTER:~-5!"==" and " (
        set "CAPTURE_FILTER=!CAPTURE_FILTER:~0,-5!"
    )
)
for /l %%. in () do (
    if exist "!WINDOWS_TSHARK_PATH!" (
        if exist "!WINDOWS_BLACKLIST_PATH!" (
            for /f "tokens=1-8" %%A in ('^"%@WINDOWS_TSHARK_STDERR%"!WINDOWS_TSHARK_PATH!" -q -Q -i !CAPTURE_INTERFACE! -f "!CAPTURE_FILTER!" -Y "frame.len^>^=68 && frame.len^<^=1160"  -Tfields -Eseparator^=/s -e ip.src_host -e ip.src -e udp.srcport -e ip.dst_host -e ip.dst -e udp.dstport -e data -e frame.len -a duration:1^"') do (
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
                                                    call :BLACKLISTED_SEARCH
                                                ) else (
                                                    set "reverse_ip=%%~A"
                                                    set "ip=%%~B"
                                                    set "port=%%~C"
                                                    call :BLACKLISTED_SEARCH
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
        %@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find your 'WINDOWS_TSHARK_PATH' PATH on your system.!\N!!\N!Redirecting you to Wireshark download page.!\N!!\N!You can also define your own PATH in the 'Settings.ini' file." 69648 "!TITLE!"
        exit
    )
)
exit /b

:BLACKLISTED_SEARCH
if "%ip:~0,8%"=="192.168." (
    set "local_ip_%ip%=true"
    exit /b 1
) else if "%ip:~0,3%"=="10." (
    set "local_ip_%ip%=true"
    exit /b 1
) else if "%ip:~0,4%"=="172." (
    for /l %%A in (16,1,31) do (
        if "%ip:~4,3%"=="%%~A." (
            set "local_ip_%ip%=true"
            exit /b 1
        )
    )
)
for /f "usebackqtokens=1*delims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
    if not "%%~A"=="" (
        set "blacklisted_psn=%%~A"
        set "blacklisted_ip=%%~B"
        if defined blacklisted_ip (
            if "%ip%"=="!blacklisted_ip!" (
                call :BLACKLISTED_FOUND
                exit /b 0
            )
        )
        if defined invalid_psn_%%~A (
            exit /b 1
        )
        for %%C in (136 1160) do (
            if "%%~C"=="%frame_len%" (
                if not defined hexadecimal_psn_%%~A (
                    call :ASCII_TO_HEXADECIMAL || (
                        set "invalid_psn_%%~A=true"
                        exit /b 1
                    )
                )
                for %%D in ("!hexadecimal_psn_%%~A!") do (
                    if not "!hexadecimal_packet:%%~D=!"=="%hexadecimal_packet%" (
                        call :BLACKLISTED_FOUND
                        >nul findstr /bc:"%%~A=%ip%" "!WINDOWS_BLACKLIST_PATH!" || (
                            >>"!WINDOWS_BLACKLIST_PATH!" (
                                echo %%~A=%ip%
                            ) || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=WINDOWS_BLACKLIST_PATH%
                        )
                        exit /b 0
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
call :IPLOOKUP
echo Name:%blacklisted_psn% ^| ReverseIP:%reverse_ip% ^| IP:%ip% ^| Port:%port% ^| Time:!datetime! ^| Country:!iplookup_countrycode_%ip%!
:LOOP_WINDOWS_RESULTS_LOGGING_PATH
if %WINDOWS_RESULTS_LOGGING%==true (
    >>"%WINDOWS_RESULTS_LOGGING_PATH%" (
        echo Name:%blacklisted_psn% ^| ReverseIP:%reverse_ip% ^| IP:%ip% ^| Port:%port% ^| Time:!datetime! ^| Country:!iplookup_countrycode_%ip%!
    ) || (
        call :CREATE_WINDOWS_RESULTS_LOGGING_FILE
        goto :LOOP_WINDOWS_RESULTS_LOGGING_PATH
    )
)
if %WINDOWS_NOTIFICATIONS%==true (
    set pause_windows_notifications=false
    if %WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL%==true (
        if defined windows_notifications_packets_interval_%ip%_t1 (
            call :TIMER_T2 windows_notifications_packets_interval_%ip%
        ) else (
            set windows_notifications_packets_interval_%ip%_seconds=%WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER%
        )
        if !windows_notifications_packets_interval_%ip%_seconds! lss %WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER% (
            set pause_windows_notifications=true
        )
        call :TIMER_T1 windows_notifications_packets_interval_%ip%
    )
    if !pause_windows_notifications!==false (
        if defined windows_notifications_%ip%_t1 (
            call :TIMER_T2 windows_notifications_%ip%
        ) else (
            set windows_notifications_%ip%_seconds=%WINDOWS_NOTIFICATIONS_TIMER%
        )
        if !windows_notifications_%ip%_seconds! geq %WINDOWS_NOTIFICATIONS_TIMER% (
            set windows_notifications_%ip%_t1=
            %@MSGBOX% start /b cscript //nologo "lib\msgbox.vbs" "#### Blacklisted user detected at !hourtime:~0,5! ####!\N!!\N!User: %blacklisted_psn%!\N!IP: %ip%!\N!Port: %port%!\N!Country Code: !iplookup_countrycode_%ip%!!\N!!\N!############ IP Lookup #############!\N!!\N!Reverse IP: !iplookup_reverse_%ip%!!\N!Continent: !iplookup_continent_%ip%!!\N!Country: !iplookup_country_%ip%!!\N!City: !iplookup_city_%ip%!!\N!Organization: !iplookup_org_%ip%!!\N!ISP: !iplookup_isp_%ip%!!\N!AS: !iplookup_as_%ip%!!\N!AS Name: !iplookup_asname_%ip%!!\N!Proxy: !iplookup_proxy_2_%ip%!!\N!Type: !iplookup_type_%ip%!!\N!Mobile (cellular) connection: !iplookup_mobile_%ip%!!\N!Proxy, VPN or Tor exit address: !iplookup_proxy_%ip%!!\N!Hosting, colocated or data center: !iplookup_hosting_%ip%!" 69680 "!TITLE!"
            if not defined windows_notifications_%ip%_t1 (
                call :TIMER_T1 windows_notifications_%ip%
            )
        )
    )
)
if defined PS3_IP_ADDRESS (
    if %PS3_NOTIFICATIONS%==true (
        if %PS3_NOTIFICATIONS_ABOVE%==true (
            set pause_ps3_notifications_above=false
            if %PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL%==true (
                if defined ps3_notifications_above_packets_interval_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_above_packets_interval_%ip%
                ) else (
                    set ps3_notifications_above_packets_interval_%ip%_seconds=%PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER%
                )
                if !ps3_notifications_above_packets_interval_%ip%_seconds! lss %PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER% (
                    set pause_ps3_notifications_above=true
                )
                call :TIMER_T1 ps3_notifications_above_packets_interval_%ip%
            )
            if !pause_ps3_notifications_above!==false (
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
                        >nul curl -fkLs "http://%PS3_IP_ADDRESS%/notify.ps3mapi?msg=Blacklisted+user+%%5B%blacklisted_psn%%%5D+detected%%3A%%0D%%0A%%0D%%0AIP%%3A+%ip%%%0D%%0APort%%3A+%port%%%0D%%0ACountry%%3A+!iplookup_countrycode_%ip%!&icon=!PS3_NOTIFICATIONS_ABOVE_ICON!!@PS3_NOTIFICATIONS_ABOVE_SOUND!"
                    )
                    if not defined ps3_notifications_above_%ip%_t1 (
                        call :TIMER_T1 ps3_notifications_above_%ip%
                    )
                )
            )
        )
        if %PS3_NOTIFICATIONS_BOTTUM%==true (
            set pause_ps3_notifications_bottum=false
            if %PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL%==true (
                if defined ps3_notifications_bottum_packets_interval_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_bottum_packets_interval_%ip%
                ) else (
                    set ps3_notifications_bottum_packets_interval_%ip%_seconds=%PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER%
                )
                if !ps3_notifications_bottum_packets_interval_%ip%_seconds! lss %PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER% (
                    set pause_ps3_notifications_bottum=true
                )
                call :TIMER_T1 ps3_notifications_bottum_packets_interval_%ip%
            )
            if !pause_ps3_notifications_bottum!==false (
                if defined ps3_notifications_bottum_%ip%_t1 (
                    call :TIMER_T2 ps3_notifications_bottum_%ip%
                ) else (
                    set ps3_notifications_bottum_%ip%_seconds=%PS3_NOTIFICATIONS_BOTTUM_TIMER%
                )
                if !ps3_notifications_bottum_%ip%_seconds! geq %PS3_NOTIFICATIONS_BOTTUM_TIMER% (
                    set ps3_notifications_bottum_%ip%_t1=
                    >nul curl -fkLs "http://%PS3_IP_ADDRESS%/popup.ps3*Blacklisted+user+%%5B%blacklisted_psn%%%5D+connected..."
                    if not %PS3_NOTIFICATIONS_BOTTUM_SOUND%==false (
                        >nul curl -fkLs "http://%PS3_IP_ADDRESS%/beep.ps3?%PS3_NOTIFICATIONS_BOTTUM_SOUND%"
                    )
                    if not defined ps3_notifications_bottum_%ip%_t1 (
                        call :TIMER_T1 ps3_notifications_bottum_%ip%
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

:ASCII_TO_HEXADECIMAL
if not "%blacklisted_psn:~16%"=="" (
    exit /b 1
)
if "%blacklisted_psn:~2%"=="" (
    exit /b 1
)
for /f "delims=0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_" %%A in ("%blacklisted_psn%") do (
    exit /b 1
)
if not defined hexadecimal_psn_%blacklisted_psn% (
    if exist "lib\tmp\hexadecimal_psn" (
        for /f "usebackqtokens=1,2delims==" %%A in ("lib\tmp\hexadecimal_psn") do (
            set first_6=1
            if defined first_6 (
                if "%%~A"=="%blacklisted_psn%" (
                    set first_6=
                    set "hexadecimal_psn_%blacklisted_psn%=%%~B"
                    call :CHECK_HEXADECIMAL_PSN && (
                        exit /b 0
                    )
                )
            )
        )
    )
)
set "hexadecimal_psn_%blacklisted_psn%="
set "ascii_psn=%blacklisted_psn%"
:_ASCII_TO_HEXADECIMAL
if defined ascii_psn (
    for %%A in (
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
        "-`2D"
        "_`5F"
    ) do (
        for /f "tokens=1,2delims=`" %%B in ("%%~A") do (
            if "!ascii_psn:~0,1!"=="%%~B" (
                set "hexadecimal_psn_%blacklisted_psn%=!hexadecimal_psn_%blacklisted_psn%!%%~C"
            )
        )
    )
    set "ascii_psn=!ascii_psn:~1!"
    goto :_ASCII_TO_HEXADECIMAL
)
for %%A in ("lib\tmp\hexadecimal_psn") do (
    if not exist "%%~dpA" (
        md "%%~dpA" || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=lib\tmp\%
    )
    >>"%%~A" (
        echo %blacklisted_psn%=!hexadecimal_psn_%blacklisted_psn%!
    ) || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=lib\tmp\hexadecimal_psn%
)
exit /b 0

:CHECK_HEXADECIMAL_PSN
if not "!hexadecimal_psn_%blacklisted_psn%:~32!"=="" (
    exit /b 1
)
if "!hexadecimal_psn_%blacklisted_psn%:~5!"=="" (
    exit /b 1
)
for /f "delims=0123456789ABCDEFabcdef" %%A in ("!hexadecimal_psn_%blacklisted_psn%!") do (
    exit /b 1
)
exit /b 0

:IPLOOKUP
for /f "tokens=1,2delims=</" %%A in ('curl -fkLs "http://ip-api.com/xml/%ip%?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query"') do (
    set "x=%%~A%%~B"
    set "x=!x:~2!"
    for /f "tokens=1,2delims=>" %%C in ("!x!") do (
        if not "%%~D"=="" (
            if /i "%%~C"=="status" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="message" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="continent" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="continentcode" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="country" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="countrycode" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="region" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="regionname" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="city" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="district" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="zip" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="lat" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="lon" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="timezone" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="offset" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="currency" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="isp" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="org" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="as" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="asname" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="reverse" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="mobile" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="proxy" (
                set "iplookup_%%~C_%ip%=%%~D"
            ) else if /i "%%~C"=="hosting" (
                set "iplookup_%%~C_%ip%=%%~D"
            )
        )
    )
)
for /f "tokens=1,2delims=:" %%A in ('curl -fkLs "https://proxycheck.io/v2/%ip%?vpn=1&port=1"') do (
    set "x=%%~A:%%~B"
    set "x=!x:"=!"
    if "!x:~-1!"=="," (
        set "x=!x:~,-1!"
    )
    set "x=!x:no=false!"
    set "x=!x:yes=true!"
    for /f "tokens=1,2delims=: " %%C in ("!x!") do (
        if /i "%%~C"=="proxy" (
            set "iplookup_%%~C_2_%ip%=%%~D"
        ) else if /i "%%~C"=="type" (
            set "iplookup_%%~C_%ip%=%%~D"
        )
    )
)
call :CHECK_COUNTRYCODE || (
    for /f "tokens=1,2delims=:, " %%A in ('curl -fkLs "https://ipinfo.io/%ip%/json"') do (
        if /i "%%~A"=="country" (
            set "iplookup_countrycode_%ip%=%%~B"
            call :CHECK_COUNTRYCODE && (
                exit /b
            )
        )
    )
    set "iplookup_countrycode_%ip%=N/A"
)
exit /b

:CHECK_COUNTRYCODE
if defined iplookup_countrycode_%ip% (
    if not "!iplookup_countrycode_%ip%:~1!"=="" (
        if "!iplookup_countrycode_%ip%:~2!"=="" (
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
    set generate_new_settings_file=true
    exit /b
)
%@MSGBOX% cscript //nologo "lib\msgbox.vbs" "!TITLE! could not find your 'WINDOWS_TSHARK_PATH' PATH on your system.!\N!!\N!Redirecting you to Wireshark download page.!\N!!\N!You can also define your own PATH in the 'Settings.ini' file." 69648 "!TITLE!"
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
    echo PS3_NOTIFICATIONS=!PS3_NOTIFICATIONS!
    echo PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON!
    echo PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!
    echo PS3_NOTIFICATIONS_ABOVE=!PS3_NOTIFICATIONS_ABOVE!
    echo PS3_NOTIFICATIONS_ABOVE_ICON=!PS3_NOTIFICATIONS_ABOVE_ICON!
    echo PS3_NOTIFICATIONS_ABOVE_SOUND=!PS3_NOTIFICATIONS_ABOVE_SOUND!
    echo PS3_NOTIFICATIONS_ABOVE_TIMER=!PS3_NOTIFICATIONS_ABOVE_TIMER!
    echo PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL=!PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL!
    echo PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER=!PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER!
    echo PS3_NOTIFICATIONS_BOTTUM=!PS3_NOTIFICATIONS_BOTTUM!
    echo PS3_NOTIFICATIONS_BOTTUM_SOUND=!PS3_NOTIFICATIONS_BOTTUM_SOUND!
    echo PS3_NOTIFICATIONS_BOTTUM_TIMER=!PS3_NOTIFICATIONS_BOTTUM_TIMER!
    echo PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL=!PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL!
    echo PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER=!PS3_NOTIFICATIONS_BOTTUM_PACKETS_INTERVAL_TIMER!
) || %@ADMINISTRATOR_MANIFEST_REQUIRED:?=Settings.ini%
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
        set ps3_connected_notification=true
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
            set first_5=1
            for /l %%A in (1,1,9) do (
                if defined first_5 (
                    if not "!%1:~1,1!"=="%%~A" (
                        set generate_new_settings_file=true
                        set "%1=!%1:~1!"
                        set first_5=
                        goto :CHECK_NUMBER_STRIP_STARTING_0
                    )
                )
            )
        ) else (
            if "!%1:~1,1!"=="0" (
                set generate_new_settings_file=true
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
        md "%%~dpA" || %@ADMINISTRATOR_MANIFEST_REQUIRED_OR_INVALID_FILENAME:?=lib\tmp\%
    )
    >"%%~A" (
        echo MsgBox WScript.Arguments^(0^),WScript.Arguments^(1^),WScript.Arguments^(2^)
    ) || %@ADMINISTRATOR_MANIFEST_REQUIRED:?=lib\msgbox.vbs%
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