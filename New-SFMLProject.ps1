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

# Pre-start checks
if (-not (Test-Path -Path $SFMLLibraryPath)) {
    throw "SFML library path $SFMLLibraryPath not found"
}

# Content template variables
# I wanted to have these in a seperate file that I 'include'
# but I can't figure out to do this with PowerShells scope rules

# Dam, this file uses guids in braces and I want to use string format on it, so 
# I've got to double escape the brances resulting in monstories like this {{{0}}}!
$solutionFileTemplate = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.9.34728.123
MinimumVisualStudioVersion = 10.0.40219.1
Project("{{{0}}}") = "{1}", "{1}\{1}.vcxproj", "{{{0}}}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|x64 = Debug|x64
		Debug|x86 = Debug|x86
		Release|x64 = Release|x64
		Release|x86 = Release|x86
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{{{0}}}.Debug|x64.ActiveCfg = Debug|x64
		{{{0}}}.Debug|x64.Build.0 = Debug|x64
		{{{0}}}.Debug|x86.ActiveCfg = Debug|Win32
		{{{0}}}.Debug|x86.Build.0 = Debug|Win32
		{{{0}}}.Release|x64.ActiveCfg = Release|x64
		{{{0}}}.Release|x64.Build.0 = Release|x64
		{{{0}}}.Release|x86.ActiveCfg = Release|Win32
		{{{0}}}.Release|x86.Build.0 = Release|Win32
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = {{{2}}}
	EndGlobalSection
EndGlobal
"@

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

    $projectGUID = New-Guid
    $solutionGUID = New-Guid

    $solutionFileContents = [string]::Format($solutionFileTemplate, $projectGUID, $projectName, $solutionGUID)

    $solutionFileContents | Out-File -FilePath $solutionFile
}

New-ProjectDirStructure -basePath $ProjectPath -projectName $ProjectName
New-SolutionAndProject -basePath $ProjectPath -projectName $ProjectName