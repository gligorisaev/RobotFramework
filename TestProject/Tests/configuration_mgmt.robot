*** Settings ***
*** Settings ***
Library    Browser
Library    OperatingSystem
Library    Dialogs
Library    SSHLibrary
Library    DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.145
${USERNAME}       pi
${PASSWORD}       Alex210295
${DeviceID}       Rpi3lite
${Version}        0.7.0
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
${toml}    "files = [\n    { path = '/etc/tedge/tedge.toml', type = 'tedge.toml'},\n    { path = '/etc/tedge/mosquitto-conf/c8y-bridge.conf', type = 'c8y-bridge.conf' },\n    { path = '/etc/tedge/mosquitto-conf/tedge-mosquitto.conf', type = 'tedge-mosquitto.conf' },\n    { path = '/etc/mosquitto/mosquitto.conf', type = 'mosquitto.conf' },\n    { path = '/etc/tedge/c8y/example.txt', type = 'example', user = 'tedge', group = 'tedge', mode = 0o444 }\n]"


*** Test Cases ***

   
Configuation 
    Given Device is connected to Cumulocity
    And The Configuration plugin is initialized
    And The toml file is like in the specification
    When starting the Configuration plugin process
    And Enable configuration on boot
    And Navigate to Cumulocity Device Management 
    And Navigate to the desired Device
    And open Devices Configuration tab
    Then c8y-configuration-plugin is listed as supported configuration type
    And More configurations are listed as in toml file

*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
   
Device is connected to Cumulocity
    SSHLibrary.Execute Command    rm *.deb
    SSHLibrary.Execute Command    rm *.zip

# Download the Package
    New Context    acceptDownloads=True
    New Page    ${url_dow} 
    Click    //a[normalize-space()='Sign in']
    Fill Text    //input[@id='login_field']    ${user_git}
    Fill Text    //input[@id='password']    ${pass_git}
    Click    //input[@name='commit']
    Fill Text    //input[@placeholder='Filter workflow runs']    workflow:build-workflow is:success 
    Keyboard Key    press    Enter    

    Click    //a[@aria-label='Run ${BUILD} of build-workflow. build-workflow']
    ${dl_promise}          Promise To Wait For Download    ${DIRECTORY}${FILENAME}.zip
    Click    //a[normalize-space()='${FILENAME}']
    ${file_obj}=    Wait For  ${dl_promise}
# Copy File to Device
    Put File    /Users/glis/Downloads/${FILENAME}.zip
# Unpack the File
    SSHLibrary.Execute Command    unzip ${FILENAME}.zip
# Dependency installation
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install mosquitto
# Install Libmosquitto1
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install libmosquitto1
# Install Collectd-core
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install collectd-core
# thin-edge.io installation
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_${Version}_arm*.deb
# Install Tedge mapper
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_mapper_${Version}_arm*.deb
# Install Tedge agent
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_agent_${Version}_arm*.deb
# Install Tedge apama plugin
    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_apama_plugin_${Version}_arm*.deb
# Install tedge apt plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_apt_plugin_${Version}_arm*.deb
# Install Tedge logfile request plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./c8y_log_plugin_${Version}_arm*.deb
# Install C8y plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./c8y_configuration_plugin_${Version}_arm*.deb
# Create the certificate
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert create --device-id ${Timestamp}
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
    Log    ${output}
    #You may notice that the issuer of this certificate is the device itself. This is a self-signed certificate. To use a certificate signed by your Certificate Authority, see the reference guide of tedge cert.
# Configure the device
    SSHLibrary.Execute Command    sudo tedge config set c8y.url gligor.latest.stage.c8y.io    #Set the URL of your Cumulocity IoT tenant
    SSHLibrary.Execute Command    sudo tedge config set c8y.root.cert.path /etc/ssl/certs     #Set the path to the root certificate if necessary. The default is /etc/ssl/certs.
    #This will set the root certificate path of the Cumulocity IoT. In most of the Linux flavors, the certificate will be present in /etc/ssl/certs.
    Write   sudo tedge cert upload c8y --user gligor
    Write    Ian@240821
    Sleep    3s
    ${output}=    SSHLibrary.Execute Command    sudo tedge connect c8y
    Should Contain    ${output}    tedge-agent service successfully started and enabled!

The Configuration plugin is initialized
    SSHLibrary.Execute Command    sudo c8y_configuration_plugin --init
The toml file is like in the specification
    SSHLibrary.Execute Command    sudo rm /etc/tedge/c8y/c8y-configuration-plugin.toml
    SSHLibrary.Execute Command    sudo printf ${toml} > c8y-configuration-plugin.toml
    SSHLibrary.Execute Command    sudo mv c8y-configuration-plugin.toml /etc/tedge/c8y/
starting the Configuration plugin process
    SSHLibrary.Execute Command   sudo systemctl start c8y-configuration-plugin.service 
Enable configuration on boot
        SSHLibrary.Execute Command   sudo systemctl enable c8y-configuration-plugin.service
Navigate to Cumulocity Device Management
    Open Browser    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']
    Wait For Elements State    //i[@class='icon-2x dlt-c8y-icon-th']    visible
    Click    //i[@class='icon-2x dlt-c8y-icon-th']
    Wait For Elements State    //span[normalize-space()='Device management']    visible
    Click    //span[normalize-space()='Device management']
    Wait For Elements State    //span[normalize-space()='Devices']    visible
    
Navigate to the desired Device
    Click    //span[normalize-space()='Devices']
    Wait For Elements State    //span[normalize-space()='All devices']    visible
    Click    //span[normalize-space()='All devices']
    Wait For Elements State    //td[@ng-class='table-cell-truncate']    visible
    Click    //td[@ng-class='table-cell-truncate']
    Wait For Elements State    //span[normalize-space()='Configuration']    visible
    
open Devices Configuration tab
    Click    //span[normalize-space()='Configuration']
    Wait For Elements State    //span[@title='c8y-configuration-plugin']    visible
    
c8y-configuration-plugin is listed as supported configuration type
    Click    //span[@title='c8y-configuration-plugin']
    Wait For Elements State    //button[@id='action-btn']    visible
    Click    //button[@id='action-btn']
More configurations are listed as in toml file
    Pause Execution