import os


def check_python():
    os.system('cmd /c "cd"')
    python_version = os.system('cmd /c "python --version"')
    if "was not found" in python_version:
        print("Python is not installed in the system")
        python_installed = False
    return python_installed


def install_python():
    os.system('cmd /c "cd"')
    python_version = os.system('cmd /c "python --version"')
    if "was not found" in python_version:
        print("Python is not installed in the system")
        python_installed = False
    return python_installed
