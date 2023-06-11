@echo off
setlocal enabledelayedexpansion

echo cmd
echo argv:%*

set argCount=0
for %%x in (%*) do (
    set /A argCount+=1
    echo argCount:%argCount% [%%~x]
)

echo argc:%argCount%
