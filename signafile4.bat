:: This batch script will digitally sign the filename referenced by the deliberately misspelled verisign "timstamp.dll".  Take notice of the spell error, this prevents us from getting the error message we can expect, since
:: we issue as an individual who is not a part of the chained trustees, it would otherwise prevent us from being able to sign it at all. Now it will sign the referenced file and add a notification
:: we were unable to reach the server, but we did sign the file. If we would attempt to get through the verification like this, we would ofcourse fail and the server will notice our attempt and consequently send us back
:: to where we came from, starting point zero. in this case however, microsoft will notice our efford to sign a file and won't leave us entirely empty handed.
:: It will only show a warning but not an error.
::
:: Windows will still treat our file as being unsigned, until we complete all steps successfully. For now however it was my goal to make signing a file easier to do and understand.
:: The last step necessary to sign the file and succesfully verify it just falls beyond the scope of my post since I'm not a professional
:: or commercial coder.
:: You will be needing some files shipped with Windows SDK, I failed to find all necessary files so I modified the approach by using an already present binary and it worked.
:: Officially you need makecert, cert2spc, capicorn.dll and pvkimprt. The Windows 10 Signing Tools x86 will help you get about all files, except for the capicorn.dll. Using the pvk2pfx was
:: my idea, to bypass the other missing binary.
:: 
:: Run this batch script as an Administrator, from the same directory in which the binaries reside and the targetfile. All required files, which are passed as parameters during the execution
:: will be created by the script itself. It will pop up a password box, just make sure you enter the same password. Presumed you dont alter anything, Pass will literally be the password you
:: are using during the project. Default = Pass. Change if you like to avoid some prompts.
:: 
:: Example: you start with empty directory then copy the filetosign.exe and the above mentioned binaries with it.
:: In your directory you now have makecert.exe, cert2spc.exe pvk2pfx.exe, signtool.exe, capicorn.dll and last your filetosign.exe.
:: 
:: After completing the execution, you will find certificatefile.cer, privatekeyfile.pkv, certificatefile.spc, privatekeyfile.pfx and your signed filetosign.exe in addittion to the other already
:: present binaries.
:: 
:: Start of code 
::
:: Pass = Pass :: Set to emit some prompts
@ECHO OFF

:RequiredfilesPresent
:: Check whether the required binaries are present, oterwise we can't start
if exist "makecert.exe" if exist "cert2spc.exe" if exist "pvk2pfx.exe"  if exist "signtool.exe"  if exist "capicom.dll" GOTO :IsDirEmpty
ECHO."A required file is missing, cannot continue" 
pause 
EXIT



:IsDirEmpty
ECHO."All Required files are present, continue execution"
:: To avoid problems make sure that the files we are about the create aren't yet present.
if not exist "CertificateFile.cer"  if not exist "CertificateFile.pkv"  if not exist "CertificateFile.spc"  if not exist "PrivateKeyFile.pfx" GOTO :trySign
ECHO. "Directory is not empty.Delete previously created signing files and try again, cannot continue" 
Pause 
EXIT


:trySign
ECHO."Directory is clean, continue execution"
:: Required files are present and none of the about to create files are present, let's go
makecert.exe CertificateFile.cer -r -n "CN= Public Domain " -$ individual -sv PrivateKeyFile.pkv -pe -eku 1.3.6.1.5.5.7.3.3
pause
:: succeeded unless it fails to create the files because they were already present or missing

cert2spc.exe CertificateFile.cer CertificateFile.spc
pause
:: succeeded unless it fails to create the files because they were already present or missing

pvk2pfx -pvk PrivateKeyFile.pkv -pi Pass -spc CertificateFile.spc -pfx PrivateKeyFile.pfx  -f
pause
:: succeeded unless it fails to create the files because they were already present or missing

:: If you already provide the PrivateKeyFile.pkv, CertificateFile.spc, PrivateKeyFile.pfx and the 
:: CertificateFile.cer, you will only need the last portion of the code, starting with signtool.exe
:: Start here >>>.

signtool.exe sign /f PrivateKeyFile.pfx /p Pass /v /t http://timestamp.verisign.com/scripts/timstamp.dll %1
pause
:: succeeded followed bythe noticication it encountered a warning, but not an error.
:: unless it fails to create the files because they were already present or missing
:: By Peter de Biel 08-03-2024 01:38 hr
::
:: Added some file checking, some are mandatory, some should be avoided
:: By Peter de Biel 08-03-18:00 hr

:: ToDo: clean up the files that were created and are no longer needed
