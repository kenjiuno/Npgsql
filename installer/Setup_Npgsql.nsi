; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

!define APP "Npgsql"
!define VER "2.2.0.0"
!define PRIVER "KU20140827-8f70c8b7"
; KU20140725-a846e688

!define ASM1 "Npgsql, Version=2.2.0.0, Culture=neutral, PublicKeyToken=5d8b90d52f46fda7"
!define ASM3 "Mono.Security, Version=4.0.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756"

!define FAC "Npgsql.NpgsqlFactory, ${ASM1}"

; The name of the installer
Name "${APP} ${VER}"

; The file to write
OutFile "Setup_${APP}-${VER}-${PRIVER}.exe"

; The default installation directory
InstallDir "$APPDATA\${APP}"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

!include "LogicLib.nsh"

;--------------------------------

; Pages

Page license
Page directory
Page components
Page instfiles

LicenseData README.rtf

;--------------------------------

InstType "Install .NET4.5 ver"
InstType "Uninstall"

; The stuff to install
Section ""
  SetOutPath "$INSTDIR"
  
  File /x "*.vshost.*" "bin\Debug-net40\GACInstall.*"
  File /x "*.vshost.*" "bin\Debug-net40\GACRemove.*"
  File /x "*.vshost.*" "bin\Debug-net40\ModifyDbProviderFactories.*"
  
  SetOutPath "$INSTDIR\Npgsql-${VER}-net45"
  File                "Npgsql-${VER}-net45\*.dll"
  File                "Npgsql-${VER}-net45\NpgsqlDdexProvider.vsix"

SectionEnd

Section "Uninst NpgsqlDdexProvider"
  SectionIn 2

  StrCpy $1 "$INSTDIR\VSIXInstaller.exe"
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}

  ${If} ${FileExists} $1
    ExecWait '"$1" /u:958b9481-2712-4670-9a62-8fe65e5beea7' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd

Section "Uninst Npgsql.dll from GAC"
  SectionIn 2

  SetOutPath "$INSTDIR"

  ExecWait '"$INSTDIR\GACRemove.exe" "${ASM1}"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "Uninst Mono.Security.dll from GAC"
  SectionIn 2

  SetOutPath "$INSTDIR"

  ExecWait '"$INSTDIR\GACRemove.exe" "${ASM3}"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "Uninst Npgsql DbProviderFactory from machine.config"
  SectionIn 2
  
  SetOutPath "$INSTDIR"

  ${If} ${FileExists}                                            "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config"
    ExecWait '"$INSTDIR\ModifyDbProviderFactories.exe" "/remove" "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config" "Npgsql"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}

  ${If} ${FileExists}                                            "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"
    ExecWait '"$INSTDIR\ModifyDbProviderFactories.exe" "/remove" "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config" "Npgsql"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd


Section "Inst Npgsql.dll (.NET4.5) to GAC"
  SectionIn 1

  SetOutPath "$INSTDIR"

  ExecWait '"$INSTDIR\GACInstall.exe" "$INSTDIR\Npgsql-${VER}-net45\Npgsql.dll"' $0
  DetailPrint "RetCode: $0"
SectionEnd


Section "Inst Mono.Security.dll to GAC"
  SectionIn 1

  SetOutPath "$INSTDIR"

  ExecWait '"$INSTDIR\GACInstall.exe" "$INSTDIR\Npgsql-${VER}-net45\Mono.Security.dll"' $0
  DetailPrint "RetCode: $0"
SectionEnd

Section "Inst Npgsql DbProviderFactory to machine.config"
  SectionIn 1
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

Section "Inst NpgsqlDdexProvider"
  SectionIn 1

  StrCpy $1 "$INSTDIR\VSIXInstaller.exe"
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}
  ${IfNot} ${FileExists} $1
    StrCpy $0 ""
    ReadRegStr $0 HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\11.0" "InstallDir"
    StrCpy $1 "$0VSIXInstaller.exe"
  ${EndIf}

  ${If} ${FileExists} $1
    ExecWait '"$1" "$INSTDIR\Npgsql-${VER}-net45\NpgsqlDdexProvider.vsix"' $0
    DetailPrint "RetCode: $0"
  ${EndIf}
SectionEnd
