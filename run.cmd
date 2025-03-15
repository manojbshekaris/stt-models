@echo off
setlocal enabledelayedexpansion

REM Define JSON file path
set "JSON_FILE=%~dp0models.json"

REM Check if models.json exists
if not exist "%JSON_FILE%" (
    echo Error: models.json not found in %~dp0
    echo Please ensure models.json is in the same folder as this script.
    pause
    exit /b 1
)

REM Create a folder for models
mkdir models 2>nul

REM Check if jq is installed
where jq >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: jq is not installed. Please install it from https://stedolan.github.io/jq/download/
    pause
    exit /b 1
)

REM Read JSON file and download models
for /f "delims=" %%i in ('jq -c ".[]" "%JSON_FILE%"') do (
    REM Extract Model name and URL properly
    for /f "tokens=*" %%a in ('echo %%i ^| jq -r ".Model"') do set "modelName=%%a"
    for /f "tokens=*" %%b in ('echo %%i ^| jq -r ".URL"') do set "url=%%b"

    REM Remove potential surrounding quotes
    set "modelName=!modelName:"=!"
    set "url=!url:"=!"

    REM Validate URL before downloading
    if not "!url!" == "null" if not "!url!" == "" (
        echo Downloading model: !modelName!
        curl -L -o "models\!modelName!.zip" "!url!"
    ) else (
        echo Skipping model: !modelName! (No valid URL found)
    )
)

echo Done! Models are downloaded in the "models" folder.
pause
