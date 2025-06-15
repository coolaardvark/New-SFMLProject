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
    the project. The directory should have both 32 and 64 bit versions of 
    the library in the x86 and x64 sub-directories respectively
    .PARAMETER Version
    The version of SFML that you want to build for, e.g 2.6.1 or 3.0.0. A
    directory with the matching version number must exist in the SFMMLibraryPath
    so if building for 3, then the SMFL-3.0.0 must exist. You just sepcify a major
    3 version in which case the script will select the latest minor version that it
    finds in the library path. Optional, if not provided the latest version found
    will be used
    .PARAMETER NoRepository
    Switch, if passed the script will not create a local git repository for
    the project
    .PARAMETER StaticLib
    Switch, if passed the exe is built using static, complied in, libraries
    to reduce the number of files you need to run it, at the expense of the
    size of the files
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = '',
    [Parameter(Mandatory=$false)]
    [string]$SFMLLibraryPath = '',
    [Parameter(Mandatory=$false)]
    [string]$Version = '',
    [Parameter(Mandatory=$false)]
    [switch]$NoRepository,
    [Parameter(Mandatory=$false)]
    [switch]$StaticLib
)

Set-StrictMode -Version Latest

$LibDirectory = ''
# Set defaults
if ($ProjectPath -eq '') {
    $ProjectPath = 'D:\source\repos\'
}
if ($SFMLLibraryPath -eq '') {
    $SFMLLibraryPath = 'D:\source\SFML\'
}

if ($Version -eq '') {
    $LibDirectory = (Get-ChildItem("$($SFMLLibraryPath)SFML-*") | Sort-Object | Select-Object -Last 1).FullName
    # Extract version number
    $Version = $LibDirectory.Substring($LibDirectory.Length -5)
}
else {
    if ($Version -match '\d+\.\d+\.\d+') {
        $LibDirectory = "$($SFMLLibraryPath)SFML-$Version"
    }
    elseif ($Version -match '\d+') {
        $LibDirectory = (Get-ChildItem("$($SFMLLibraryPath)SFML-$Version.0.0") | Sort-Object | Select-Object -Last 1).FullName
    }
}

# I have to do these two checks seperatley, if I used an -or both clauses
# would need to be evaulated meaning if $LibDirectory was null, we would
# get a null error while running Test-Path
if ($null -eq $LibDirectory) {
    throw "No SMFL-<version> directory found in $SFMLLibraryPath"
}
if (-not (Test-Path -Path $LibDirectory)) {
    throw  "No SMFL-$Version directory found in $SFMLLibraryPath"
}

$gitExe = Join-Path $ENV:ProgramFiles "Git\bin\git.exe"
if (-not (Test-Path $gitExe)) {
    $gitExe = Join-Path $ENV:LOCALAPPDATA "Programs\Git\bin\git.exe"

    if (-not (Test-Path $gitExe)) {
        $gitExe = 'not found'
    }
}

# We might not be run from the directory with our templates in
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
# Content template variables, loaded from external file to keep the
# code here, nice a clean
.(Join-Path $scriptPath 'VS2022Templates.ps1')

function New-Folder {
    param($path, $name)

    if ($null -eq (New-Item -Path $path -Name $name -ItemType Directory)) {
        throw "Failed to create directory $name in path $path"
    }
}

function Copy-Libraries {
    param($arcitecture, $solutionSFMLPath)

    $arcLibPath = Join-Path $LibDirectory $arcitecture
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
    param($basePath, $projectName, $version)

    $projectPath = Join-Path $basePath $projectName

    $projectGUID = New-Guid
    $solutionGUID = New-Guid

    # Version spesifc stuff
    $sampleFileTemplate = ''
    $cppLanguageVersion = ''
    switch ($version) {
        '2' { 
            $sampleFileTemplate = $sourceFileTemplateV2
            $cppLanguageVersion = '14' 
        }
        '3' { 
            $sampleFileTemplate = $sourceFileTemplateV3
            $cppLanguageVersion = '17'
        }
        Default { throw "Unsuported version! $version" }
    }

    $solutionFileContents = [string]::Format($global:solutionFileTemplate, $projectGUID, $projectName, $solutionGUID)
    $solutionFileContents | Out-File -FilePath (Join-Path $projectPath "${projectName}.sln")

    # Yes this is right, the project name appears twice in the path
    $sourcePath = Join-Path $projectPath $projectName

    $selectedProjectFileTemplate = ''
    if ($StaticLib) {
        $selectedProjectFileTemplate = $global:staticLibProjectFileTemplate
    }
    else {
        $selectedProjectFileTemplate = $global:projectFileTemplate
    }


    $projectFileContents = [string]::Format($selectedProjectFileTemplate, $projectGUID, $basePath, $projectName, $cppLanguageVersion)
    $projectFileContents | Out-File -FilePath (Join-Path $sourcePath "${projectName}.vcxproj")

    $global:vcxprojFiltersTemplate | Out-File -FilePath (Join-Path $sourcePath "${projectName}.vcxproj.filters")
    $global:vcxprojUserTemplate | Out-File -FilePath (Join-Path $sourcePath "${projectName}.vcxproj.user")

    # Create a source file so the project actually has something to build
    $sourceFileContents = [string]::Format($sampleFileTemplate, $projectName)
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
    Write-Host 'I can''t find git.exe, if you still want to set up the solution pass the NoRepository switch to disable this or install git'
    return 1
}

New-ProjectDirStructure -basePath $ProjectPath -projectName $ProjectName
# We only care about the first digit of our version here
New-SolutionAndProject -basePath $ProjectPath -projectName $ProjectName -version $Version.Substring(0, 1)

if (-not $NoRepository) {
    New-Repository -basePath $ProjectPath -projectName $ProjectName
}

Invoke-Item (Join-Path $ProjectPath $ProjectName "${ProjectName}.sln")