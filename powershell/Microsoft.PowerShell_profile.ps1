$colors = @{
    "red"     = "`e[31m";
    "green"   = "`e[32m";
    "yellow"  = "`e[33m";
    "blue"    = "`e[34m";
    "magenta" = "`e[35m";
    "cyan"    = "`e[36m";
    "reset"   = "`e[m";
    "bold"    = "`e[1m";
    "inverse" = "`e[7m"
}

function Get-GitInfo {
    $isinsideworktree = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $isinsideworktree -ne "true") {
        Clear-LastExitCode
        return ""
    }

    $branch      = git rev-parse --abbrev-ref HEAD 2>$null
    $status      = git status --porcelain 2>$null
    $upstream    = git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
    $aheadBehind = if ($upstream) { git rev-list --left-right --count "$upstream...HEAD" 2>$null } else { $null }

    $staged    = 0
    $modified  = 0
    $untracked = 0

    foreach ($line in $status) {
        if ($line.Length -ge 2) {
            $indexStatus = $line[0]
            $workStatus  = $line[1]

            if ($indexStatus -ne ' ' -and $indexStatus -ne '?') {
                $staged++
            }
            if ($workStatus -eq 'M' -or $workStatus -eq 'D') {
                $modified++
            }
            if ($indexStatus -eq '?' -and $workStatus -eq '?') {
                $untracked++
            }
        }
    }

    $gitStatus = "$($colors['magenta'])[$($colors['cyan'])$branch"

    if ($LASTEXITCODE -eq 0 -and $upstream -and $aheadBehind) {
        $parts  = $aheadBehind -split '\s+'
        $behind = [int]$parts[0]
        $ahead  = [int]$parts[1]

        if ($ahead -gt 0)  { $gitStatus += " $($colors['green'])↑$ahead" }
        if ($behind -gt 0) { $gitStatus += " $($colors['red'])↓$behind" }
    } else {
        Clear-LastExitCode
    }

    if ($staged -gt 0)    { $gitStatus += " $($colors['green'])•$staged" }
    if ($modified -gt 0)  { $gitStatus += " $($colors['yellow'])~$modified" }
    if ($untracked -gt 0) { $gitStatus += " $($colors['blue'])?$untracked" }
    $gitStatus += "$($colors['magenta'])]$($colors['reset'])"

    return $gitStatus
}

function prompt {
    $green    = $colors['green']
    $cyan     = $colors['cyan']
    $red      = $colors['red']
    $bold     = $colors['bold']
    $reset    = $colors['reset']
    $user     = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [System.Net.Dns]::GetHostName() }
    $path     = Split-Path -Leaf $PWD
    $lastcode = $LASTEXITCODE
    $gitinfo  = Get-GitInfo

    if ($lastcode) {
        $lem = "$red($lastcode)$reset"
        "$lem $bold$green$user@$computer$reset $cyan$path$reset $gitinfo>`n$ "
    } else {
        "$bold$green$user@$computer$reset $cyan$path$reset $gitinfo>`n$ "
    }
}

function Clear-LastExitCode {
    $global:LASTEXITCODE = 0
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if ($env:ChocolateyInstall -and (Test-Path $ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
