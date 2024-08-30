@echo off
setlocal enabledelayedexpansion

rem Display menu and get user choice
:menu
echo Model Selection List:
echo 1: gpt-3.5-turbo (default)
echo 2: gpt-4o
echo 3: deepseek-chat

set /p model_choice=Please select the main model (1/2/3):
if "!model_choice!"=="" set model_choice=1
set /p weak_model_choice=Please select the weak model (1/2/3):
if "!weak_model_choice!"=="" set weak_model_choice=1

rem Set parameter values based on user's choice
rem Main model selection
if "%model_choice%"=="1" (
    set model=gpt-3.5-turbo
) else if "%model_choice%"=="2" (
    set model=gpt-4o
) else if "%model_choice%"=="3" (
    set model=deepseek-chat
) else (
    echo Invalid choice, please try again.
    goto menu
)

rem Weak model selection
if "%weak_model_choice%"=="1" (
    set weak_model=gpt-3.5-turbo
) else if "%weak_model_choice%"=="2" (
    set weak_model=gpt-4o
) else if "%weak_model_choice%"=="3" (
    set weak_model=deepseek-chat
) else (
    echo Invalid choice, please try again.
    goto menu
)

rem Display the selected parameters
echo You have chosen the MAIN model: %model%
echo You have chosen the WEAK model: %weak_model%

rem Insert your Python command here
echo Executing command: python -m aider --dark-mode --model %model% --weak-model %weak_model%
python -m aider --dark-mode --model %model% --weak-model %weak_model%

pause