$url = "https://app.action1.com/agent/34cb3154-e7f9-11f0-b8e5-2d11c07677e4/Windows/agent(My_Organization).msi"
$output = "C:\Windows\Temp\action1_agent.msi"
$logFile = "C:\Windows\Temp\action1_install.log"

# 1. Forçar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = 3072

# 2. Download Robusto (Tenta Invoke-WebRequest, se falhar usa WebClient)
try {
    Write-Host "Baixando MSI..."
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
} catch {
    (New-Object System.Net.WebClient).DownloadFile($url, $output)
}

# 3. Verificação de Arquivo
if (!(Test-Path $output)) {
    Write-Host "✗ Erro: O arquivo MSI nao foi baixado." -ForegroundColor Red
    exit 1
}

# 4. Instalação com LOG (Fundamental para diagnóstico)
Write-Host "Instalando e gerando log em $logFile..."
$args = "/i `"$output`" /quiet /qn /norestart /L*V `"$logFile`""
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $args -Wait -PassThru

# 5. Verificação de Sucesso
if ($process.ExitCode -eq 0) {
    Write-Host "✓ Sucesso! O Agente foi instalado." -ForegroundColor Green
    Remove-Item $output -Force
} else {
    Write-Host "✗ Falha na instalacao. Codigo: $($process.ExitCode)" -ForegroundColor Red
    Write-Host "Verifique o log em: $logFile"
}