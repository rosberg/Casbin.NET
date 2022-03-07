$buildId= $env:BUILD_BUILDID
$sourcesDirectory = $env:BUILD_SOURCESDIRECTORY

#$buildId= "12"
#$sourcesDirectory = ".\"

Write-Host "Using build Id = $($buildId)"

# Find all the csproj files

if ($sourcesDirectory -eq $null) {
    Write-Error ("BUILD_SOURCESDIRECTORY environment variable is missing.")
    exit 1
}

# This code snippet gets all the files in $Path that end in ".csproj" and any subdirectories.
Get-ChildItem -Path $sourcesDirectory -Filter "*.csproj" -Recurse -File | 
    ForEach-Object { 

        $projectPath = $_.FullName

        Write-Host "Processing file: $($projectPath)"    
       
        $project = Select-Xml $projectPath -XPath "//Project"
        
        $version = $project.Node.SelectSingleNode("PropertyGroup/Version")

        if ($version -eq $null) {
            Write-Host "<Version> element missing!!"
        }       
        else{
        
            $mmpb = $version.InnerText.split(".")
            
            $newVersion = $mmpb[0] + "." + $mmpb[1] + "." + $mmpb[2] + "." + $BuildId
            Write-Host "Udating version element"
            $version.InnerText = $newVersion
            $version.OwnerDocument.Save($projectPath)
            Write-Host "Updated to version $($newVersion) for $($projectPath)"
        }
    }
