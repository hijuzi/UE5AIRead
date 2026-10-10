@echo off
setlocal

REM ============================================================
REM  push-to-github.bat
REM  Stage ALL workspace changes, commit, and push to origin.
REM  Repo: git@github.com:hijuzi/UE5AIRead.git   Branch: main
REM
REM  Usage:
REM    double-click              - auto commit message (timestamp)
REM    push-to-github.bat "msg"  - custom commit message
REM
REM  Notes:
REM  - ASCII-only on purpose: cmd.exe on Chinese Windows defaults to
REM    code page 936; non-ASCII literals may display garbled and can
REM    even break quoting. Keep this file ASCII.
REM  - Set NOPAUSE=1 to skip the final "press any key" prompts
REM    (for automated runs).
REM ============================================================

cd /d "%~dp0"

echo === UE5AIRead : commit and push ===
echo.

REM --- 1. sanity checks ---------------------------------------
where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] git not found in PATH. Install Git for Windows first.
    goto :fail
)
if not exist ".git" (
    echo [ERROR] .git not found. Keep this script in the repo root.
    goto :fail
)
git remote get-url origin >nul 2>nul
if errorlevel 1 (
    echo [ERROR] remote "origin" is not configured. Example:
    echo         git remote add origin git@github.com:USER/REPO.git
    goto :fail
)

REM --- 2. show current changes --------------------------------
echo --- status (short) ---
git status --short
echo.

REM --- 3. stage everything ------------------------------------
git add -A
if errorlevel 1 goto :fail

REM --- 4. skip commit if nothing changed ----------------------
git diff --cached --quiet
if not errorlevel 1 (
    echo [SKIP] No new changes to commit.
    goto :push
)

REM --- 5. build commit message --------------------------------
set "MSG=%~1"
if not "%MSG%"=="" goto :havemsg
for /f "delims=" %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set "MSG=chore: sync workspace %%t"
if "%MSG%"=="" set "MSG=chore: sync workspace"
:havemsg

echo --- commit ---
git commit -m "%MSG%"
if errorlevel 1 goto :fail

REM --- 6. push -------------------------------------------------
:push
echo.
echo --- push to origin ---
git push -u origin HEAD
if errorlevel 1 (
    echo.
    echo [ERROR] push failed. Common causes:
    echo    1^) remote has newer commits - run "git pull --rebase" then retry
    echo    2^) SSH key for git@github.com is not configured on this machine
    goto :fail
)

echo.
echo [OK] Pushed to origin.
if not defined NOPAUSE pause
exit /b 0

:fail
echo.
echo [FAILED] Nothing was pushed. Read the messages above.
if not defined NOPAUSE pause
exit /b 1
