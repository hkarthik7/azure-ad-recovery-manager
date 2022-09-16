---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Restore-AzADSecurityGroup

## SYNOPSIS

Restore-AzADSecurityGroup helps to restore the deleted security group(s) from backup.

## SYNTAX

### ByName (Default)
```
Restore-AzADSecurityGroup -GroupDisplayName <String> [<CommonParameters>]
```

### All
```
Restore-AzADSecurityGroup [-RestoreAll] [<CommonParameters>]
```

## DESCRIPTION

Restore-AzADSecurityGroup helps to restore the deleted security group(s) from backup. You can either restore all the deleted groups or restore a particular group.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

# Restore all the deleted security groups
PS C:\> Restore-AzADSecurityGroup -RestoreAll -Verbose

# Restore a particular security group
PS C:\> Restore-AzADSecurityGroup -GroupDisplayName 'new-group-to-restore' -Verbose
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -GroupDisplayName

Display name of the security group.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RestoreAll

If true restores all the security groups.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

The account you are using should have necessary permissions to perform the restore action.

## RELATED LINKS

https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Restore-AzADSecurityGroup.md