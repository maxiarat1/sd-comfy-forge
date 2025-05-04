<#
  Interactive deployment script for SD-Comfy-Forge stack.
  Lets you start/stop ComfyUI, Forge WebUI, and File Browser containers.
#>

function Show-Menu {
    Write-Host ""
    Write-Host "==== SD-Comfy-Forge Deployment Menu ===="
    Write-Host "1. Start ComfyUI"
    Write-Host "2. Stop ComfyUI"
    Write-Host "3. Start Forge WebUI"
    Write-Host "4. Stop Forge WebUI"
    Write-Host "5. Start File Browser"
    Write-Host "6. Stop File Browser"
    Write-Host "7. Status"
    Write-Host "8. Exit"
    Write-Host ""
}

function Test-Running($containerName) {
    $status = docker ps --filter "name=$containerName" --filter "status=running" -q
    return -not [string]::IsNullOrEmpty($status)
}

function Test-ImageExists($imageName) {
    $img = docker images -q $imageName
    return -not [string]::IsNullOrEmpty($img)
}

function Start-Service($path, $desc, $containerName, $imageName) {
    if (Test-Running $containerName) {
        Write-Host "`n⚠️  $desc is already running."
        return
    }
    if (-not (Test-ImageExists $imageName)) {
        Write-Host "`n❌ Docker image '$imageName' not found."
        $dockerfile = Join-Path $path "Dockerfile"
        $hasDockerfile = Test-Path $dockerfile
        if ($hasDockerfile) {
            $build = Read-Host "Do you want to build the image now? (y/n)"
            if ($build -eq "y" -or $build -eq "Y") {
                Write-Host "`n🔨 Building image '$imageName' in $path ..."
                Push-Location $path
                docker-compose build
                Pop-Location
                if (-not (Test-ImageExists $imageName)) {
                    Write-Host "`n❌ Build failed or image still not found."
                    $create = Read-Host "Do you want to create a new image with 'docker build .'? (y/n)"
                    if ($create -eq "y" -or $create -eq "Y") {
                        Push-Location $path
                        docker build -t $imageName .
                        Pop-Location
                        if (-not (Test-ImageExists $imageName)) {
                            Write-Host "`n❌ Image creation failed."
                            return
                        }
                        Write-Host "`n✅ Image created."
                    } else {
                        Write-Host "Skipping start of $desc."
                        return
                    }
                } else {
                    Write-Host "`n✅ Build complete."
                }
            } else {
                Write-Host "Skipping start of $desc."
                return
            }
        } else {
            # No Dockerfile, so offer to pull from registry
            $pull = Read-Host "No Dockerfile found. Pull image '$imageName' from Docker Hub? (y/n)"
            if ($pull -eq "y" -or $pull -eq "Y") {
                Write-Host "`n⬇️  Pulling image '$imageName'..."
                docker pull $imageName
                if (-not (Test-ImageExists $imageName)) {
                    Write-Host "`n❌ Pull failed or image still not found."
                    return
                }
                Write-Host "`n✅ Image pulled."
            } else {
                Write-Host "Skipping start of $desc."
                return
            }
        }
    }
    Write-Host "`n🟢 Starting $desc..."
    Push-Location $path
    docker-compose up -d
    Pop-Location
}

function Stop-Service($path, $desc, $containerName) {
    if (-not (Test-Running $containerName)) {
        Write-Host "`n⚠️  $desc is not running."
        return
    }
    Write-Host "`n🛑 Stopping $desc..."
    Push-Location $path
    docker-compose down
    Pop-Location
}

function Show-Status {
    Write-Host "`n==== Docker Container Status ===="
    docker ps --filter "name=sd-comfyui" --filter "name=sd-forge" --filter "name=sd-filebrowser"
}

do {
    Show-Menu
    $choice = Read-Host "Select an option (1-8)"
    switch ($choice) {
        "1" { Start-Service ".\comfyui" "ComfyUI" "sd-comfyui" "sd-cu128-comfyui" }
        "2" { Stop-Service ".\comfyui" "ComfyUI" "sd-comfyui" }
        "3" { Start-Service ".\webui-forge" "Forge WebUI" "sd-forge" "sd-cu128-forge" }
        "4" { Stop-Service ".\webui-forge" "Forge WebUI" "sd-forge" }
        "5" { 
            $enable = Read-Host "Do you want to enable File Browser? (y/n)"
            if ($enable -eq "y" -or $enable -eq "Y") {
                Start-Service ".\filebrowser" "File Browser" "sd-filebrowser" "filebrowser/filebrowser"
                Write-Host "`nFile Browser is hosted at http://localhost:8080/filebrowser"
            } else {
                Write-Host "File Browser not started."
            }
        }
        "6" { Stop-Service ".\filebrowser" "File Browser" "sd-filebrowser" }
        "7" { Show-Status }
        "8" { Write-Host "Exiting..."; exit }
        default { Write-Host "Invalid option. Please select 1-8." }
    }
} 
while ($true)