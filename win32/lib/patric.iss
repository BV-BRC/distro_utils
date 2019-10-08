#include "defs"
#define EnvSetup "{app}/SetPATRICEnv.cmd"

[Setup]
AppName={#app_name}
AppVerName={#app_name} (release {#release})
AppPublisher=University of Chicago and Fellowship for Interpretation of Genomes
DefaultDirName={pf}\{#app_dir}
DefaultGroupName={#app_dir}
LicenseFile=
;LicenseFile=LICENSE.TXT
OutputDir=installer
OutputBaseFilename={#app_name}-{#release}
Compression=lzma
SolidCompression=yes
PrivilegesRequired=none
ArchitecturesInstallIn64BitMode=x64
DisableDirPage=yes

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: quicklaunch; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked


[Icons]
Name: "{group}\PATRIC Command Line "; Filename: {cmd}; Parameters: "\E:ON /V:ON /K ""{#EnvSetup}"""; WorkingDir: {userdocs} 
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\PATRIC Command Line"; Filename: {cmd}; Parameters: "\E:ON /V:ON /K ""{#EnvSetup}"""; WorkingDir: {userdocs}; Tasks: "quicklaunch"
Name: "{commondesktop}\PATRIC Command Line"; Filename: {cmd}; Parameters: "/E:ON /V:ON /K ""{#EnvSetup}"""; WorkingDir: {userdocs}; Comment: "Start a command shell to use the server tools"; Tasks: "desktopicon"
Name: "{group}\PATRIC Home"; Filename: "{app}\patric.url"
Name: "{group}\PATRIC Command Line Tutorial"; Filename: "{app}\patric_cli_tutorial.url"
Name: "{group}\Uninstall PATRIC Command Line"; Filename: {uninstallexe}

//[Components]
//Name: gnuwin32; Description: "GnuWin32 text processing utilities"; Types: full custom

[Files]

Source: {#RuntimeDir}\*; DestDir: {app}\runtime; Flags: ignoreversion recursesubdirs
Source: {#DistroDir}\urls\*; DestDir: {app}; Flags: ignoreversion
Source: {#DeployDir}\lib\*; DestDir: {app}\cli\lib; Flags: ignoreversion recursesubdirs
Source: {#DeployDir}\plbin\*; DestDir: {app}\cli\plbin; Flags: ignoreversion

[Dirs]
Name: {app}\cli\lib; Flags: uninsalwaysuninstall
Name: {app}\cli\bin; Flags: uninsalwaysuninstall
Name: {app}\cli\plbin; Flags: uninsalwaysuninstall
Name: {app}\runtime; Flags: uninsalwaysuninstall
Name: {app}; Flags: uninsalwaysuninstall


[Run]


[Code]

procedure MakeBatchStartup;
var
  path: String;
begin

  path := ExpandConstant('{#EnvSetup}');
  SaveStringToFile(path, '@ECHO OFF' + #13 + #10, false);
  SaveStringToFile(path, 'set KB_TOP=' + GetShortName(ExpandConstant('{app}')) + '\cli' + #13 + #10, true);
  SaveStringToFile(path, 'set KB_RUNTIME=' + GetShortName(ExpandConstant('{app}')) + '\runtime' + #13 + #10, true);
  SaveStringToFile(path, 'set PERL5LIB=' +  GetShortName(ExpandConstant('{app}')) + '\cli\lib' + #13 + #10, true);
  SaveStringToFile(path, 'PATH %KB_TOP%\bin;%KB_RUNTIME%\bin;%PATH%' + #13 + #10, true);
  SaveStringToFile(path, 'ECHO. ' + #13 + #10, true);
  SaveStringToFile(path, 'ECHO Welcome to the PATRIC runtime.' + #13 + #10, true);
  SaveStringToFile(path, 'ECHO See https://www.patricbrc.org/ for more information.' + #13 + #10, true);
  SaveStringToFile(path, 'ECHO. ' + #13 + #10, true);

end;

procedure MakeScriptWrapper(file :  String);
var
   cmd, cmdpath,bindir	:  String;
begin
   cmd := ChangeFileExt(file, '.cmd');
   bindir :=   ExpandConstant('{app}\cli\bin\');
   cmdpath := bindir + cmd;

   SaveStringToFile(cmdpath, '@echo off' + #13 + #10, false);
   SaveStringToFile(cmdpath, 'setlocal' + #13 + #10, true);
   SaveStringToFile(cmdpath, 'set KB_TOP=' + GetShortName(ExpandConstant('{app}')) + '\cli' + #13 + #10, true);
   SaveStringToFile(cmdpath, 'set KB_RUNTIME=' + GetShortName(ExpandConstant('{app}')) + '\runtime' + #13 + #10, true);
   SaveStringToFile(cmdpath, 'set PERL5LIB=' +  GetShortName(ExpandConstant('{app}')) + '\cli\lib' + #13 + #10, true);
   SaveStringToFile(cmdpath, 'PATH %KB_TOP%\bin;%KB_RUNTIME%\bin;%PATH%' + #13 + #10, true);
   SaveStringToFile(cmdpath, '%KB_RUNTIME%\bin\perl %KB_TOP%\plbin\' + file + ' %*' + #13 + #10, true);
   
end;

procedure MakeScriptWrappers;
var
   findRec : TFindRec;
   path	   :  STring;
begin

   path := ExpandConstant('{app}\cli\plbin\*.pl');
   if FindFirst(path, findRec) then begin
      try
      repeat
	 MakeScriptWrapper(findRec.Name);
      until not FindNext(findRec);
      finally
      FindClose(findRec);
       end;
   end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then begin
    MakeBatchStartup();
    MakeScriptWrappers();
  end;
end; { CurStepChanged }

procedure RemoveGeneratedData(dir : String; wildcard: String);
var
   findRec : TFindRec;
begin
   if FindFirst(dir + '\' + wildcard, findRec) then begin
      try
      repeat
	 DeleteFile(dir + '\' + findRec.Name);
      until not FindNext(findRec);
      finally
      FindClose(findRec);
   end;
   end;
end; { RemoveGeneratedData }


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then begin
     RemoveGeneratedData(ExpandConstant('{app}'), '*.cmd');
     RemoveGeneratedData(ExpandConstant('{app}\cli\bin'), '*.cmd');
  end;
end;
