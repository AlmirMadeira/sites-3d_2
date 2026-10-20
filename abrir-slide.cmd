@echo off
setlocal
cd /d "%~dp0"
set "MIRA_URL=http://127.0.0.1:8138/index.html"

rem Se a porta ja estiver respondendo, reutiliza o servidor existente.
powershell -NoProfile -Command "$c = New-Object Net.Sockets.TcpClient; try { $c.Connect('127.0.0.1', 8138); $c.Close(); exit 0 } catch { $c.Close(); exit 1 }" >nul 2>nul
if not errorlevel 1 (
  echo O servidor ja esta ativo em http://127.0.0.1:8138
  start "" "%MIRA_URL%"
  exit /b 0
)

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js nao encontrado. Instale em https://nodejs.org e abra este arquivo de novo.
  pause
  exit /b 1
)

rem Abre o navegador somente depois que o novo servidor responder.
start "" /b powershell -NoProfile -WindowStyle Hidden -Command "$url = '%MIRA_URL%'; for ($i = 0; $i -lt 60; $i++) { try { $r = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 1; if ($r.StatusCode -eq 200) { Start-Process $url; exit 0 } } catch {}; Start-Sleep -Milliseconds 250 }; exit 1"

echo Iniciando a apresentacao 3D em http://127.0.0.1:8138
echo Esta janela e o servidor. Para encerrar a apresentacao, feche-a.
call npx --yes http-server . -p 8138 -c-1

echo.
echo O servidor foi encerrado ou nao conseguiu iniciar.
pause
exit /b 1
