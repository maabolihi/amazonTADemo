*** Settings ***
Library  SeleniumLibrary    run_on_failure=None
Resource  ../TestCaseKeyword/amazon.robot
Resource  ../setup.robot
Suite Setup    Test Setup
#Suite Teardown    Window Ke
# the browser will be opened in the start-up of the test case
Test Setup       Open Amazon Page    browser=${Browser}
Test Teardown    Close Browser

*** Keywords ***

*** Test Cases ***

Test Case 1: Search Ipad 2020 In Amazon
    [Tags]  smoke_test
    amazon.Verify Amazon Page Loaded
    amazon.Search Product  productToSearch=Ipad 2020
    amazon.Verify Product Shown Is Unavailable  productName=${UnavailableIpadProName}

Test Case 2: Invalid Log In Amazon
    [Tags]  log_in
    amazon.Verify Amazon Page Loaded
    amazon.Go To Login Page
    amazon.Verify Invalid Email User  userEmail=${InvalidUserNameEmail}