*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
#Library    RPA.Desktop
Library             RPA.Tables
Library             RPA.Excel.Files
Library             RPA.PDF
Library             OperatingSystem
Library             RPA.Archive


*** Variables ***
${DOWNLOAD_PATH}=           ${OUTPUT DIR}${/}output${/}downloads
${PDF_PATH}=                ${OUTPUT DIR}${/}output${/}pdf
${ORDERLIST_FILE_NAME}=     orders.csv
${EXCEL_EXAMPLE}=           https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from the RobotSpareBin Industries Inc.
    ${order_table}=    Download the order list and return as table
    Open the Robocorp Website
    FOR    ${order}    IN    @{order_table}
        #Log    miau hier sollten die orders geplaced werden
        Close the annoying modal
        Wait Until Keyword Succeeds    5 x    200ms
        ...    Place Order    ${order}
        Click Button    order-another
    END

    Zip it all together


*** Keywords ***
Download the order list and return as table
    Download    ${EXCEL_EXAMPLE}    target_file=${DOWNLOAD_PATH}${/}${ORDERLIST_FILE_NAME}    overwrite=true
    ${order_table}=    Read table from CSV    ${DOWNLOAD_PATH}${/}${ORDERLIST_FILE_NAME}    true
    RETURN    ${order_table}

Open the Robocorp Website
    [Documentation]    Öffnet eine Website
    ${browser}=    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    css:.btn-dark

Place Order
    [Arguments]    ${order}
    Fill the form    ${order}[Head]    ${order}[Body]    ${order}[Legs]    ${order}[Address]
    Click Button    preview
    Click Button    order

    #Wait Until Element Is Visible    id:receipt
    Store the receipt as PDF file    ${order}[Order number]

Fill the form    [Arguments]    ${robot_head}    ${robot_body}    ${robot_legs}    ${address}
    Select From List By Value    id:head    ${robot_head}
    Click Button    id-body-${robot_body}
    #Select Radio Button    id-body-${robot_body}
    RPA.Browser.Selenium.Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${robot_legs}
    RPA.Browser.Selenium.Input Text    address    ${address}

Store the receipt as PDF file    [Arguments]    ${order_number}

    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${PDF_PATH}${/}${order_number}.pdf

Zip it all together
    #
    # ${liste_aller_dateien}=    List Directory    ${PDF_PATH}
    Archive Folder With Zip    ${PDF_PATH}    output${/}rechnungen.zip
    # FOR    ${datei}    IN    @{liste_aller_dateien}
    #    Log    ${liste_aller_dateien}
    # END
