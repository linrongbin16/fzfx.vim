@echo off
setlocal EnableDelayedExpansion

echo windows

set "content=%1"
set "flag=--"
set /A hasFlag=0
set /A contentLength=0
set "option="

for /L %%i in (0,1,16384) do (
    if "!content:~%%i,2!"=="!flag!" (
        if !hasFlag! equ 0 (
            set /A queryLength=%%i
            set "query=!content:~0,%%i!"
            set /A hasFlag=1
        )
    )
    if "!content:~%%i,1!"=="" (
        set /A contentLength=%%i
        goto :ContentLoop
    )
)
:ContentLoop

if !hasFlag! equ 1 (
    set /A "option=%contentLength%-%queryLength%-2"
    for /F "tokens=1*" %%a in ("!query!") do (
        set "query=%%a"
        goto :HasFlagTrimLeftQuery
    )
    :HasFlagTrimLeftQuery
    for /L %%j in (0,1,16384) do (
        if "!query%:~-1!"==" " (
            set "query=!query:~0,-1!"
        ) else if "!query%:~-1!"=="!TAB!" (
            set "query=!query:~0,-1!"
        ) else (
            goto :HasFlagTrimRightQuery
        )
    )
    :HasFlagTrimRightQuery
    for /F "tokens=1*" %%b in ("!option!") do (
        set "option=%%b"
        goto :HasFlagTrimLeftOption
    )
    :HasFlagTrimLeftOption
    for /L %%j in (0,1,16384) do (
        if "!option%:~-1!"==" " (
            set "option=!option:~0,-1!"
        ) else if "!option%:~-1!"=="!TAB!" (
            set "option=!option:~0,-1!"
        ) else (
            goto :HasFlagTrimRightOption
        )
    )
    :HasFlagTrimRightOption
    REM echo content:%content%
    rg --column -n --no-heading --color=always -S -g "!*.git/" !option! -- !query!
) else (
    for /F "tokens=1*" %%a in ("!content!") do (
        set "content=%%a"
        goto :NoFlagTrimLeftContent
    )
    :NoFlagTrimLeftContent
    for /L %%j in (0,1,16384) do (
        if "!content%:~-1!"==" " (
            set "content=!content:~0,-1!"
        ) else if "!content%:~-1!"=="!TAB!" (
            set "content=!content:~0,-1!"
        ) else (
            goto :NoFlagTrimRightContent
        )
    )
    :NoFlagTrimRightContent
    REM echo content:%content%
    rg --column -n --no-heading --color=always -S -g "!*.git/" -- !content!
)
