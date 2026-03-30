REM =====================================================
REM    Synchronize uqam-site with ANNEX001
REM 
REM =====================================================

@c:
@cd "C:\Program Files (x86)\WinSCP"

REM -------------------------------
REM  
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_Backup2Database2026.log

start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_Backup2Database2026.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_Backup2Database2026.log"
