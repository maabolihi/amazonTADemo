*** Settings ***
Documentation     The setup before run the test suites
Library  SeleniumLibrary

*** Variables ***
${AmazonUrl}  https://www.amazon.com/
${UnavailableIpadProName}   2020 Apple iPad Pro (11-inch, Wi-Fi, 256GB) - Space Gray (2nd Generation)
${LocatorSearchBox}    xpath=//input[@id="twotabsearchtextbox"]
${LocatorConditionOfUse}    xpath=//a[text()="Conditions of Use"]
${LocatorSearchButton}    xpath=//input[@id="nav-search-submit-button"]
${LocatorCurrentlyUnavailable}    xpath=//span[text()="Currently unavailable."]
${LocatorModelNameIpadPro}  xpath=//span[@class="a-size-base" and contains(text(),"IPad Pro")]
${LocatorHomeSignInButtone}    xpath=//a[@id="nav-link-accountList"]
${LocatorSignInEmail}   xpath=//input[@id="ap_email"]
${InvalidUserNameEmail}     12_21invalid@gmail.com
${LocatorInvalidEmailUserName}   xpath=//span[contains(text(),"We cannot find an account with that email address")]
${LocatorLogInButton}    xpath=//input[@id="continue"]

*** Keywords ***
Open Amazon Page
    [Arguments]     ${browser}
    Run Keyword If      '${browser}' == 'Chrome'    Open Chrome   url=${AmazonUrl}
    ...     ELSE
    ...     Open Browser   url=${AmazonUrl}  browser=${browser}
    Maximize Browser Window

Open Chrome
    [Arguments]    ${url}
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --disable-extensions
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --disable-gpu
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    ${enableLogging}    Create list    enable-logging
    Call Method    ${chrome options}    add_experimental_option    excludeSwitches    ${enableLogging}
    Create Webdriver    Chrome    chrome_options=${chrome_options}
    Go To    ${url}

Verify Amazon Page Loaded
    Capture Page Screenshot
    Wait Until Element Is Visible    ${LocatorSearchBox}
    Wait Until Element Is Visible    ${LocatorConditionOfUse}

Search Product
    [Arguments]     ${productToSearch}
    Capture Page Screenshot
    Input Text  ${LocatorSearchBox}    ${productToSearch}
    Click Button  ${LocatorSearchButton}

Verify Product Is Shown
    [Arguments]     ${productName}
    Capture Page Screenshot
    Wait Until Element Is Visible    xpath=//span[text()="${productName}"]

Verify Product Is Ipad Pro Model
    [Arguments]     ${productName}
    Click Element    xpath=//span[text()="${productName}"]
    Wait Until Element Is Visible    ${LocatorModelNameIpadPro}

Go To Login Page
    Click Element    ${LocatorHomeSignInButtone}
    Wait Until Element Is Visible    ${LocatorSignInEmail}

Enter User Name Email
    [Arguments]     ${userEmail}
    Capture Page Screenshot
    Input Text  ${LocatorSignInEmail}    ${userEmail}

Invalid Login Error Shown
    Wait Until Element Is Visible    ${LocatorInvalidEmailUserName}

Verify Invalid Email User
    [Arguments]     ${userEmail}
    Capture Page Screenshot
    Enter User Name Email    userEmail=${userEmail}
    Click Button  ${LocatorLogInButton}
    Invalid Login Error Shown