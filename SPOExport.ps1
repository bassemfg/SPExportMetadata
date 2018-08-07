<#
https://micromidasincorporated.sharepoint.com
boxmigration@originmaterials.com

 NAME
    Get-SPOInventory
 DESCRIPTION
   Script to inventory all sites within a SharePoint Online (O365) site collection.
   If running this script on a machine that does not have SharePoint bits installed, you will need to install the latest SharePoint Server 2013 Client Components SDK on the machine.   
   It can be downloaded from here: http://www.microsoft.com/en-us/download/details.aspx?id=35585     
 PARAMETER SiteUrl
    The URL of your SharePoint Online site collection
	
 PARAMETER UserName
    SharePoint Online User with FULL CONTROL permissions
	
 PARAMETER Password
    User password
	
 PARAMETER OutputFile
    The absolute folder path and file name where the site collection inventory file (*.csv) should be saved
	
 USAGE
    .\Get-SPOInventory.ps1 -SiteUrl https://rightpoint.sharepoint.com -UserName kkakanur@rightpoint.com -Password pass@word  -OutputFile C:\Rightpoint\SiteInventory.csv   
	
#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [string]$SiteUrl,
    [parameter(Mandatory=$true)]
    [string]$UserName,
    [parameter(Mandatory=$true)]
    [string]$Password,
    [parameter(Mandatory=$true)]
    [string]$OutputFile
)
BEGIN{
function Get-SPOSites{
        Param(
        [Microsoft.SharePoint.Client.ClientContext]$Context,
        [Microsoft.SharePoint.Client.Web]$RootWeb)
        #Create array variable to store data
        $siteitems = $null
        $siteitems = @()
        
        #get all webs under root web
        $Webs = $RootWeb.Webs
        $Context.Load($Webs)
        $Context.ExecuteQuery()
        #loop through the webs
        ForEach ($sWeb in $Webs)
        {
            Write-Host $sWeb.url
            $siteUrl = $sWeb.Url;
            #get all lists in web
            $AllLists = $sWeb.Lists
            $Context.Load($AllLists)
            $Context.ExecuteQuery()
            #loop through all lists in web
            ForEach ($list in $AllLists){
             Write-Host List: $list.Title
              #get list title
              $listTitle = $list.Title;
              
              # Do not inventory the following lists -> User Information List, Workflow History, Images, Site Assets, Composed Looks, Microfeed, Workflow Tasks, Access Requests, Master Page Gallery, Web Part Gallery, Style Library, List Template Library
              # NOTE: Add to (or remove from) the list below, as needed.
              
              If($listTitle -ne 'User Information List' -and `
                 $listTitle -ne 'Workflow History' -and `
                 $listTitle -ne 'Images' -and `
                 $listTitle -ne 'Site Assets' -and `
                 $listTitle -ne 'Composed Looks' -and `
                 $listTitle -ne 'Microfeed' -and `
                 $listTitle -ne 'Workflow Tasks' -and `
                 $listTitle -ne 'Access Requests' -and `
                 $listTitle -ne 'Master Page Gallery' -and  `
                 $listTitle -ne 'Web Part Gallery' -and `
                 $listTitle -ne 'Style Library' -and `
                 $listTitle -ne 'List Template Library') {
                
                 #Create a CAML Query object
                 #You can pass an undefined CamlQuery object to return all items from the list, or use the ViewXml property to define a CAML query and return items that meet specific criteria - https://msdn.microsoft.com/en-us/library/office/ee534956(v=office.14).aspx#sectionSection0
                 #In this script an undefined CamlQuery object is passed, to get all list items 
                 $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
                 $AllItems = $list.GetItems($camlQuery)
                 $Context.Load($AllItems)
                 $Context.ExecuteQuery()
                 If($AllItems.Count -gt 0) {
                 ForEach ($item in $AllItems){
                                                   
                          $listType = $list.BaseTemplate
                          $listUrl = $item["FileDirRef"]
                          #set item title based on the type of list
                          switch ($listType) 
                           { 
                                101 { $itemTitle = $item["FileLeafRef"] }    #Document Library
                                103 { $itemTitle = $item["FileLeafRef"] }    #Links List
                                109 { $itemTitle = $item["FileLeafRef"] }    #Picture Library
                                119 { $itemTitle = $item["FileLeafRef"] }    #Site Pages
                                851 { $itemTitle = $item["FileLeafRef"] }    #Media
                                default { $itemTitle = $item["Title"] }
                           }
                           Write-Host Item Name: $itemTitle
                         
                          #retrieve item values
                          $itemType = $item.FileSystemObjectType
                          $itemurl = $item["FileRef"]
                          $itemCreatedBy = $item["Author"].LookupValue
                          $itemCreated = $item["Created"]
                          $itemModifiedBy = $item["Editor"].LookupValue
                          $itemModified = $item["Modified"]
                          #store the item values
                          #earlier versions (v2) of PowerShell do not support [Ordered]. If so, remove [Ordered]. Columns will be randomly ordered, but can be rearranged manually in the CSV file
                          $props = [Ordered]@{'Site' = $siteUrl;
                                     'List Title' = $listTitle;
                                     'List URL' = $listUrl;
                                     'List Type' = $listType;
                                     'Item Title' = $itemTitle;
                                     'Item URL' = $itemUrl;
                                     'Item Type' = $itemType;
                                     'Created By' = $itemCreatedBy;
                                     'Created'= $itemCreated;
                                     'Modified By' = $itemModifiedBy;
                                     'Modified' = $itemModified} ;                      
                          #append the values to the existing array object 
                          $siteitemarray = New-Object -TypeName PSObject -Property $props ; $siteitems += $siteitemarray
                   } #end loop for all items in list
                 } #check if item count is > 0
            } #check if it is a 'do not inventory' list          
          
          } #end loop for all lists in site 
          
          Get-SPOSites -RootWeb $sWeb -Context $Context #recursive call          
        } #end loop for all sites in site collection     
    
    #Output site collection inventory to CSV 
    $siteitems | Export-Csv $OutputFile -Append  
    }
    
    #reference the SharePoint Client DLLs
    Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll" | Out-Null
    Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" | Out-Null    
}
PROCESS
{
    #pass SharePoint Online credentials to get ClientContext object
    $securePassword = ConvertTo-SecureString $PassWord -AsPlainText -Force
    $spoCred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $securePassword)
    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
    $ctx.Credentials = $spoCred
    $Web = $ctx.Web    
	$ctx.Load($Web)    
	$ctx.ExecuteQuery()        
	#call the function that does the inventory of the site collection    
	Get-SPOSites -RootWeb $Web -Context $ctx	
	#Inventory complete    
	Write-Host Site Collection Inventory Completed! -foregroundcolor yellow ; 
}