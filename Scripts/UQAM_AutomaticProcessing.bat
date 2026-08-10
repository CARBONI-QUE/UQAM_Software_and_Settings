REM =====================================================
REM    Download data and process all UQAM sites
REM 
REM - Start all WinSCP transfers (space them out 10s)
REM - Wait 2 minutes for all transfers to complete (fingers crossed)
REM - Start Matlab data processing for all the sites
REM =====================================================

@c:
@cd "C:\Program Files (x86)\WinSCP"

REM -------------------------------
REM  UQAM_1
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_1_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_1_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_1_SmartFlux_download.log"
timeout 10 > nul

REM -------------------------------
REM  UQAM_2
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_2_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_2_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_2_SmartFlux_download.log"
timeout 10 > nul

REM -------------------------------
REM  UQAM_3
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_3_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_3_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_3_SmartFlux_download.log"
timeout 10 > nul

REM -------------------------------
REM  UQAM_4
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_4_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_4_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_4_SmartFlux_download.log"
timeout 10 > nul

REM -------------------------------
REM  UQAM_5
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_5_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_5_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_5_SmartFlux_download.log"
timeout 10 > nul

REM -------------------------------
REM  MCGILL_1
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\MCGILL_1_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\MCGILL_1_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\MCGILL_1_SmartFlux_download.log"
timeout 10 > nul

REM ---------------------------------------------
REM  Data base processing and data upload to Web
REM ---------------------------------------------
REM -nodesktop -nosplash -minimize
@Date /t 
@Time /t 
"C:\Program Files\MATLAB\R2024a\bin\matlab.exe"  -noFigureWindows -batch "try; set_TAB_project('Z:\uqam-site\');run_TAB_db_update; catch ME; disp(ME);end; quit" > Z:\uqam-site\Scripts\Automatic_site_data_processing.log


exit