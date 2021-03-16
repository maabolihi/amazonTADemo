def GIT_REPO = "amazonTADemo"
def FIREFOX_VERSION = "78.5.0esr"
def CHROMEDRIVER_VERSION = "89.0.4389.23"
def GECKODRIVER_VERSION = "0.29.0"


node {
    stage ('Pre-Requisites') {
        step([$class: 'WsCleanup'])
        sh """
        git clone https://github.com/maabolihi/amazonTADemo.git
        # Python virtual environment (venv)
        python3 -m venv \$HOME/TA_env
        source \$HOME/TA_env/bin/activate
        python3 -m pip install --upgrade pip
        python3 -m pip install robotframework
        python3 -m pip install robotframework-seleniumlibrary
        python3 -m pip install robotframework-sshlibrary
        python3 -m pip install robotframework-pdf2textlibrary
        python3 -m pip install robotframework-pabot
        python3 -m pip install pyyaml
        python3 -m pip install requests
        deactivate

        # Download packages
        if [ ! -d \$HOME/opt ]; then
            mkdir \$HOME/opt
        fi
        cd \$HOME/opt

        # Download chromedriver
        if [ ! -f chromedriver ]; then
            wget --quiet https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip
            unzip chromedriver_linux64.zip
            chmod +x chromedriver
        fi

        # Download geckodriver
        if [ ! -f geckodriver ]; then
            wget --quiet https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz
            tar xzf geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz
            chmod +x geckodriver
        fi

        PATH=\$HOME/opt:\$PATH
        export PATH
        which chromedriver
        which geckodriver
        """
        }

    stage ('Test In Firefox') {
        sh """
        # Setup display
        export DISPLAY=":99.0"
        Xvfb :99 -screen 0 1280x1024x8 -ac &
        sleep 1

        # Activate Python venv
        source \$HOME/TA_env/bin/activate
        cd \$WORKSPACE/${GIT_REPO}

        PATH=\$HOME/opt:\$PATH
        PYTHONPATH=${WORKSPACE}/${GIT_REPO}/lib:\$PYTHONPATH

        python3 -u -m pabot \
        --variable browser:Firefox \
        --nostatusrc \
        -d Reports/firefox \
        -o output.xml \
        TestCases

        """
        }

    stage ('Test In Chrome') {
        sh """

        # Activate Python venv
        source \$HOME/TA_env/bin/activate
        cd \$WORKSPACE/${GIT_REPO}

        PATH=\$HOME/opt:\$PATH
        PYTHONPATH=${WORKSPACE}/${GIT_REPO}/lib:\$PYTHONPATH

        python3 -u -m pabot \
        --variable browser:Chrome \
        --nostatusrc \
        -d Reports/chrome \
        -o output.xml \
        TestCases

        """
        }

    stage ('Publish RobotFramework Result') {

        step([
            $class              : 'RobotPublisher',
            outputPath          : "${GIT_REPO}/Reports",
            outputFileName      : "**/output.xml",
            reportFileName      : '**/report.html',
            logFileName         : '**/log.html',
            disableArchiveOutput: false,
            passThreshold       : 100,
            unstableThreshold   : 90,
            otherFiles          : "**/*.png,**/*.jpg",
            ])
        }
    }