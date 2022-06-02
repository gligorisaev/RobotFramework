*** Settings ***

Library    Browser
Library    Dialogs
Library    DateTime
Library    String
Library    REST   https://gligor.latest.stage.c8y.io/    ssl_verify=false
Library    MQTTLibrary
Library    OperatingSystem


*** Variables ***
${url}    https://github.com/thin-edge/thin-edge.io/actions
${user_git}    gligorisaev@gmail.com
${pass_git}    IanIasev24082021

${ARCH}    aarch64
${FILENAME}    debian-packages-${ARCH}-unknown-linux-gnu.zip
${DIRECTORY}    /Users/glis/Downloads/
${BUILD}




*** Test Cases ***

Download
    New Context    acceptDownloads=True
    Open Browser    ${url}    webkit
    Click    //a[normalize-space()='Sign in']
    Fill Text    //input[@id='login_field']    ${user_git}
    Fill Text    //input[@id='password']    ${pass_git}
    Click    //input[@name='commit']
    
    Pause Execution

    Fill Text    //input[@placeholder='Filter workflow runs']    workflow:build-workflow is:success 
    Keyboard Key    press    Enter

    ${BUILD}    Get Value From User    Insert Workflow Number (e.g. 716)
    Log    ${BUILD}
    Set Global Variable    ${BUILD}
    Click    //a[@aria-label='Run ${BUILD} of build-workflow. build-workflow']

    ${dl_promise}          Promise To Wait For Download    ${DIRECTORY}${FILENAME}
    Click    //a[normalize-space()='debian-packages-${ARCH}-unknown-linux-gnu']
    ${file_obj}=    Wait For  ${dl_promise}







    

    
