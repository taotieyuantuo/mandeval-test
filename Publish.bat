@echo off
setlocal

title Publish Website to GitHub Pages

cd /d "%~dp0"

echo ==========================================
echo   Publish Website to GitHub Pages
echo ==========================================
echo.

REM ------------------------------------------
REM 1. Check Git
REM ------------------------------------------
where git >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Git is not installed.
    echo.
    echo Please install Git for Windows first:
    echo https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo [OK] Git found.
echo.

REM ------------------------------------------
REM 2. Ask for repository URL
REM ------------------------------------------
set /p REPO_URL=Enter GitHub repository URL: 

if "%REPO_URL%"=="" (
    echo.
    echo [ERROR] Repository URL cannot be empty.
    pause
    exit /b 1
)

echo.
echo Repository:
echo %REPO_URL%
echo.

REM ------------------------------------------
REM 3. Initialize Git if necessary
REM ------------------------------------------
if not exist ".git" (
    echo [INFO] Initializing Git repository...
    git init

    if errorlevel 1 (
        echo [ERROR] git init failed.
        pause
        exit /b 1
    )
)

REM ------------------------------------------
REM 4. Set main branch
REM ------------------------------------------
git branch -M main

REM ------------------------------------------
REM 5. Configure remote
REM ------------------------------------------
git remote get-url origin >nul 2>&1

if errorlevel 1 (
    echo [INFO] Adding GitHub remote...
    git remote add origin "%REPO_URL%"
) else (
    echo [INFO] Updating GitHub remote...
    git remote set-url origin "%REPO_URL%"
)

if errorlevel 1 (
    echo [ERROR] Failed to configure GitHub remote.
    pause
    exit /b 1
)

REM ------------------------------------------
REM 6. Add files
REM ------------------------------------------
echo.
echo [INFO] Adding project files...
git add .

if errorlevel 1 (
    echo [ERROR] git add failed.
    pause
    exit /b 1
)

REM ------------------------------------------
REM 7. Check whether there is anything to commit
REM ------------------------------------------
git diff --cached --quiet

if errorlevel 1 (
    echo.
    echo [INFO] Changes detected.
    echo [INFO] Creating commit...

    git -c user.name="GitHub Publisher" ^
        -c user.email="publisher@localhost" ^
        commit -m "Publish website"

    if errorlevel 1 (
        echo.
        echo [ERROR] Commit failed.
        pause
        exit /b 1
    )
) else (
    echo.
    echo [INFO] No new changes to commit.
)

REM ------------------------------------------
REM 8. Push to GitHub
REM ------------------------------------------
echo.
echo [INFO] Pushing to GitHub...
echo [INFO] If this is your first push, a browser window may open.
echo.

git push -u --force origin main

if errorlevel 1 (
    echo.
    echo ==========================================
    echo [ERROR] Git push failed.
    echo ==========================================
    echo.
    echo Possible reasons:
    echo 1. You are not logged into the GitHub account.
    echo 2. You do not have write permission to this repository.
    echo 3. The remote repository already contains commits
    echo    that are not in this local project.
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   SUCCESS
echo ==========================================
echo.
echo The project has been pushed to GitHub.
echo GitHub Actions should now build and deploy
echo the website automatically.
echo.
pause

endlocal