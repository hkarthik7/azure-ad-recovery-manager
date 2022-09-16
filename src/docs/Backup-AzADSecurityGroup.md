---
external help file: azure-ad-recovery-manager-help.xml
Module Name: azure-ad-recovery-manager
online version:
schema: 2.0.0
---

# Backup-AzADSecurityGroup

## SYNOPSIS

Backup-AzADSecurityGroup cmdlet to backup Azure Active Directory security groups.

## SYNTAX

```text
Backup-AzADSecurityGroup [-AsJob] [-Incremental] [-ShowOutput] [[-NumberOfJobs] <Int32>] [<CommonParameters>]
```

## DESCRIPTION

Backup-AzADSecurityGroup cmdlet helps to backup Azure Active Directory security groups and it's members. It takes the backup of role assignments of the security groups for complete restoration.

## EXAMPLES

### Example 1

```powershell
# Set the backup path first
PS C:\> Set-BackupPath -FilePath $PWD.Path

# Take a full backup
PS C:\> Backup-AzADSecurityGroup -Verbose

# Take an incremental backup
PS C:\> Backup-AzADSecurityGroup -Incremental -Verbose

# Run backup as a background job
PS C:\> Backup-AzADSecurityGroup -AsJob -Verbose
```

You should set the backup path before running this cmdlet.

## PARAMETERS

### -AsJob

Runs the backup as background job.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Incremental

Takes an incremental backup. This means if there are any new groups added, this cmdlet looks for new changes and adds it to the backup database.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NumberOfJobs

Specify the number of background jobs to run.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowOutput

Returns the output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Backup-AzADSecurityGroup](https://github.com/hkarthik7/azure-ad-recovery-manager/blob/main/src/docs/Backup-AzADSecurityGroup.md)