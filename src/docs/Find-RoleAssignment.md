---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Find-RoleAssignment

## SYNOPSIS

Find-RoleAssignment gets the role assignment for scanned groups.

## SYNTAX

### ByPattern (Default)
```
Find-RoleAssignment -NamePattern <String> [<CommonParameters>]
```

### ByName
```
Find-RoleAssignment -Name <String> [<CommonParameters>]
```

### ById
```
Find-RoleAssignment -Id <String> [<CommonParameters>]
```

### All
```
Find-RoleAssignment [-All] [<CommonParameters>]
```

## DESCRIPTION

Find-RoleAssignment gets the role assignment for scanned groups. You should run `Get-AzRoleAssignment` to get the details of role assignments. This cmdlet is helper function that has a backup of role assignments for only scanned security groups.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

PS C:\> Find-RoleAssignment -Name 'test-group'
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -All

If true lists all scanned role assignments.

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

### -Id

Get the role assignments by group id.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Get the role assignments by group name.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePattern

Get the role assignments by group name pattern.

```yaml
Type: String
Parameter Sets: ByPattern
Aliases:

Required: True
Position: Named
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

https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-RoleAssignment.md