*** Settings ***
Library     OperatingSystem
Library     setup.py

*** Variables ***
${windows_venv_dir}    C:/TA_env
${windows_opt_dir}    C:/opt

*** Keywords ***
Test Setup
    Log to console  Running Setup....
    ${system}=    Evaluate    platform.system()    platform
    Run keyword if    '${system}' == 'Windows'  Check Prerequisite For Windows
    Log to console  Running Test Case(s)....

Check Python For Windows
    ${python}=  run     python --version
    Should Not Contain  ${python}   Python was not found   msg=Test Cant Continue In Windows: Must install python first

Check VirtualEnv For Windows
    Create directory    ${windows_venv_dir}
    run     python -m venv ${windows_venv_dir}
    run     ${windows_venv_dir}/Scripts/activate.bat

Check RobotFramework Libraries For Windows
    run    python -m pip install robotframework
    run    python -m pip install robotframework-seleniumlibrary
    run    python -m pip install robotframework-OperatingSystem
    run    python -m pip install robotframework-pabot
    run    python -m pip install robotframework-sshlibrary
    run    python -m pip install robotframework-pdf2textlibrary

Check Prerequisite For Windows
    Check Python For Windows
    Check VirtualEnv For Windows
    Check RobotFramework Libraries For Windows