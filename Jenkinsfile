def GIT_REPO = "amazonTADemo"
def FIREFOX_VERSION = "78.5.0esr"
def CHROMEDRIVER_VERSION = "89.0.4389.23"
def GECKODRIVER_VERSION = "0.29.0"
def WORKING_DIR = "\$WORKSPACE/${GIT_REPO}"
def ZAP_TARGET_URL = "http://www.itsecgames.com"
def ZAP_ALERT_LVL = "High"

def checkoutGitSCM(branch,gitUrl) {
	checkout([$class: 'GitSCM',
		branches: [[name: branch ]],
		doGenerateSubmoduleConfigurations: false,
		extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: '.']],
		submoduleCfg: [],
		userRemoteConfigs: [[url: gitUrl]]
	])
}

properties([
    pipelineTriggers([cron('*/30 9-17 * * *')]),
    buildDiscarder(logRotator(daysToKeepStr: '3', numToKeepStr: '15')),])

pipeline {
	agent {
		node { label 'test' }
	}
    options {
		timestamps()
		disableConcurrentBuilds()
		buildDiscarder(logRotator(numToKeepStr: '10'))
		timeout(time: 180, unit: 'MINUTES')
	}
    stage ('Initialize') {
	            steps{
	                script {
					    cleanWs()
		            }

                    sh """

                     git clone https://github.com/maabolihi/amazonTADemo.git
                    # Python virtual environment (venv)
                    python3 -m venv ${WORKING_DIR}/TA_env
                    source  ${WORKING_DIR}/TA_env/bin/activate
                    cd  ${WORKING_DIR}
                    which python
                    python3 -m pip install --upgrade pip
                    python3 -m pip install -r requirements.txt
                    deactivate

                    # Download packages
                    if [ ! -d ${WORKING_DIR}/opt ]; then
                        mkdir ${WORKING_DIR}/opt
                    fi
                    cd ${WORKING_DIR}/opt

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

                    PATH=${WORKING_DIR}/opt:\$PATH
                    export PATH
                    which chromedriver
                    which geckodriver

                    # Setup display
                    export DISPLAY=":99.0"
                    Xvfb :99 -screen 0 1280x1024x8 -ac &
                    sleep 1

                    # Activate Python venv
                    source ${WORKING_DIR}/TA_env/bin/activate
                    cd ${WORKING_DIR}

                    PATH=${WORKING_DIR}/opt:\$PATH

                    """
	            }
            }
	stages{
    		stage ('Run Tests') {
    		    parallel{
                    stage ('Test In Firefox'){
                        steps{
                            sh """

                            python3 -u -m robot \
                            --variable browser:Firefox \
                            --nostatusrc \
                            -d Reports/firefox \
                            -o output.xml \
                            TestCases

                            """
                        }

                    }
                    stage ('Test In Chrome'){
                        steps{
                            sh """

                            python3 -m robot \
                            --variable browser:Chrome \
                            --nostatusrc \
                            -d Reports/chrome \
                            -o output.xml \
                            TestCases

                            """
                        }
                    }
                }
	        }

            stage ('Publish RobotFramework Result') {
                steps{
                    RobotPublisher([
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

		    stage ('Run ZAP Scan'){
			    when { branch 'master' }
                steps{
                    sh("echo ${env.WORKSPACE}; ls -l;")
                    sh("bash -c \"chmod +x ${env.WORKSPACE}/*.sh\"")
                    sh("${WORKING_DIR}/security/zap/validate_input.sh")
                    sh("${WORKING_DIR}/security/zap/runZapScan.sh ${params.ZAP_TARGET_URL} ${env.WORKSPACE} ${params.ZAP_ALERT_LVL}")
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
            sh("${WORKING_DIR}/security/zap/runCleanup.sh")
        }	
	}
		}
