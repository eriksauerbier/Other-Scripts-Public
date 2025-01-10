# Diese Skript bereinigt Windows Server 2025 Features die nicht benötigt werden
# Stannek GmbH - v.1.0 - 06.01.2025 - E.Sauerbier

# AzureArc entfernen
Remove-WindowsCapability -online -Name AzureArcSetup~~~~

# Windows Feedback Hub entfernen
Get-AppxPackage | ? {$_.Name -like 'Microsoft.WindowsFeedbackHub*'} | Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -Online | ? {$_.DisplayName -Like 'Microsoft.WindowsFeedbackHub'} | Remove-AppxProvisionedPackage -Online