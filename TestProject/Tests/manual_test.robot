*** Settings ***
Library    Browser
Library    OperatingSystem
Library    Dialogs
Library    SSHLibrary
Library    DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.43.48
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


Timestamp
    Create Timestamp

Get build
    ${BUILD}    Get Value From User    Insert Workflow Number (e.g. 716)
    Log    ${BUILD}
    Set Global Variable    ${BUILD}
Check Architecture    
    ${output}=    SSHLibrary.Execute Command   uname -m
    ${ARCH}    Set Variable    ${output}
    Set Global Variable    ${ARCH}
Set File Name
    Run Keyword If    '${ARCH}'=='aarch64'    aarch64
    ...  ELSE    armv7   
Check if installation exists on Device
     ${dir}=    SSHLibrary.Execute Command    ls /usr/bin | grep tedge_agent
    Log    ${dir}
    Set Suite Variable    ${dir} 

    Run Keyword If    '${dir}'=='tedge_agent'    exists
    ...  ELSE    doesnt exists



*** Keywords ***
Create Timestamp
        ${Timestamp}=    get current date    result_format=%d%m%Y%H%M%S
        log    ${Timestamp}
        Set Global Variable    ${Timestamp}
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}
aarch64
    [Documentation]    Setting file name according architecture
    ${FILENAME}    Set Variable    debian-packages-aarch64-unknown-linux-gnu
    Log    ${FILENAME}
    Set Global Variable    ${FILENAME}
armv7
    [Documentation]    Setting file name according architecture
    ${FILENAME}    Set Variable    debian-packages-armv7-unknown-linux-gnueabihf
    Log    ${FILENAME}
    Set Global Variable    ${FILENAME}
exists
    SSHLibrary.Execute Command    sudo tedge disconnect c8y
    SSHLibrary.Execute Command    sudo dpkg -P c8y_configuration_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge_agent
    SSHLibrary.Execute Command    sudo dpkg -P c8y_log_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge_mapper
    SSHLibrary.Execute Command    sudo dpkg -P tedge_apt_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge_apama_plugin
    SSHLibrary.Execute Command    sudo dpkg -P tedge
    SSHLibrary.Execute Command    sudo dpkg -P mosquitto
    SSHLibrary.Execute Command    sudo dpkg -P libmosquitto1
    SSHLibrary.Execute Command    sudo DEBIAN_FRONTEND=noninteractive dpkg -P collectd-core
    SSHLibrary.Execute Command    sudo apt -y autoremove
# Remove device from Cumulocity
    New Page    ${url}
    Wait For Elements State    //button[normalize-space()='Log in']    visible
    Type Text    id=user    ${user}
    Type Text    id=password    ${pass}
    Click    //button[normalize-space()='Log in']
    Wait For Elements State    //i[@class='icon-2x dlt-c8y-icon-th']    visible
    Click    //i[@class='icon-2x dlt-c8y-icon-th']
    Wait For Elements State    //span[normalize-space()='Device management']    visible
    Click    //span[normalize-space()='Device management']
    Wait For Elements State    //span[normalize-space()='Devices']    visible
    Click    //span[normalize-space()='Devices']
    Wait For Elements State    //span[normalize-space()='All devices']    visible
    Click    //span[normalize-space()='All devices']
    Wait For Elements State    //tbody/tr[@ng-class="{'interact': onItemClick, 'no-cursor': !onItemClick}"]/td[10]/div[1]    visible
    Click    //tbody/tr[@ng-class="{'interact': onItemClick, 'no-cursor': !onItemClick}"]/td[10]/div[1]
    Wait For Elements State    //div[@ng-repeat='cb in checkboxes | filter: showIf']//span[1]    visible
    Click    //div[@ng-repeat='cb in checkboxes | filter: showIf']//span[1]
    Wait For Elements State    //button[normalize-space()='Delete']    visible
    Click    //button[normalize-space()='Delete']
# Remove certificates from Cumulocity
    # New Page    ${url}
    # Wait For Elements State    //button[normalize-space()='Log in']    visible
    # Type Text    id=user    ${user}
    # Type Text    id=password    ${pass}
    # Click    //button[normalize-space()='Log in']
    # Wait For Elements State    //i[@class='icon-2x dlt-c8y-icon-th']    visible
    # Click    //i[@class='icon-2x dlt-c8y-icon-th']
    # Wait For Elements State    //span[normalize-space()='Device management']    visible
    # Click    //span[normalize-space()='Device management']
    # Wait For Elements State    //span[normalize-space()='Devices']    visible
    # Click    //span[normalize-space()='Devices']
    # Wait For Elements State    //span[normalize-space()='Management']    visible
    Click    //span[normalize-space()='Management']
    Wait For Elements State    //span[normalize-space()='Trusted certificates']    visible
    Click    //span[normalize-space()='Trusted certificates']
    Wait For Elements State    //i[@c8yicon='certificate']    visible
    Click    //button[@title='Actions']//i
    Wait For Elements State    //span[normalize-space()='Delete']    visible
    Click    //span[normalize-space()='Delete']
    Wait For Elements State    //button[normalize-space()='Delete']    visible
    Click    //button[normalize-space()='Delete']

# Delete files
    # SSHLibrary.Execute Command    rm *.deb
    # SSHLibrary.Execute Command    rm *.zip

    doesnt exists


doesnt exists
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

    # Pause Execution