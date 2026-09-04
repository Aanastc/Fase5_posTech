param (
    [string]$AccessKey,
    [string]$SecretKey,
    [string]$SessionToken
)

# Verifica se o GitHub CLI está instalado
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI (gh) não encontrado!" -ForegroundColor Red
    Write-Host "Instale rodando como administrador: winget install --id GitHub.cli" -ForegroundColor Yellow
    Write-Host "Depois de instalar, rode e siga os passos: gh auth login" -ForegroundColor Yellow
    exit 1
}

if (-not $AccessKey -or -not $SecretKey -or -not $SessionToken) {
    Write-Host "❌ Faltando parâmetros!" -ForegroundColor Red
    Write-Host "Uso correto:" -ForegroundColor Yellow
    Write-Host ".\update-github-secrets.ps1 -AccessKey 'sua_key' -SecretKey 'sua_secret' -SessionToken 'seu_token'"
    exit 1
}

Write-Host "🚀 Atualizando secrets no repositório GitHub..." -ForegroundColor Cyan

$AccessKey | gh secret set AWS_ACCESS_KEY_ID
$SecretKey | gh secret set AWS_SECRET_ACCESS_KEY
$SessionToken | gh secret set AWS_SESSION_TOKEN

Write-Host "✅ Secrets atualizados com sucesso no GitHub Actions!" -ForegroundColor Green
