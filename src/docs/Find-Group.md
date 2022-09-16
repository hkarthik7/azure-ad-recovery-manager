---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Find-Group

## SYNOPSIS

Find-Group to get the scanned group details.

## SYNTAX

### ByPattern (Default)
```
Find-Group -NamePattern <String> [<CommonParameters>]
```

### ByName
```
Find-Group -Name <String> [<CommonParameters>]
```

### ById
```
Find-Group -Id <String> [<CommonParameters>]
```

### All
```
Find-Group [-All] [<CommonParameters>]
```

## DESCRIPTION

Find-Group is a helper function to get the group(s) details of all scanned security groups.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

PS C:\> Find-Group -All # Lists all the scanned group

PS C:\> Find-Group -Name 'test-group' # Gets the group by name

PS C:\> Find-Group -NamePattern 'test' # Lists all groups with name test

PS C:\> Find-Group -Id 'xxxxxxxxxxxxxxxxxxxxxxxx' # Gets the group by id
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -All

If true lists all scanned groups.

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

Pass the group id to get the group details.

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

Finds group by display name.

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

Finds group(s) for given name pattern.

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

https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-Group.md