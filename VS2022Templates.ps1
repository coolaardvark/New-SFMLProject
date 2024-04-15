# All variables here need to be in the global scope to be visible in the file
# which 'soruces' this one

# Dam, this file uses guids in braces and I want to use string format on it, so 
# I've got to double escape the brances resulting in monstories like this {{{0}}}!
# Format Parameters are:-
# 0 = Project GUID
# 1 = Project name
# 2 = Solution GUID
$global:solutionFileTemplate = @"
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

# Format parameters are:-
# 0 = project GUID
# 1 = project base directory
# 2 = project name
$global:projectFileTemplate = @'
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|Win32">
      <Configuration>Debug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|Win32">
      <Configuration>Release</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Debug|x64">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|x64">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <VCProjectVersion>17.0</VCProjectVersion>
    <Keyword>Win32Proj</Keyword>
    <ProjectGuid>{{{0}}}</ProjectGuid>
    <RootNamespace>SFMLFirst</RootNamespace>
    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'" Label="Configuration">
    <ConfigurationType>Application</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <PlatformToolset>v143</PlatformToolset>
    <WholeProgramOptimization>true</WholeProgramOptimization>
    <CharacterSet>Unicode</CharacterSet>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Label="Shared">
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <AdditionalIncludeDirectories>{1}{2}\sfml\include;</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>{1}{2}\sfml\lib</AdditionalLibraryDirectories>
      <AdditionalDependencies>sfml-system-d.lib;sfml-graphics-d.lib;sfml-audio-d.lib;sfml-network-d.lib;sfml-window-d.lib</AdditionalDependencies>
    </Link>
    <PreLinkEvent>
      <Command>copy $(SolutionDir)sfml\bin\sfml-audio-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-graphics-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-network-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-system-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-window-d-2.dll $(OutDir)</Command>
    </PreLinkEvent>
    <PreLinkEvent>
      <Message>Copies needed sfml dll's to output</Message>
    </PreLinkEvent>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>WIN32;NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <AdditionalIncludeDirectories>{1}{2}\sfml\include;</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>D:\source\nonrepos\SFMLFirst\sfml\lib</AdditionalLibraryDirectories>
      <AdditionalDependencies>sfml-system.lib;sfml-graphics.lib;sfml-audio.lib;sfml-network.lib;sfml-window.lib</AdditionalDependencies>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <AdditionalIncludeDirectories>{1}{2}\sfml\include;{1}{2}\sfml\include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>{1}{2}\sfml\lib</AdditionalLibraryDirectories>
      <AdditionalDependencies>sfml-system-d.lib;sfml-graphics-d.lib;sfml-audio-d.lib;sfml-network-d.lib;sfml-window-d.lib</AdditionalDependencies>
    </Link>
    <PreLinkEvent>
      <Command>copy $(SolutionDir)sfml\bin\sfml-audio-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-graphics-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-network-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-system-d-2.dll $(OutDir)
copy $(SolutionDir)sfml\bin\sfml-window-d-2.dll $(OutDir)</Command>
    </PreLinkEvent>
    <PreLinkEvent>
      <Message>Copies needed sfml dll's to output</Message>
    </PreLinkEvent>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <AdditionalIncludeDirectories>{1}{2}\sfml\include;{1}{2}\sfml\include;</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>{1}{2}\sfml\lib</AdditionalLibraryDirectories>
      <AdditionalDependencies>sfml-system.lib;sfml-graphics.lib;sfml-audio.lib;sfml-network.lib;sfml-window.lib</AdditionalDependencies>
    </Link>
  </ItemDefinitionGroup>
  <ItemGroup>
    <ClCompile Include="main.cpp" />
  </ItemGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>
'@

# Again, the choice of braces casues a problem here, C code it going to be
# littered with the dam things, each one needs escaping! Thankfully not to
# many in this simple example
$global:sourceFileTemplate = @'
#include <SFML/Graphics.hpp>

int main()
{{
    sf::RenderWindow window(sf::VideoMode(200, 200), "{0} works");
    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    while (window.isOpen())
    {{
        sf::Event event;
        while (window.pollEvent(event))
        {{
            if (event.type == sf::Event::Closed)
            {{
                window.close();
            }}
        }}

        window.clear();
        window.draw(shape);
        window.display();
    }}

    return 0;
}}
'@