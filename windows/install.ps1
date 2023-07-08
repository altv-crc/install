# Function to check if a command exists
function CommandExists($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check if MongoDB is installed
$connectionTest = Test-NetConnection -ComputerName "localhost" -Port 27017
if ($connectionTest.TcpTestSucceeded) {
    Write-Host "MongoDB is intalled."
} else {
    Write-Host "MongoDB may not be running or installed. Did you install it as a service?"
    Write-Host "Try downloading, and installing again."
    Write-Host "https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-6.0.7-signed.msi"
}

# Check if Node.js is installed
if (CommandExists('node')) {
    Write-Host "Node.js is installed."
} else {
    Write-Host "Node.js is not installed. Download it, and install it."
    Write-Host "https://nodejs.org/en/download"
    exit
}

# Check if Git is installed
if (CommandExists('git')) {
    Write-Host "Git is installed."
} else {
    Write-Host "GIT is not installed. Download it, and install it."
    Write-Host "https://git-scm.com/downloads"
    exit
}

# Specify the relative path where the repositories will be cloned
$corePath = "altv-crc-core"
$srcPath = "altv-crc-core/src"

# Create the full destination path based on the current directory
$currentDirectory = (Get-Location).Path
$coreDestinationPath = Join-Path -Path $currentDirectory -ChildPath $corePath
$srcDestinationPath = Join-Path -Path $currentDirectory -ChildPath $srcPath

# Clone core
git clone -q "https://github.com/altv-crc/altv-crc-core" $coreDestinationPath

Set-Location -Path $srcDestinationPath

Write-Host "Cloning repositories..."

$procs = $(
    Start-Process -FilePath "git" -NoNewWindow -ArgumentList "clone -q https://github.com/altv-crc/crc-instructional-buttons" -PassThru;
    Start-Process -FilePath "git" -NoNewWindow -ArgumentList "clone -q https://github.com/altv-crc/crc-native-menu" -PassThru;
    Start-Process -FilePath "git" -NoNewWindow -ArgumentList "clone -q https://github.com/altv-crc/crc-db" -PassThru;
    Start-Process -FilePath "git" -NoNewWindow -ArgumentList "clone -q https://github.com/altv-crc/crc-discord-login" -PassThru;
    Start-Process -FilePath "git" -NoNewWindow -ArgumentList "clone -q https://github.com/altv-crc/crc-select-character" -PassThru;
)

$procs | Wait-Process

Write-Host "Main repositories installed"

# Install
Set-Location -Path $coreDestinationPath
Start-Process -FilePath "npm" -NoNewWindow -ArgumentList "install" -Wait

$confirmation = Read-Host "Type 'y' if you want to start the server now"
if ($confirmation -eq 'y') {
    Start-Process -FilePath "npm" -NoNewWindow -ArgumentList "run windows"
}
