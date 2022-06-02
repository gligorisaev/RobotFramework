*** Settings ***
Library    SSHLibrary
Library    DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.145
${USERNAME}       pi
${PASSWORD}       Alex210295
${DeviceID}       Rpi3lite
${Version}        0.6.4
${download_dir}    /Users/glis/Downloads
${url_dow}    https://github.com/thin-edge/thin-edge.io/actions
${user_git}    gligorisaev@gmail.com
${pass_git}    IanIsaev24082021
${FILENAME}
${DIRECTORY}    /Users/glis/Downloads/
${url}    https://gligor.latest.stage.c8y.io/
${user}    gligor
${pass}    Ian@240821
${BUILD}
${ARCH}
${Timestamp}
${dir}

*** Test Cases ***


*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}