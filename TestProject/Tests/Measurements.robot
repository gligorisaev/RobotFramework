*** Settings ***
Documentation          This is the automated manual test which
...                    was running on end of every Sprint
...                    Sending measurements 

Library                SSHLibrary
Library                DateTime

Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.145
${USERNAME}       pi
${PASSWORD}       Alex210295
${DeviceID}       Rpi3lite
${Version}        0.6.4



*** Test Cases ***
Send value
    
    FOR    ${counter}    IN RANGE    10    99
        SSHLibrary.Execute Command    tedge mqtt pub c8y/s/us 211,${counter}
        SSHLibrary.Execute Command    tedge mqtt pub tedge/measurements/child1 '{ "temperature": ${counter} }
        Sleep    1s
        Log    ${counter}
        
    END

*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
