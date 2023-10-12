unit portscan_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process, Graphics;

type
  PortScan = class(TThread)
  private

    { Private declarations }
  protected
  var
    ResultStr: TStringList;

    procedure Execute; override;
    procedure ShowStatus;

  end;

implementation

uses unit1;

{ TRD }

procedure PortScan.Execute;
var
  ScanProcess: TProcess;
begin
  FreeOnTerminate := True; //Уничтожать по завершении

  while not Terminated do
    try
      ResultStr := TStringList.Create;

      ScanProcess := TProcess.Create(nil);

      ScanProcess.Executable := 'bash';
      ScanProcess.Parameters.Add('-c');
      ScanProcess.Options := [poUsePipes, poWaitOnExit];

      ScanProcess.Parameters.Add(
        'if [[ $(ss -ltn | grep ' + MainForm.PortEdit.Text +
        ') && $(pidof xray) ]]; then echo "yes"; else echo "no"; fi');

      ScanProcess.Execute;

      ResultStr.LoadFromStream(ScanProcess.Output);
      Synchronize(@ShowStatus);

      Sleep(1000);
    finally
      ResultStr.Free;
      ScanProcess.Free;
    end;
end;

//Отображение статуса
procedure PortScan.ShowStatus;
begin
  with MainForm do
  begin
    if ResultStr[0] = 'yes' then
    begin
      Shape1.Brush.Color := clLime;
      PortEdit.Enabled := False;
      LoadItem.Enabled := False;
    end
    else
    begin
      Shape1.Brush.Color := clYellow;
      if ConfigBox.Count <> 0 then
        PortEdit.Enabled := True;
      LoadItem.Enabled := True;
    end;

    Shape1.Repaint;
  end;
end;

end.
