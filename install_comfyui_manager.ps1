# install_comfyui_manager.ps1
# Installs ComfyUI-Manager into the ComfyUI volume if not already present

Write-Host "`n🔍 Checking if ComfyUI-Manager is already installed..."

# Check if ComfyUI-Manager already exists in the volume
$managerExists = docker run --rm -v sd-comfyui:/opt/ComfyUI python:3.10-slim bash -c '[ -d "/opt/ComfyUI/custom_nodes/comfyui-manager" ] && echo "true" || echo "false"'

if ($managerExists -eq "true") {
    Write-Host "`n✅ ComfyUI-Manager is already installed!"
} else {
    Write-Host "`n📦 Installing ComfyUI-Manager..."
    
    # Create custom_nodes directory if it doesn't exist and clone the manager
    docker run --rm `
        -v sd-comfyui:/opt/ComfyUI `
        --entrypoint=/bin/sh `
        alpine/git -c 'mkdir -p /opt/ComfyUI/custom_nodes && cd /opt/ComfyUI/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager'
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ ComfyUI-Manager installed successfully!"
        Write-Host "`n⚠️  Please restart ComfyUI container for the changes to take effect."
        Write-Host "   You can do this by running: ./deploy.ps1 and selecting options 2 then 1"
    } else {
        Write-Host "`n❌ Failed to install ComfyUI-Manager. Please check your internet connection and try again."
    }
}
