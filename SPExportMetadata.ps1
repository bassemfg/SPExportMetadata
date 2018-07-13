Add-PSSnapin "Microsoft.SharePoint.Powershell"
Add-PSSnapin "Microsoft.SharePoint.Powershell"

# Get All Web Applications 
$sbFields = New-Object System.Text.StringBuilder(1024)
$sbVals = New-Object System.Text.StringBuilder(1024)
#[void]$sbVals.Append('Was it a car')
#$sbVals.ToString()

$WebApps=Get-SPWebApplication
foreach($webApp in $WebApps) 
{ 
    foreach ($SPsite in $webApp.Sites) 
    { # get the collection of webs 
        foreach($SPweb in $SPsite.AllWebs) 
        { 
            $sbFields.Length = 0;
            write-host $SPweb.title ":" $spweb.URL 
            
            foreach($list in $SPweb.Lists) 
            { 
                $sbVals.Length = 0;
                if($List.BaseTemplate -eq "DocumentLibrary")
                {
                    $j = 0;
                    Write-Host $list.ID ":" $list.Title
                    foreach($item in $list.Items) 

                    { 
                            if ($j -eq 0)
                            {
                                [void]$sbFields.Append("SourcePath");
                                [void]$sbFields.Append(',');
								[void]$sbFields.Append("UniqueId");
                                [void]$sbFields.Append(',');
                            }

                            [void]$sbVals.Append($item["URL Path"].Replace(',',' '));
                            [void]$sbVals.Append(',');
							[void]$sbVals.Append($item["UniqueId"]);
                            [void]$sbVals.Append(',');


                        Write-Host $item.Title

                         foreach($field in $item.Fields) 
                         {
                           #Write-Host $field.Name
                            try
                                {
                                    if ($field.Hidden -eq $false -and $field.Sealed -eq $false )
                                    {
                                        if ($j -eq 0)
                                        {
                                            [void]$sbFields.Append($field.Title);
                                            [void]$sbFields.Append(',');
                                        }

                                        if (($item[$field.ToString()]) -ne $null)
                                        {
                                            [void]$sbVals.Append($item[$field.Title].ToString().Replace(',', ' '));
                                            }
                                        else
                                            {$sbVals.Append(" ");}

                                        $sbVals.Append(',');

                                    }
                                }
                                catch { }
                            }
                            #remove last ','
                            if ($sbFields.Length -gt 0)
                                {$sbFields.Length = $sbFields.Length - 1;}
                            if ($sbVals.Length -gt 0)
                                {$sbVals.Length = $sbVals.Length - 1;}
                            # add new lines
                            [void]$sbFields.Append('
'); 
                            [void]$sbVals.Append('
');
                            $j=$j+1;

                        }
                    }
                        [void]$sbFields.Append($sbVals.ToString());
                        [void]$sbFields.Append('
');
                }
                $file = "c:\metadata_" + $SPweb.Url.Substring($SPweb.Url.LastIndexOf("/")+1) + ".csv"
                $sw = [System.IO.StreamWriter] $file
                $sw.Write($sbFields.ToString());
                $sw.Write($sbVals.ToString());
                $sw.Flush();
                $sw.Close();
            }
                    
                
            } 
        } 
    
 

