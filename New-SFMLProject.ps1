<#
    .SYNOPSIS
    Creates a new C++ SFML based project for Visual Studio

    .PARAMETER ProjectName
    Required string, the name of the project you want to create
    .PARAMETER ProjectPath
    Optional string, an override to the default path for the project files
    .PARAMETER SFMLLibraryPath
    Optional string, an override to the default path for directory holding the
    lib, bin and lnclude directories with the files that are copied in to
    the project. Could be used to build against different versions of the
    library
    .PARAMETER NoRepository
    Switch, if passed the script will not create a local git repository for
    the project
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = '',
    [Parameter(Mandatory=$false)]
    [string]$SFMLLibraryPath = '',
    [Parameter]
    [switch]$NoRepository
)

Set-StrictMode -Version Latest

# Set defaults
if ($ProjectPath -eq '') {
    $ProjectPath = 'D:\source\repos\'
}
if ($SFMLLibraryPath -eq '') {
    $SFMLLibraryPath = 'D:\SFML\SFML-2.6.1'
}

$gitExe = Join-Path $ENV:ProgramFiles "Git\bin\git.exe"
if (-not (Test-Path $gitExe)) {
    $gitExe = Join-Path $ENV:LOCALAPPDATA "Programs\Git\bin\git.exe"

    if (-not (Test-Path $gitExe)) {
        $gitExe = 'not found'
    }
}

# Pre-start checks
if (-not (Test-Path -Path $SFMLLibraryPath)) {
    throw "SFML library path $SFMLLibraryPath not found"
}

# Content template variables, loaded from external file to keep the
# code here, nice a clean
.\VS2022Templates.ps1

function New-Folder {
    param($path, $name)

    if ($null -eq (New-Item -Path $path -Name $name -ItemType Directory)) {
        throw "Failed to create directory $name in path $path"
    }
}

function Copy-Libraries {
    param($arcitecture, $solutionSFMLPath)

    $arcLibPath = Join-Path $SFMLLibraryPath $arcitecture
    $solutionLibPath = Join-Path $solutionSFMLPath $arcitecture

    Copy-Item -Path (Join-Path $arcLibPath "lib") -Destination $solutionLibPath -Recurse
    Copy-Item -Path (Join-Path $arcLibPath "bin") -Destination $solutionLibPath -Recurse
    Copy-Item -Path (Join-Path $arcLibPath "include") -Destination $solutionLibPath -Recurse
}

function New-ProjectDirStructure {
    param($basePath, $projectName)

    # Are we good to go?
    if ((Test-Path -Path $basePath) -eq $false) {
        throw "Project path $basePath doesn't exist!"
    }
    $solutionPath = Join-Path $basePath $projectName
    if ((Test-Path -Path $solutionPath) -eq $true) {
        throw "Project folder $solutionPath already exists"
    }

    # Create folders
    # Base solution directory
    New-Folder -path $basePath -name $projectName

    # Now the project directory
    New-Folder -path $solutionPath -name $projectName
    # Next the all important lib, bin and include directories
    $sfmlPath = Join-Path $solutionPath "sfml"
    New-Folder -path $solutionPath -name "sfml"
    # copy the sub dirs and contents from our master copy for both architectures
    Copy-Libraries -arcitecture 'x86' -solutionSFMLPath $sfmlPath
    Copy-Libraries -arcitecture 'x64' -solutionSFMLPath $sfmlPath
}

function New-SolutionAndProject {
    param($basePath, $projectName)

    $projectPath = Join-Path $basePath $projectName

    $projectGUID = New-Guid
    $solutionGUID = New-Guid

    $solutionFileContents = [string]::Format($global:solutionFileTemplate, $projectGUID, $projectName, $solutionGUID)
    $solutionFileContents | Out-File -FilePath (Join-Path $projectPath "${projectName}.sln")

    # Yes this is right, the project name appears twice in the path
    $sourcePath = Join-Path $projectPath $projectName
    $projectFileContents = [string]::Format($global:projectFileTemplate, $projectGUID, $basePath, $projectName)
    $projectFileContents | Out-File -FilePath (Join-Path $sourcePath "${projectName}.vcxproj")

    $global:vcxprojFiltersTemplate | Out-File -FilePath (Join-Path $sourcePath "${projectName}.vcxproj.filters")
    $global:vcxprojUserTemplate | Out-File -FilePath (Join-Path $sourcePath "${projectName}.vcxproj.user")

    # Create a source file so the project actually has something to build
    $sourceFileContents = [string]::Format($sourceFileTemplate, $projectName)
    $sourceFileContents | Out-File -FilePath (Join-Path $sourcePath 'main.cpp')
}

function New-Repository {
    param($basePath, $projectName)

    $solutionPath = Join-Path $basePath $projectName
    Push-Location $solutionPath

    $gitIgnorePath = Join-Path $solutionPath '.gitignore'
    $gitIgnoreTemplate | Out-File -FilePath $gitIgnorePath

    & $gitExe init
    & $gitExe add .
    & $gitExe commit -a -m 'SFML template appiled'

    Pop-Location
}

if ($NoRepository -eq $false -and $gitExe -eq 'not found') {
    Write-Host "I can't find git.exe, if you still want to set up the solution pass the NoRepository switch to disable this or install git"
    return 1
}

New-ProjectDirStructure -basePath $ProjectPath -projectName $ProjectName
New-SolutionAndProject -basePath $ProjectPath -projectName $ProjectName

if (-not $NoRepository) {
    New-Repository -basePath $ProjectPath -projectName $ProjectName
}