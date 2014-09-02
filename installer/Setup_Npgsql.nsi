; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

!define APP "Npgsql"
!define TTL "Npgsql - .Net Data Provider for Postgresql"
!define COM "The Npgsql Development Team"
!define VER "2.2.0.0"
!define PRIVER "Final-Release"
; KU20140829-8f70c8b7
; KU20140725-a846e688

!define ASM1 "Npgsql, Version=2.2.0.0, Culture=neutral, PublicKeyToken=5d8b90d52f46fda7"
!define ASM3 "Mono.Security, Version=4.0.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756"

!define FAC "Npgsql.NpgsqlFactory, ${ASM1}"

; The name of the installer
Name "${APP} ${VER}"

; The file to write
OutFile "Setup_${APP}-${VER}-${PRIVER}.exe"

; The default installation directory
InstallDir "$PROGRAMFILES\${COM}\${APP}"

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\${COM}\${APP}" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

!include "LogicLib.nsh"

;--------------------------------

; Pages

Page license
Page directory
Page components
Page instfiles

UninstPage uninstConfirm
UninstPage components
UninstPage instfiles

LicenseData README.rtf

;--------------------------------

; The stuff to install
Section ""
  SetOutPath "$INSTDIR"
  
  File /x "*.vshost.*" "bin\Debug-net40\GACInstall.*"
  File /x "*.vshost.*" "bin\Debug-net40\GACRemove.*"
  File /x "*.vshost.*" "bin\Debug-net40\ModifyDbProviderFactories.*"
  
  SetOutPath "$INSTDIR\Npgsql-${VER}-net45"
  File                "Npgsql-${VER}-net45\*.dll"
  File                "Npgsql-${VER}-net45\NpgsqlDdexProvider.vsix" ;Vs2012/Vs2013

  SetOutPath "$INSTDIR\Npgsql-${VER}-net40"
  File                "Npgsql-${VER}-net40\NpgsqlDdexProvider.vsix" ;Vs2010

SectionEnd

Section "Npgsql.dll (.NET4.5) to GAC"
  SetOutPath "$INSTDIR"

  ExecWait '"$INSTDIR\GACInstall.exe" "$INSTDIR\Npgsql-${VER}-net45\Npgsql.dll"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "Mono.Security.dll to GAC"
  SetOutPath "$INSTDIR"

  ExecWait '"$INSTDIR\GACInstall.exe" "$INSTDIR\Npgsql-${VER}-net45\Mono.Security.dll"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "Npgsql DbProviderFactory to machine.config"
  SetOutPath "$INSTDIR"

  ${If} ${FileExists} "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config"
    StrCpy $0 '"$INSTDIR\ModifyDbProviderFactories.exe"'
    StrCpy $0 '$0 "/add-or-replace"'
    StrCpy $0 '$0 "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config"'
    StrCpy $0 '$0 "Npgsql Data Provider"'
    StrCpy $0 '$0 "Npgsql"'
    StrCpy $0 '$0 ".Net Data Provider for PostgreSQL"'
    StrCpy $0 '$0 "${FAC}"'
    StrCpy $0 '$0 "support"'
    StrCpy $0 '$0 "FF"'

    ExecWait '$0' $1
    DetailPrint "RetCode: $1"
  ${EndIf}

  ${If} ${FileExists} "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"
    StrCpy $0 '"$INSTDIR\ModifyDbProviderFactories.exe"'
    StrCpy $0 '$0 "/add-or-replace"'
    StrCpy $0 '$0 "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"'
    StrCpy $0 '$0 "Npgsql Data Provider"'
    StrCpy $0 '$0 "Npgsql"'
    StrCpy $0 '$0 ".Net Data Provider for PostgreSQL"'
    StrCpy $0 '$0 "${FAC}"'
    StrCpy $0 '$0 "support"'
    StrCpy $0 '$0 "FF"'

    ExecWait '$0' $1
    DetailPrint "RetCode: $1"
  ${EndIF}
SectionEnd

Section "NpgsqlDdexProvider(Vs2012/Vs2013)"
  SetOutPath "$INSTDIR"

  StrCpy $1 "$INSTDIR\VSIXInstaller.exe"
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\12.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\11.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}

  ${If} ${FileExists} $1
    ExecWait '"$1" "$INSTDIR\Npgsql-${VER}-net45\NpgsqlDdexProvider.vsix"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd

Section "NpgsqlDdexProvider(Vs2010)"
  SetOutPath "$INSTDIR"

  StrCpy $1 "$INSTDIR\VSIXInstaller.exe"
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\10.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}

  ${If} ${FileExists} $1
    ExecWait '"$1" "$INSTDIR\Npgsql-${VER}-net40\NpgsqlDdexProvider.vsix"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd

Section ""
  SetOutPath "$INSTDIR"

  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\${COM}\${APP}" "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${TTL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "un.NpgsqlDdexProvider(Vs2012/Vs2013)"
  StrCpy $1 "$INSTDIR\VSIXInstaller.exe"
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\12.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\11.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}

  ${If} ${FileExists} $1
    ExecWait '"$1" /u:958b9481-2712-4670-9a62-8fe65e5beea7' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd

Section "un.NpgsqlDdexProvider(Vs2010)"
  StrCpy $1 "$INSTDIR\VSIXInstaller.exe"
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\10.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}

  ${If} ${FileExists} $1
    ExecWait '"$1" /u:958b9481-2712-4670-9a62-8fe65e5beea7' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd

Section "un.Remove Npgsql.dll from GAC"
  ExecWait '"$INSTDIR\GACRemove.exe" "${ASM1}"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "un.Remove Mono.Security.dll from GAC"
  ExecWait '"$INSTDIR\GACRemove.exe" "${ASM3}"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "un.Remove Npgsql DbProviderFactory from machine.config"
  ${If} ${FileExists}                                            "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config"
    ExecWait '"$INSTDIR\ModifyDbProviderFactories.exe" "/remove" "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config" "Npgsql"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}

  ${If} ${FileExists}                                            "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"
    ExecWait '"$INSTDIR\ModifyDbProviderFactories.exe" "/remove" "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config" "Npgsql"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}

SectionEnd

Section "un."
  ; Remove files
  Delete "$INSTDIR\GACInstall.*"
  Delete "$INSTDIR\GACRemove.*"
  Delete "$INSTDIR\ModifyDbProviderFactories.*"
  
  Delete "$INSTDIR\Npgsql-${VER}-net45\*.dll"
  Delete "$INSTDIR\Npgsql-${VER}-net45\NpgsqlDdexProvider.vsix"
  RMDir  "$INSTDIR\Npgsql-${VER}-net45"

  Delete "$INSTDIR\Npgsql-${VER}-net40\NpgsqlDdexProvider.vsix"
  RMDir  "$INSTDIR\Npgsql-${VER}-net40"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
  DeleteRegKey HKLM "SOFTWARE\${COM}\${APP}"

  ; Remove uninstaller
  Delete "$INSTDIR\uninstall.exe"

  ; Remove directories used
  RMDir "$INSTDIR"
SectionEnd
