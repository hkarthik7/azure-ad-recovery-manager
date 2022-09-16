---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Find-UserMemberShip

## SYNOPSIS

Find-UserMembership helper function to get the users' group membership details.

## SYNTAX

### ByPattern (Default)
```
Find-UserMemberShip -NamePattern <String> [<CommonParameters>]
```

### ByName
```
Find-UserMemberShip -Name <String> [<CommonParameters>]
```

### ById
```
Find-UserMemberShip -Id <String> [<CommonParameters>]
```

## DESCRIPTION

Find-UserMembership helper function to get the users' group membership details.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

PS C:\> Find-UserMembership -Name 'user-name'
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -Id

Find the user membership by id.

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

Find the user membership by user name.

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

Gets the membership details for passed user name pattern.

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

[Find-UserMemberShip](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-UserMemberShip.md)