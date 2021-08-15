$loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
if (-Not (Test-Path -Path $loadEnvPath)) {
    $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
}
. ($loadEnvPath)
$TestRecordingFile = Join-Path $PSScriptRoot 'Enable-AzsTenantSubscriptionFeature.Recording.json'
$currentPath = $PSScriptRoot
while(-not $mockingPath) {
    $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
    $currentPath = Split-Path -Path $currentPath -Parent
}
. ($mockingPath | Select-Object -First 1).FullName

Describe 'Enable-AzsTenantSubscriptionFeature' {
    It 'TestEnableTenantSubscriptionFeature' -Skip:$('TestEnableTenantSubscriptionFeature' -in $global:SkippedTests) {
        $global:TestName = 'TestEnableTenantSubscriptionFeature'

        $tenantSubscriptionId = [guid]::NewGuid().ToString()
        $feature = Get-AzsFeature -Name Microsoft.Compute.EmergencyVMAccess -Location $env.Location
        $feature.EnabledTenantSubscriptionId[-1] | Should Not Be $tenantSubscriptionId
        Enable-AzsTenantSubscriptionFeature  -TenantSubscriptionId $tenantSubscriptionId -FeatureName Microsoft.Compute.EmergencyVMAccess -Location $env.Location -SubscriptionId $env.SubscriptionId
        $feature = Get-AzsFeature -Name Microsoft.Compute.EmergencyVMAccess -Location $env.Location -SubscriptionId $env.SubscriptionId
        $feature.EnabledTenantSubscriptionId[-1] | Should Be $tenantSubscriptionId
    }
}
