*** Settings ***
# Library    Browser
# Library    OperatingSystem
# Library    Dialogs
Library    SSHLibrary
# Library    DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.43.48
${USERNAME}       pi
${PASSWORD}       Alex210295

*** Test Cases ***


*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}