*** Settings ***
Documentation     The setup before run the test suites
Library  SeleniumLibrary

*** Variables ***
${AmazonUrl}  https://www.amazon.com/
${UnavailableIpadProName}    2020 Apple iPad Pro (12.9-inch, Wi-Fi, 256GB) - Space Gray (4th Generation)
${LocatorSearchBox}    xpath=//input[@id="twotabsearchtextbox"]
${LocatorConditionOfUse}    xpath=//a[text()="Conditions of Use"]
${LocatorSearchButton}    xpath=//input[@id="nav-search-submit-button"]
${LocatorCurrentlyUnavailable}    xpath=//span[text()="Currently unavailable."]
${LocatorHomeSignInButtone}    xpath=//a[@id="nav-link-accountList"]
${LocatorSignInEmail}   xpath=//input[@id="ap_email"]
${InvalidUserNameEmail}     12_21invalid@gmail.com
${LocatorInvalidEmailUserName}   xpath=//span[contains(text(),"We cannot find an account with that email address")]
${LocatorLogInButton}    xpath=//input[@id="continue"]

*** Keywords ***
Open Amazon Page
    [Arguments]     ${browser}
    Open Browser   url=${AmazonUrl}  browser=${browser}
    Maximize Browser Window

Verify Amazon Page Loaded
    Wait Until Element Is Visible    ${LocatorSearchBox}
    Wait Until Element Is Visible    ${LocatorConditionOfUse}

Search Product
    [Arguments]     ${productToSearch}
    Input Text  ${LocatorSearchBox}    ${productToSearch}
    Click Button  ${LocatorSearchButton}

Verify Product Shown Is Unavailable
    [Arguments]     ${productName}
    Wait Until Element Is Visible    xpath=//span[text()="${productName}"]
    Click Element    xpath=//span[text()="${productName}"]
    Wait Until Element Is Visible    ${LocatorCurrentlyUnavailable}

Go To Login Page
    Click Element    ${LocatorHomeSignInButtone}
    Wait Until Element Is Visible    ${LocatorSignInEmail}

Enter User Name Email
    [Arguments]     ${userEmail}
    Input Text  ${LocatorSignInEmail}    ${userEmail}

Invalid Login Error Shown
    Wait Until Element Is Visible    ${LocatorInvalidEmailUserName}

Verify Invalid Email User
    [Arguments]     ${userEmail}
    Enter User Name Email    userEmail=${userEmail}
    Click Button  ${LocatorLogInButton}
    Invalid Login Error Shown