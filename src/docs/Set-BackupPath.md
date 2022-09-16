---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Set-BackupPath

## SYNOPSIS

Set-BackupPath sets the path where the backup files should be created.

## SYNTAX

```
Set-BackupPath [-FilePath] <String> [<CommonParameters>]
```

## DESCRIPTION

Set-BackupPath sets the path where the backup files should be created.

## EXAMPLES

### Example 1

```powershell
PS C:\> mkdir "Azure-AD-Backup_$(Get-Date -Format yyyyMMdd_HHmmss)"
PS C:\> Set-BackupPath -FilePath ".\Azure-AD-Backup_$(Get-Date -Format yyyyMMdd_HHmmss)"
```

By default the name of backup database will be created as 'Azure-AD-Backup.db' and you just have to specify the path to store the backup files.

## PARAMETERS

### -FilePath

File path to store the backup files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Set-BackupPath](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Set-BackupPath.md)