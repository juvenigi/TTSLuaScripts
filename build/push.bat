@echo off
setlocal enabledelayedexpansion

REM Define source and destination directories
set srcDir=..\src
set destDir=..\fromtts

REM Create destination directory if it doesn't exist
if not exist "%destDir%" (
    mkdir "%destDir%"
)

REM Iterate over each .ttslua file in the source directory
for %%f in ("%srcDir%\*.tts.lua") do (
    REM Get the file name without extension
    set fileName=%%~nf

    REM Copy and rename the file to the destination directory with the new extension
    copy "%%f" "%destDir%\!fileName!.ttslua"
)

echo All files copied and renamed successfully. Pushing to Tabletop Simulator
python C:\Users\lenovo\IdeaProjects\TTSLuaScripts\build\generic-ide-tabletopsimulator\command.py --output-dir ./fromtts --command push
