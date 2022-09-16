---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Find-User

## SYNOPSIS

Find-User function to find the user from scanned backup file.

## SYNTAX

### ByPattern (Default)
```
Find-User -NamePattern <String> [<CommonParameters>]
```

### ByName
```
Find-User -Name <String> [<CommonParameters>]
```

### ById
```
Find-User -Id <String> [<CommonParameters>]
```

### ByEmail
```
Find-User -Email <String> [<CommonParameters>]
```

### ByUPN
```
Find-User -UserPrincipalName <String> [<CommonParameters>]
```

### All
```
Find-User [-All] [<CommonParameters>]
```

## DESCRIPTION

Find-User function to find the user from scanned backup file.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

PS C:\> Find-User -Name 'user-name'
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -All

If true lists all scanned users.

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

### -Email

Gets a user by email.

```yaml
Type: String
Parameter Sets: ByEmail
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Finds a user by id.

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

Finds a user by name.

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

Get user details for the given name pattern.

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

### -UserPrincipalName

Get the user by user principal name.

```yaml
Type: String
Parameter Sets: ByUPN
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

## RELATED LINKS

https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Find-User.md