################################################################################
#This script will upload the files to SharePoint online document library from the local path.
#Author: Habibur Rahaman
#Date: 22.12.2019
################################################################################

#Variables
$siteURL="https://globalsharepoint.sharepoint.com/sites/TestSite/"
$listName="TestDocumentLibrary"
$fromDate="2019-10-28"
$toDate="2019-11-09"
$filesFolderLoaction=$directoryPathForFileToUploadLocation;
$userName = "YourSPOAccount@YourTenantDomain.com"
$password = "YourPassWord"
$securePassword= $password | ConvertTo-SecureString -AsPlainText -Force
#Variables ends here.


#Load SharePoint CSOM Assemblies
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
cls

$fileName = "File_Uploading_Report"
#'yyyyMMddhhmm   yyyyMMdd
$enddate = (Get-Date).tostring("yyyyMMddhhmmss")
#$filename =  $enddate + '_VMReport.doc'  
$logFileName = $fileName +"_"+ $enddate+"_Log.txt"   
$invocation = (Get-Variable MyInvocation).Value  
$directoryPath = Split-Path $invocation.MyCommand.Path  

$directoryPathForLog=$directoryPath+"\"+"LogFiles"
if(!(Test-Path -path $directoryPathForLog))  
        {  
            New-Item -ItemType directory -Path $directoryPathForLog
            #Write-Host "Please Provide Proper Log Path" -ForegroundColor Red   
        }   


#$logPath = $directoryPath + "\" + $logFileName 

$logPath = $directoryPathForLog + "\" + $logFileName 
  
$isLogFileCreated = $False 



#DLL location

$directoryPathForDLL=$directoryPath+"\"+"Dependency Files"
if(!(Test-Path -path $directoryPathForDLL))  
        {  
            New-Item -ItemType directory -Path $directoryPathForDLL
            #Write-Host "Please Provide Proper Log Path" -ForegroundColor Red   
        } 

#DLL location

$clientDLL=$directoryPathForDLL+"\"+"Microsoft.SharePoint.Client.dll"
$clientDLLRuntime=$directoryPathForDLL+"\"+"Microsoft.SharePoint.Client.dll"

Add-Type -Path $clientDLL
Add-Type -Path $clientDLLRuntime


#Files to upload location

$directoryPathForFileToUploadLocation=$directoryPath+"\"+"Files To Upload"
if(!(Test-Path -path $directoryPathForFileToUploadLocation))  
        {  
            New-Item -ItemType directory -Path $directoryPathForFileToUploadLocation
            #Write-Host "Please Provide Proper Log Path" -ForegroundColor Red   
        } 

#Files to upload location ends here.
 

function Write-Log([string]$logMsg)  
{   
    if(!$isLogFileCreated){   
        Write-Host "Creating Log File..."   
        if(!(Test-Path -path $directoryPath))  
        {  
            Write-Host "Please Provide Proper Log Path" -ForegroundColor Red   
        }   
        else   
        {   
            $script:isLogFileCreated = $True   
            Write-Host "Log File ($logFileName) Created..."   
            [string]$logMessage = [System.String]::Format("[$(Get-Date)] - {0}", $logMsg)   
            Add-Content -Path $logPath -Value $logMessage   
        }   
    }   
    else   
    {   
        [string]$logMessage = [System.String]::Format("[$(Get-Date)] - {0}", $logMsg)   
        Add-Content -Path $logPath -Value $logMessage   
    }   
} 

#The below function will upload the file from local directory to SharePoint Online library.
Function FileUploadToSPOnlineLibrary()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SPOSiteURL,
        [Parameter(Mandatory=$true)] [string] $SourceFilePath,
        [Parameter(Mandatory=$true)] [string] $File,
        [Parameter(Mandatory=$true)] [string] $TargetLibrary,
        [Parameter(Mandatory=$true)] [string] $UserName,
        [Parameter(Mandatory=$true)] [string] $Password
    )
 
    Try 
    {
       
        $securePassword= $Password | ConvertTo-SecureString -AsPlainText -Force  
        #Setup the Context
        $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SPOSiteURL)
        $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $securePassword)

        $list = $ctx.Web.Lists.GetByTitle($TargetLibrary)
        $ctx.Load($list)
        $ctx.ExecuteQuery()     
       
        $tarGetFilePath=$siteURL+"/"+"$TargetLibrary"+"/"+$File

        $fileOpenStream = New-Object IO.FileStream($SourceFilePath, [System.IO.FileMode]::Open)  
        $fileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation  
        $fileCreationInfo.Overwrite = $true  
        $fileCreationInfo.ContentStream = $fileOpenStream  
        $fileCreationInfo.URL = $File  
        $uploadFileInfo = $list.RootFolder.Files.Add($FileCreationInfo)  
        $ctx.Load($uploadFileInfo)  
        $ctx.ExecuteQuery() 

         
        Write-host -f Green "File '$SourceFilePath' has been uploaded to '$tarGetFilePath' successfully!"
    }
    Catch 
    {
            
            $ErrorMessage = $_.Exception.Message +"in uploading File!: " +$tarGetFilePath
            Write-Host $ErrorMessage -BackgroundColor Red
            Write-Log $ErrorMessage 


    }
}

$filesCollectionInSourceDirectory=Get-ChildItem $filesFolderLoaction -File 

$uploadItemCount=1;
     
    #Extract the each file item from the folder.
    ForEach($oneFile in $filesCollectionInSourceDirectory)
    {            
               
            try
            {                            
          
                FileUploadToSPOnlineLibrary -SPOSiteURL $siteURL -SourceFilePath $oneFile.FullName -File $oneFile -TargetLibrary $listName -UserName $UserName -Password $Password
                
                $fileUploadingMessage=$uploadItemCount.ToString()+": "+$oneFile.Name; 
                Write-Host $fileUploadingMessage -BackgroundColor DarkGreen
                Write-Log $fileUploadingMessage

        $uploadItemCount++

        }
        catch
        { 
            $ErrorMessage = $_.Exception.Message +"in: " +$oneFile.Name
            Write-Host $ErrorMessage -BackgroundColor Red
            Write-Log $ErrorMessage 

        }

    }
    Write-Host "========================================================================"
    Write-Host "Total number of files uploaded: " $filesCollectionInSourceDirectory.Count 
    Write-Host "========================================================================"