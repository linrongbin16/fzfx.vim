@echo off

set "fzfx_bin=%~dp0"
REM echo cmd: %fzfx_bin%live_grep_provider
sh %fzfx_bin%live_grep_provider %*
