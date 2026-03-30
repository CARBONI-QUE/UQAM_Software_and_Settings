REM =====================================================
REM    Synchronize uqam-site with data.carbonique.ca
REM 
REM =====================================================

@c:
@cd "C:\Program Files (x86)\WinSCP"

REM -------------------------------
REM  
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_Backup2Sites.log

start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_Backup2Sites.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_Backup2Sites.log"
