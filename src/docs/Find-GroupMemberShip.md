---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Find-GroupMemberShip

## SYNOPSIS

Find-GroupMemberShip helps to find the members in the given group.

## SYNTAX

### ByPattern (Default)
```
Find-GroupMemberShip -NamePattern <String> [<CommonParameters>]
```

### ByName
```
Find-GroupMemberShip -Name <String> [<CommonParameters>]
```

### ById
```
Find-GroupMemberShip -Id <String> [<CommonParameters>]
```

## DESCRIPTION

Find-GroupMemberShip helper function lists the members in a given group.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

PS C:\> Find-GroupMembership -Name 'test-group'
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -Id

Pass the group id to list the members.

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

Pass the group name to list the members from scanned group.

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

Lists the members from scanned groups for passed name pattern.

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

https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-GroupMemberShip.md