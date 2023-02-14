function ReadDL {
    try {
        
        Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Retreving object details"
        $Result = GetDL -Identity $Identity | select DisplayName,PrimarySmtpAddress,Alias,GroupType | fl | Out-string
        $ResultMember = GetDLMember -Identity $Identity
        $ResultMemberStr = $ResultMember | select Name,PrimarySmtpAddress,RecipientType | fl | Out-string

        if ($Result.Length -gt 0) {
            $countMember = $ResultMember.Count
            Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Object found"
            Write-Host "`n------------------OUTPUT---------------------------`n`nDetails:`n$Result`n`nMembers($countMember):`n$ResultMemberStr"
            [System.Windows.MessageBox]::Show("Object found `n`n`nDetails:`n$Result`n`nMembers($countMember):`n$ResultMemberStr","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon) | Out-Null
        }else{
            Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Object not found"
            [System.Windows.MessageBox]::Show("Object not found","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon) | Out-Null
        }

            
    }
    catch {
        Get-Kill -Mode "Hard"
    }
    
}