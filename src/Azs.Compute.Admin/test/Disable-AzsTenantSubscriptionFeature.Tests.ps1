$loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
if (-Not (Test-Path -Path $loadEnvPath)) {
    $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
}
. ($loadEnvPath)
$TestRecordingFile = Join-Path $PSScriptRoot 'Disable-AzsTenantSubscriptionFeature.Recording.json'
$currentPath = $PSScriptRoot
while(-not $mockingPath) {
    $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
    $currentPath = Split-Path -Path $currentPath -Parent
}
. ($mockingPath | Select-Object -First 1).FullName

Describe 'Disable-AzsTenantSubscriptionFeature' {
    It 'TestDisableTenantSubscriptionFeature' -Skip:$('TestDisableTenantSubscriptionFeature' -in $global:SkippedTests) {
        $global:TestName = 'TestDisableTenantSubscriptionFeature'

        $tenantSubscriptionId = [guid]::NewGuid().ToString()
        $feature = Get-AzsFeature -Name Microsoft.Compute.EmergencyVMAccess -Location $env.Location
        $originalLastSubscriptionId = $feature.EnabledTenantSubscriptionId[-1]
        Enable-AzsTenantSubscriptionFeature  -TenantSubscriptionId $tenantSubscriptionId -FeatureName Microsoft.Compute.EmergencyVMAccess -Location $env.Location -SubscriptionId $env.SubscriptionId
        Disable-AzsTenantSubscriptionFeature  -TenantSubscriptionId $tenantSubscriptionId -FeatureName Microsoft.Compute.EmergencyVMAccess -Location $env.Location -SubscriptionId $env.SubscriptionId
        $feature = Get-AzsFeature -Name Microsoft.Compute.EmergencyVMAccess -Location $env.Location -SubscriptionId $env.SubscriptionId
        $feature.EnabledTenantSubscriptionId[-1] | Should Be $originalLastSubscriptionId
    }
}
