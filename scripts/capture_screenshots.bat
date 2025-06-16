@echo off
echo.
echo ========================================
echo 📸 CAPTURA DE SCREENSHOTS - PROJETO INFNET
echo ========================================
echo.

REM Criar pasta screenshots se não existir
if not exist "docs\screenshots" mkdir "docs\screenshots"

echo 🚀 Preparando ambiente...
echo.

REM Limpar e reconstruir projeto
echo 🧹 Limpando projeto...
call flutter clean
call flutter pub get

echo.
echo 📱 Iniciando aplicativo...
echo.

REM Executar aplicativo
start /B flutter run --release

echo.
echo ========================================
echo 📋 INSTRUÇÕES PARA CAPTURA
echo ========================================
echo.
echo 1. Aguarde o app carregar completamente
echo 2. Navegue pelas telas seguindo a ordem:
echo.
echo 🔐 AUTENTICAÇÃO:
echo    - Tela de Login (login.png)
echo    - Tela de Registro (register.png)  
echo    - Recuperação de Senha (reset.png)
echo.
echo 📋 TAREFAS:
echo    - Lista Principal (home.png)
echo    - Nova Tarefa (add_todo.png)
echo    - Detalhes da Tarefa (todo_details.png)
echo.
echo 👤 PERFIL:
echo    - Perfil do Usuário (profile.png)
echo    - Edição do Perfil (edit_profile.png)
echo    - Seleção de Localização (location.png)
echo.
echo 3. Para cada tela:
echo    - No emulador: clique no ícone de câmera
echo    - Salve como: docs\screenshots\[nome].png
echo.
echo 4. Após capturar todas, pressione qualquer tecla
echo.

pause

echo.
echo 📊 Verificando screenshots capturados...
echo.

REM Listar arquivos na pasta screenshots
dir "docs\screenshots\*.png" /B 2>nul
if errorlevel 1 (
    echo ❌ Nenhum screenshot encontrado!
    echo    Certifique-se de salvar as imagens em docs\screenshots\
) else (
    echo ✅ Screenshots encontrados!
)

echo.
echo 🔄 Deseja fazer commit das screenshots? (S/N)
set /p commit_choice=

if /i "%commit_choice%"=="S" (
    echo.
    echo 📤 Fazendo commit das screenshots...
    git add docs\screenshots\
    git commit -m "📸 Adicionar screenshots das principais telas do app"
    git push origin master
    echo ✅ Screenshots enviados para o GitHub!
) else (
    echo ℹ️  Screenshots salvos localmente. Faça commit manualmente quando estiver pronto.
)

echo.
echo ========================================
echo ✅ PROCESSO CONCLUÍDO!
echo ========================================
echo.
echo 📁 Screenshots salvos em: docs\screenshots\
echo 🌐 Repositório: https://github.com/jfsts/flutterinfnet
echo.

pause 