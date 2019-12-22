# Upload-files-to-SharePoint-online-document-library-using-PowerShell-CSOM
Using this script we can upload multiple files or documents to SharePoint online document library using PowerShell CSOM programmatically from the given directory.

Prerequisites to execute this script:
Need to place the below two DLLs in your script directory “Dependency Files” folder as like below:

https://i1.wp.com/global-sharepoint.com/wp-content/uploads/2019/11/DownloadDocumentsUsingPowerShellCSOM5.jpg?resize=579%2C156&ssl=1

Change the value of the variable in the variables section like below:

#Variables
$siteURL="Site URL"
$listName="Document Library Name"
$filesFolderLoaction=$directoryPathForFileToUploadLocation;
#Pass the local directory path where files are located. 
#Example:"C:\Temp\Files To Upload"
$userName = "YourSPOAccount@YourTenantDomain.com"
$password = "YourPassWord"
$securePassword= $password | ConvertTo-SecureString -AsPlainText -Force
#Variables ends here.

Script execution example:

https://i0.wp.com/global-sharepoint.com/wp-content/uploads/2019/11/FileUpload3.png?w=993&ssl=1

Output:

https://i2.wp.com/global-sharepoint.com/wp-content/uploads/2019/11/FileUpload4.png?w=943&ssl=1

Reference URL:

https://global-sharepoint.com/powershell/upload-files-to-sharepoint-online-document-library-using-powershell-csom/
