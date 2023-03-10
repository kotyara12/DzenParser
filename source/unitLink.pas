unit unitLink;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfrmLink = class(TForm)
    edOldLink: TLabeledEdit;
    edNewLink: TLabeledEdit;
    edText: TLabeledEdit;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLink: TfrmLink;

implementation

{$R *.dfm}

end.
