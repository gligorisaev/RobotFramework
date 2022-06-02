*** Settings ***
Documentation          This is the automated manual test which
...                    was running on end of every Sprint
...                    Cloud in use Cumulocity

Library                SSHLibrary
Library                Browser
Library                Dialogs
Library                DateTime
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.0.145
${USERNAME}       pi
${PASSWORD}       Alex210295
${DeviceID}       Rpi3lite
${Version}        0.6.4

${url}    https://gligor.latest.stage.c8y.io/
${user}    gligor
${pass}    Ian@240821

${Timestamp}

*** Test Cases ***
Timestamp
    Create Timestamp
Deinstall All
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
Remove device from Cumulocity
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
Remove certificates from Cumulocity
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
    Wait For Elements State    //span[normalize-space()='Management']    visible
    Click    //span[normalize-space()='Management']
    Wait For Elements State    //span[normalize-space()='Trusted certificates']    visible
    Click    //span[normalize-space()='Trusted certificates']
    Wait For Elements State    //i[@c8yicon='certificate']    visible
    Click    //button[@title='Actions']//i
    Wait For Elements State    //span[normalize-space()='Delete']    visible
    Click    //span[normalize-space()='Delete']
    Wait For Elements State    //button[normalize-space()='Delete']    visible
    Click    //button[normalize-space()='Delete']

#    Manual installation steps - To install thin edge package it is required to use curl to download 
#    the package and dpkg to install it.
Dependency installation
    [Documentation]    thin-edge.io has single dependency and it is mosquitto used for communication 
    ...                southbound and northbound e.g. southbound, devices can publish measurements; 
    ...                northbound, gateway may relay messages to cloud. mosquitto can be installed 
    ...                with your package manager. For apt the command may look as following:
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install mosquitto
    SSHLibrary.File Should Exist    /usr/sbin/mosquitto    #check if installation sucessful
Install Libmosquitto1
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install libmosquitto1
Install Collectd-core
    SSHLibrary.Execute Command    sudo apt-get --assume-yes install collectd-core
    SSHLibrary.File Should Exist    /usr/sbin/collectd
thin-edge.io installation
    [Documentation]    When all dependencies are in place you can proceed with installation 
    ...                of thin-edge.io cli and thin-edge.io mapper service.
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_${Version}_arm*.deb
    ${output}=    SSHLibrary.Execute Command    ls /usr/bin | grep tedge
    Should Contain    ${output}    tedge
Install Tedge mapper
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_mapper_${Version}_arm*.deb
    ${output}=    SSHLibrary.Execute Command    ls /usr/bin | grep tedge
    Should Contain    ${output}    tedge_mapper
Install Tedge agent
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_agent_${Version}_arm*.deb
    ${output}=    SSHLibrary.Execute Command    ls /usr/bin | grep tedge
    Should Contain    ${output}    tedge_agent
Install Tedge apama plugin
    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_apama_plugin_${Version}_arm*.deb
Install tedge apt plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./tedge_apt_plugin_${Version}_arm*.deb
    # ${output}=    SSHLibrary.Execute Command    tedge_apt_plugin -V
    # Should Contain    ${output}    tedge_apt_plugin ${Version}
Install Tedge logfile request plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./c8y_log_plugin_${Version}_arm*.deb
Install C8y plugin
    ${output}=    SSHLibrary.Execute Command    sudo dpkg -i ./c8y_configuration_plugin_${Version}_arm*.deb
    ${output}=    SSHLibrary.Execute Command    ls /usr/bin | grep c8y
    Should Contain    ${output}    c8y_configuration_plugin
Create the certificate
    [Documentation]    The tedge cert create command creates a self-signed certificate which can be used for testing purpose.
    ...                A single argument is required: an identifier for the device. This identifier will be used to uniquely 
    ...                identify your devices among others in your cloud tenant. This identifier will be also used as the 
    ...                Common Name (CN) of the certificate. Indeed, this certificate aims to authenticate that this device is 
    ...                actually the device with that identity.
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert create --device-id ${Timestamp}
    ${output}=    SSHLibrary.Execute Command    sudo tedge cert show    #You can then check the content of that certificate.
    Should Contain    ${output}    Device certificate: /etc/tedge/device-certs/tedge-certificate.pem
    Log    ${output}
    #You may notice that the issuer of this certificate is the device itself. This is a self-signed certificate. To use a certificate signed by your Certificate Authority, see the reference guide of tedge cert.
Configure the device
    [Documentation]    To connect the device to the Cumulocity IoT,
    ...                one needs to set the URL of your Cumulocity IoT tenant 
    ...                and the root certificate as below.
    SSHLibrary.Execute Command    sudo tedge config set c8y.url gligor.latest.stage.c8y.io    #Set the URL of your Cumulocity IoT tenant
    SSHLibrary.Execute Command    sudo tedge config set c8y.root.cert.path /etc/ssl/certs     #Set the path to the root certificate if necessary. The default is /etc/ssl/certs.
    #This will set the root certificate path of the Cumulocity IoT. In most of the Linux flavors, the certificate will be present in /etc/ssl/certs.
    Write   sudo tedge cert upload c8y --user gligor
    Write    Ian@240821
    Sleep    3s
    ${output}=    SSHLibrary.Execute Command    sudo tedge connect c8y
    Should Contain    ${output}    tedge-agent service successfully started and enabled!

*** Keywords ***
Open Connection And Log In
   SSHLibrary.Open Connection     ${HOST}
   SSHLibrary.Login               ${USERNAME}        ${PASSWORD}

Create Timestamp
        ${Timestamp}=    get current date    result_format=%d%m%Y%H%M%S
        log    ${Timestamp}
        Set Global Variable    ${Timestamp}