param($configuration = "Debug", $includeSymbols = $false, $runtimePath)

$sdkRoot = "artifacts\sdk"

.\build.ps1 $configuration

mkdir $sdkRoot -force | Out-Null

mkdir $sdkRoot\tools -force | Out-Null

cp scripts\* $sdkRoot\tools

# Fixup scripts
$scripts = ls $sdkRoot\tools -filter *.cmd

foreach($file in $scripts)
{
   $content = cat $file.FullName
   $content = $content | %{ $_.Replace("..\bin\Debug", "bin").Replace("..\src\", "").Replace("bin\Debug", "bin\$configuration") }
   Set-Content $file.FullName $content
}

# Move the bin folder in here
mkdir $sdkRoot\tools\bin -force | Out-Null
cp bin\$configuration\* $sdkRoot\tools\bin\

if(!$includeSymbols)
{
    # Remove the stuff we don't need
    ls $sdkRoot\tools\bin\*.pdb | rm
    ls $sdkRoot\tools\bin\*.ilk | rm
    ls $sdkRoot\tools\bin\*.lib | rm
    ls $sdkRoot\tools\bin\*.exp | rm
}

# Now copy source
cp -r src\Microsoft.Net.ApplicationHost -filter *.dll $sdkRoot\tools -Force
cp -r src\Microsoft.Net.Project -filter *.dll $sdkRoot\tools -Force
cp -r src\Microsoft.Net.OwinHost -filter *.dll $sdkRoot\tools -Force
cp -r src\Microsoft.Net.Launch $sdkRoot\tools -Force
cp src\Microsoft.Net.Runtime\Executable.cs $sdkRoot\tools\Microsoft.Net.Launch -Force
rm $sdkRoot\tools\Microsoft.Net.Launch\.include

if(!$includeSymbols)
{
    # Remove the stuff we don't need
    ls -r $sdkRoot\tools\*obj | rm -r
    ls -r $sdkRoot\tools\*\bin\*\*.xml | rm
}

# Copy the runtime
if($runtimePath) 
{
    cp -r $runtimePath\* $sdkRoot -force
}

# NuGet pack
cp ProjectK.nuspec $sdkRoot
.nuget\NuGet.exe pack $sdkRoot\ProjectK.nuspec -o $sdkRoot -NoPackageAnalysis