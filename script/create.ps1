function CreateDL {
    
    try {
        #--init
        $counter = 0 
   
        function CheckCreateCSV {
            $global:CreateCSV = Import-Csv -Path "$RootPath\create.csv"
            if ($($CreateCSV.Name.Count) -gt 0) {
                
            }else{
                Write-Host "`n------------------OUTPUT($counter)-------------------------"
                Write-Host "$(Get-Date -Format "HH:mm")[Log]: CSV is empty (~_^)" -foregroundcolor Yellow
    
                #popup method 2
                Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Attempting to update [create.csv]"
                $UpdateCSVResult = [System.Windows.MessageBox]::Show("Empty CSV. Do you want to update [create.csv] file?","$($json.ToolName) $($json.ToolVersion)",$YesNoButton,$QButton)
    
                If($UpdateCSVResult -eq "Yes")
                {
                    Invoke-Item "$RootPath\create.csv"
                    Start-Sleep -s 15
                    Write-Host "`n$(Get-Date -Format "HH:mm")[Debug]: Checking again [create.csv]"
                    [System.Windows.MessageBox]::Show("Checking again [create.csv]","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                    CheckCreateCSV
                }else{
                    [System.Windows.MessageBox]::Show("Goodbye!.","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                }
       
            }
        }
        
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Initialization success"
        CheckCreateCSV
        foreach($c in $CreateCSV){
            #--transform
            Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Transforming data"
            $NoCharsItem = $(($($c.Name).TrimEnd()).TrimStart())  -replace '[\W]', '' #remove whitespace and special chars
            #--assembly
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: Assembling output"
            $AssembledObj = [PSCustomObject]@{
                Name = $NoCharsItem
                DisplayName  = $json.DisplayNamePrefix + $NoCharsItem
                PrimarySmtpAddress  = $($json.AliasPrefix + $($NoCharsItem.ToLower())) + "@" + $json.DomainName #join and convert to lowercases
                Description = "`n Created at: " + $env:COMPUTERNAME + "`n Created by: " + $env:USERNAME + "`n Created on: "  + ($(Get-Date)) + "`n`n=========`n" + $c.Purpose
                Members = ($c.Members) -split (',') #turm members to array
            }
            $counter++
            #--m365
            Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Retreving object details"
            $Result = GetDL -Identity $AssembledObj.PrimarySmtpAddress | select DisplayName,PrimarySmtpAddress,Alias,GroupType | fl | Out-string
            
            if ($Result) {
                Write-Host "`n$(Get-Date -Format "HH:mm")[Debug]: Object already exist"
                Write-Host "`n------------------OUTPUT($counter)-------------------------`n$Result"
                [System.Windows.MessageBox]::Show("Object already exist `n$Result","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                
            }else{
                try{
                    New-DistributionGroup -Name $AssembledObj.Name -PrimarySmtpAddress $AssembledObj.PrimarySmtpAddress -DisplayName $AssembledObj.DisplayName -Description $AssembledObj.Description | Out-Null
                    Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Object creation success. Allowing 20 seconds replication"

                    Start-Sleep -s 20
                    #--output
                    Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Retreving object details"
                    $Result = GetDL -Identity $AssembledObj.PrimarySmtpAddress | select DisplayName,PrimarySmtpAddress,Alias,GroupType | fl | Out-string

                    Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Object replication success."
                    Write-Host "`n------------------OUTPUT($counter)-------------------------`n$Result"
                    [System.Windows.MessageBox]::Show("Object replication success. `n`n$Result","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
                }catch{
                    Write-Host "`n$(Get-Date -Format "HH:mm")[Error]: Object creation failed" 
                    Get-Kill -Mode "Hard"
                }
                
            }
        }
        
    }
    catch {
        Get-Kill -Mode "Hard"
    }
}