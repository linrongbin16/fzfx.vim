@echo off

set "fzfx_bin=%~dp0"
REM echo cmd: %fzfx_bin%google_provider

WHERE python3
IF %ERRORLEVEL% EQU 0 (
    python3 %fzfx_bin%google_provider %*
) else (
    python %fzfx_bin%google_provider %*
)
