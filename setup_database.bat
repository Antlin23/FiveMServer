@echo off
echo FiveM Server Database Setup
echo ===========================
echo.

echo Please enter your MySQL root password:
set /p MYSQL_PASSWORD=

echo.
echo Setting up database...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p%MYSQL_PASSWORD% < database_setup.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Database setup completed successfully!
    echo.
    echo Next steps:
    echo 1. Update your server.cfg with the correct password
    echo 2. Add music files to resources/[gameplay]/dj-system/html/sounds/
    echo 3. Restart your FiveM server
    echo.
    pause
) else (
    echo.
    echo Database setup failed! Please check:
    echo - MySQL is running
    echo - Password is correct
    echo - Database 'fivem1' exists
    echo.
    pause
) 