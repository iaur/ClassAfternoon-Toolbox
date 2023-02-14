function UpdateDL {
    
    try {
        #--init
        $counter = 0 
        $skipped = 0 
        $modified = 0 
   
        function CheckUpdateCSV {
            $global:UpdateCSV = Import-Csv -Path "$RootPath\deps\update.csv"
            if ($($UpdateCSV.PrimarySMTPAddress.Count) -gt 0) {
                
            }else{
                
                Write-Host "$(Get-Date -Format "HH:mm")[Log]: Update CSV is empty (~_^)" -foregroundcolor Yellow
    
                #popup method 2
                Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Attempting to update [update.csv]"
                $UpdateCSVResult = [System.Windows.MessageBox]::Show("Empty CSV. Do you want to update [update.csv] file?","$($json.ToolName) $($json.ToolVersion)",$YesNoButton,$QButton)
    
                If($UpdateCSVResult -eq "Yes")
                {
                    Invoke-Item "$RootPath\deps\update.csv"
                    Start-Sleep -s 15
                    Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Checking again [update.csv]"
                    [System.Windows.MessageBox]::Show("Checking again [update.csv]","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                    CheckUpdateCSV
                }else{
                    [System.Windows.MessageBox]::Show("Goodbye!.","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                }
       
            }
        }
        
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Initialization success"
        CheckUpdateCSV
        foreach($c in $UpdateCSV){
            $counter++
            #--m365
            Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Retreving object ($($c.PrimarySMTPAddress)) EXO details"
            try {
                $ResultDLObject = GetDL -Identity "$($c.TargetDLSMTPAddress)"
                $ResultUserObject = Get-EXOMailbox $c.PrimarySMTPAddress

                try{
                    Add-DistributionGroupMember -Identity $c.TargetDLSMTPAddress -Member $c.PrimarySMTPAddress

                    Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Object added to $($c.TargetDLSMTPAddress) success."
                    $modified++

                }catch{
                    Write-Host "`n$(Get-Date -Format "HH:mm")[Error]: Object added to $($c.TargetDLSMTPAddress) failed. [$($_.Exception.Message)]"
                    $skipped++
                }
            }
            catch {
                Write-Host "`n$(Get-Date -Format "HH:mm")[Debug]: Skipped $counter either DL or User object does not exist"
                $skipped++
            }
            
        }

        Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Allowing 20 seconds replication"
        Start-Sleep -s 20
        Write-Host "`n------------------OUTPUT-------------------------`nModified: $modified`nSkipped: $skipped"
        
    }
    catch {
        Get-Kill -Mode "Hard"
    }
}