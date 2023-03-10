unit unitImage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfrmImage = class(TForm)
    edOldLink: TLabeledEdit;
    edNewLink: TLabeledEdit;
    edAlt: TLabeledEdit;
    cbCaption: TCheckBox;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImage: TfrmImage;

implementation

{$R *.dfm}

end.
