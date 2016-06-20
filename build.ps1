Write-Host "Build number $buildNumber"

$nugetexe_path = Join-Path (Resolve-Path '.\') 'nuget.exe'

Write-Host "Clean packages"
. {
    if (Test-Path .\packages) {
        Remove-Item .\packages -Recurse -Force
    }
    if (Test-Path .\artifacts) {
        Remove-Item .\artifacts -Recurse -Force
    }
}

Write-Host "Downloading nuget.exe"
. {
    if (-not (Test-Path $nugetexe_path)) {
        # Invoke-WebRequest "http://nuget.org/nuget.exe" -OutFile $nugetexe_path
        Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetexe_path
    }
}

Write-Host "Restore solution packages"
. {
    & $nugetexe_path restore ".\packages.config" -OutputDirectory ".\packages" -DisableParallelProcessing
}

Write-Host "Creating artifacts"
. {
    if (-not (Test-Path .\artifacts)) {
        New-Item .\artifacts -ItemType directory
    }

    Copy-Item ".\packages\Microsoft.CodeAnalysis.Analyzers.*\analyzers\dotnet\cs\*.dll" .\artifacts\
    Copy-Item ".\packages\Microsoft.CodeAnalysis.Common.*\lib\net45\*.*" .\artifacts\
    Copy-Item ".\packages\Microsoft.CodeAnalysis.CSharp.*\lib\net45\*.*" .\artifacts\
    Copy-Item ".\packages\Microsoft.CodeAnalysis.Workspaces.Common.*\lib\net45\*.*" .\artifacts\
    Copy-Item ".\packages\System.Collections.Immutable.*\lib\*net45*\*.*" .\artifacts\
    Copy-Item ".\packages\System.Reflection.Metadata.*\lib\*net45*\*.*" .\artifacts\
}

Write-Host "Create package"
. {
    & $nugetexe_path pack .\roslyn.nuspec -o .\artifacts -version 1.0.0
}