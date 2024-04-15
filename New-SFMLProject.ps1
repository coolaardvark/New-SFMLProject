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

$gitExe = ''
if (Test-Path "${ENV:ProgramFiles}\Git\bin\git.exe") {
    $gitExe = "${ENV:ProgramFiles}\Git\bin\git.exe"
}
elseif (Test-Path "${ENV:LocalAppData}\Programs\Git\bin\git.exe") {
    $gitExe = "${ENV:LocalAppData}\Programs\Git\bin\git.exe"
}
else {
    $gitExe = 'not found'
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
    # copy the sub dirs and contents from our master copy
    Copy-Item -Path (Join-Path $SFMLLibraryPath "lib") -Destination $sfmlPath -Recurse
    Copy-Item -Path (Join-Path $SFMLLibraryPath "bin") -Destination $sfmlPath -Recurse
    Copy-Item -Path (Join-Path $SFMLLibraryPath "include") -Destination $sfmlPath -Recurse
}

function New-SolutionAndProject {
    param($basePath, $projectName)

    $solutionFile = Join-Path $basePath "${projectName}\${projectName}.sln"
    $projectFile = Join-Path $basePath "${projectName}\${projectName}\${projectName}.vcxproj"
    $sourceFile = Join-Path $basePath "${projectName}\${projectName}\main.cpp"

    $projectGUID = New-Guid
    $solutionGUID = New-Guid

    $solutionFileContents = [string]::Format($solutionFileTemplate, $projectGUID, $projectName, $solutionGUID)
    $solutionFileContents | Out-File -FilePath $solutionFile

    $projectFileContents = [string]::Format($projectFileTemplate, $projectGUID, $basePath, $projectName)
    $projectFileContents | Out-File -FilePath $projectFile

    # Create a source file so the project actually has something to build
    $sourceFileContents = [string]::Format($sourceFileTemplate, $projectName)
    $sourceFileContents | Out-File -FilePath $sourceFile
}

function New-Repository {
    param($basePath, $projectName)
}

if ($NoRepository -eq $false -and $gitExe -eq 'not found') {
    Write-Host "I can't find git.exe, if you still want to set up the solution pass the NoRepository switch to disable this or install git"
    return 1
}

New-ProjectDirStructure -basePath $ProjectPath -projectName $ProjectName
New-SolutionAndProject -basePath $ProjectPath -projectName $ProjectName

if ($NoRepository -eq $false) {
    New-Repository -basePath $ProjectPath -projectName $ProjectName
}