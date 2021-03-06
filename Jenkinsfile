def GIT_REPO = "amazonTADemo"
def GIT_CLONE_URL = "https://github.com/maabolihi/${GIT_REPO}.git"
def FIREFOX_VERSION = "78.5.0esr"
def CHROMEDRIVER_VERSION = "89.0.4389.23"
def GECKODRIVER_VERSION = "0.29.0"

pipeline {
	agent {
		node { label 'test' }
	}
    options {
		timestamps()
		disableConcurrentBuilds()
		timeout(time: 180, unit: 'MINUTES')
	}
	parameters {
		string(name: 'TARGET_URL', defaultValue:'https://amazon.com/', description:'')
		choice(name: 'ZAP_ALERT_LVL', choices: ['High', 'Medium', 'Low'], description: 'See Zap documentation, default High')
	}
	triggers {
        cron('*/30 9-17 * * *')
    }
	stages{
		stage('Initialize'){
			steps{
				script {
					currentBuild.displayName = "Test Automation on ${params.TARGET_URL}"
					currentWorkspace=pwd()
					cleanWs()
				}
				sh """
				git clone ${GIT_CLONE_URL}
                # Python virtual environment (venv)
                python3 -m venv ${env.WORKSPACE}/${GIT_REPO}/TA_env
                source ${env.WORKSPACE}/${GIT_REPO}/TA_env/bin/activate
                python3 -m pip install --upgrade pip
                python3 -m pip install robotframework
                python3 -m pip install robotframework-seleniumlibrary
                python3 -m pip install robotframework-sshlibrary
                python3 -m pip install robotframework-pdf2textlibrary
                python3 -m pip install pyyaml
                python3 -m pip install requests
                deactivate

                # Download packages
                if [ ! -d ${env.WORKSPACE}/${GIT_REPO}/opt ]; then
                    mkdir ${env.WORKSPACE}/${GIT_REPO}/opt
                fi
                cd ${env.WORKSPACE}/${GIT_REPO}/opt

                # Download chromedriver
                if [ ! -f chromedriver ]; then
                    google-chrome --version
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

                PATH=${env.WORKSPACE}/${GIT_REPO}/opt:\$PATH
                export PATH
                which chromedriver
                which geckodriver

                # Download ZAP docker
                docker pull owasp/zap2docker-stable
                """
			}
		}
		stage('Test In Firefox'){
			steps{
				sh """
                # Setup display
                export DISPLAY=":99.0"
                Xvfb :99 -screen 0 1280x1024x8 -ac &
                sleep 1

                # Activate Python venv
                source ${env.WORKSPACE}/${GIT_REPO}/TA_env/bin/activate
                cd ${env.WORKSPACE}/${GIT_REPO}

                PATH=${env.WORKSPACE}/${GIT_REPO}/opt:\$PATH

                python3 -u -m robot \
                --variable browser:Firefox \
                --variable amazonUrl:${TARGET_URL} \
                --nostatusrc \
                -d Reports/firefox \
                -o output.xml \
                TestCases

                """
			}
		}
		stage ('Test In Chrome') {
            steps{
                sh """

                # Activate Python venv
                source ${env.WORKSPACE}/${GIT_REPO}/TA_env/bin/activate
                cd ${env.WORKSPACE}/${GIT_REPO}

                PATH=${env.WORKSPACE}/${GIT_REPO}/opt:\$PATH

                python3 -m robot \
                --variable browser:Chrome \
                --variable amazonUrl:${TARGET_URL} \
                --nostatusrc \
                -d Reports/chrome \
                -o output.xml \
                TestCases

                """
            }
        }
		stage('Publish Robot Result'){
                steps{
                    script {
                        step([
                        $class              : 'RobotPublisher',
                        outputPath          : "${GIT_REPO}/Reports",
                        outputFileName      : "**/output.xml",
                        reportFileName      : '**/report.html',
                        logFileName         : '**/log.html',
                        disableArchiveOutput: false,
                        passThreshold       : 100,
                        unstableThreshold   : 90,
                        otherFiles          : "**/*.png,**/*.jpg",])
                    }
                }
		}
		stage('Run ZAP Scan'){
			steps{
				sh("echo ${env.WORKSPACE}/${GIT_REPO}/securityZap; ls -l;")
				sh("bash -c \"chmod +x ${env.WORKSPACE}/${GIT_REPO}/securityZap/*.sh\"")
				sh("${env.WORKSPACE}/${GIT_REPO}/securityZap/validate_input.sh")
				sh("${env.WORKSPACE}/${GIT_REPO}/securityZap/runZapScan.sh ${params.TARGET_URL} ${env.WORKSPACE} ${params.ZAP_ALERT_LVL}")
			}
		}
		stage('Publish Security Scan Result'){
			steps{
				publishHTML([allowMissing: false,
				alwaysLinkToLastBuild: false,
				keepAll: false,
				reportDir: './reports',
				reportFiles: 'report.html',
				reportName: 'ZAP scan report',
				reportTitles: ''])
			}
		}
	}
	 post {
        always {
            sh("${env.WORKSPACE}/${GIT_REPO}/securityZap/runCleanup.sh")
        }
	}
}
