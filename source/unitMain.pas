unit unitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList, parser,
  Vcl.Menus, Vcl.Samples.Spin;

type
  TfrmMain = class(TForm)
    ToolBar: TToolBar;
    pnlEditors: TPanel;
    pnlStrum: TPanel;
    Splitter1: TSplitter;
    pgcEditors: TPageControl;
    tsSource: TTabSheet;
    tsOutput: TTabSheet;
    edSite: TRichEdit;
    ImageList: TImageList;
    ActionList: TActionList;
    actDzenOpen: TAction;
    btnPastle: TToolButton;
    tvDzen: TTreeView;
    tsDzenText: TTabSheet;
    edDzen: TRichEdit;
    lvImages: TListView;
    pnlImages: TPanel;
    vSplitter1: TSplitter;
    pnlLinks: TPanel;
    lvLinks: TListView;
    pnlOptions: TPanel;
    pmDzen: TPopupMenu;
    actDzenSelectAll: TAction;
    itemDzenSelectAll: TMenuItem;
    itemOpen: TMenuItem;
    divDzen1: TMenuItem;
    pmSite: TPopupMenu;
    actSizeSave: TAction;
    itemSizeSave: TMenuItem;
    actProcess: TAction;
    ToolButton1: TToolButton;
    btnProcess: TToolButton;
    ToolButton2: TToolButton;
    btnSizeSave: TToolButton;
    actSiteSelectAll: TAction;
    actSiteCopy: TAction;
    N1: TMenuItem;
    itemSiteCopy: TMenuItem;
    itemSiteSelectAll: TMenuItem;
    itemSiteToBuffer: TMenuItem;
    btnSiteToBuffer: TToolButton;
    actSiteToBuffer: TAction;
    cbAppendNpsb: TCheckBox;
    pmImages: TPopupMenu;
    actPastleImages: TAction;
    itemPastleImages: TMenuItem;
    cbImgCaption: TCheckBox;
    cbImgLimitSize: TCheckBox;
    edImgLimitSize: TSpinEdit;
    cbImageFrame: TCheckBox;
    actOpenImage: TAction;
    N2: TMenuItem;
    itemOpenImage: TMenuItem;
    procedure actDzenOpenExecute(Sender: TObject);
    procedure actDzenOpenUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actDzenSelectAllUpdate(Sender: TObject);
    procedure actDzenSelectAllExecute(Sender: TObject);
    procedure actSizeSaveUpdate(Sender: TObject);
    procedure actSizeSaveExecute(Sender: TObject);
    procedure actSiteSelectAllUpdate(Sender: TObject);
    procedure actSiteSelectAllExecute(Sender: TObject);
    procedure actSiteCopyUpdate(Sender: TObject);
    procedure actSiteCopyExecute(Sender: TObject);
    procedure actSiteToBufferUpdate(Sender: TObject);
    procedure actSiteToBufferExecute(Sender: TObject);
    procedure actProcessUpdate(Sender: TObject);
    procedure actProcessExecute(Sender: TObject);
    procedure actPastleImagesUpdate(Sender: TObject);
    procedure actPastleImagesExecute(Sender: TObject);
    procedure lvImagesDblClick(Sender: TObject);
    procedure actOpenImageUpdate(Sender: TObject);
    procedure actOpenImageExecute(Sender: TObject);
    procedure lvLinksDblClick(Sender: TObject);
  private
    fDomTree: TDomTree;
    procedure DrawTree(DTree: TDomTreeNode);
    procedure AddChildNode(ParentNode: TTreeNode; DTree: TDomTreeNode);
    procedure ProcessBuffer(const html: string; const dir: string);
    procedure FindLinks;
    procedure FindImages(const dir: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  StrUtils, Clipbrd, rSysUtils,
  rHttpUtils, rParse, rDialogs, rFrmStore, rStrUtils, rCsvUtils, rVclUtils,
  unitImage, unitLink;

const
  imText      = 3;
  imH2        = 4;
  imH3        = 5;
  imList      = 6;
  imLink      = 7;
  imImage     = 8;
  imCaption   = 9;
  imTextProp  = 10;
  imUnknown   = 11;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Font.Name := Screen.MenuFont.Name;
  rFrmStore.frmLoadFormPosition(Self, True, True);
  pnlStrum.Width := rFrmStore.frmLoadValueInt(Self, 'RightPanel.Width', pnlStrum.Width);
  rFrmStore.frmLoadListColumns(Self, lvImages, True);
  rFrmStore.frmLoadListColumns(Self, lvLinks, True);

  fDomTree := TDomTree.Create();
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  fDomTree.Free;

  rFrmStore.frmSaveFormPosition(Self);
  rFrmStore.frmSaveValueInt(Self, 'RightPanel.Width', pnlStrum.Width);
  rFrmStore.frmSaveListColumns(Self, lvImages, True);
  rFrmStore.frmSaveListColumns(Self, lvLinks, True);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  lvImages.Height := (pnlStrum.ClientHeight - pnlOptions.Height) div 2 - pnlImages.Height;
end;

procedure TfrmMain.DrawTree(DTree: TDomTreeNode);
var
  NewNode: TTreeNode;
  NodeCap: string;
  i: integer;
begin
  if DTree.Tag <> ''
  then NodeCap := DTree.GetTagName
  else NodeCap := DTree.Text;
  NewNode := tvDzen.Items.Add(nil, NodeCap);
  NewNode.Data := DTree;
  for i := 0 to DTree.Child.Count - 1 do
    AddChildNode(NewNode, DTree.Child.Items[i]);
end;

procedure TfrmMain.AddChildNode(ParentNode:TTreeNode; DTree: TDomTreeNode);
var
  NewNode: TTreeNode;
  i: integer;
begin
  if DTree.Tag <> '' then
  begin
    NewNode := tvDzen.Items.AddChild(ParentNode, DTree.GetTagName);
    if Pos('/', DTree.Tag) <> 1 then
    begin
      if Pos('p', DTree.Tag) = 1 then
        NewNode.ImageIndex := imText
      else if Pos('h2', DTree.Tag) = 1 then
        NewNode.ImageIndex := imH2
      else if Pos('h3', DTree.Tag) = 1 then
        NewNode.ImageIndex := imH3
      else if Pos('ul', DTree.Tag) = 1 then
        NewNode.ImageIndex := imList
      else if Pos('ol', DTree.Tag) = 1 then
        NewNode.ImageIndex := imList
      else if Pos('li', DTree.Tag) = 1 then
        NewNode.ImageIndex := imText
      else if Pos('a', DTree.Tag) = 1 then
        NewNode.ImageIndex := imLink
      else if Pos('figure', DTree.Tag) = 1 then
        NewNode.ImageIndex := imImage
      else if Pos('figcaption', DTree.Tag) = 1 then
        NewNode.ImageIndex := imCaption
      else if Pos('b', DTree.Tag) = 1 then
        NewNode.ImageIndex := imTextProp
      else if Pos('i', DTree.Tag) = 1 then
        NewNode.ImageIndex := imTextProp
      else if Pos('s', DTree.Tag) = 1 then
        NewNode.ImageIndex := imTextProp
      else if Pos('hr', DTree.Tag) = 1 then
        NewNode.ImageIndex := -1
      else
        NewNode.ImageIndex := imUnknown;
    end
    else NewNode.ImageIndex := -1;
  end
  else begin
    NewNode := tvDzen.Items.AddChild(ParentNode, DTree.Text);
    NewNode.ImageIndex := -1;
  end;
  NewNode.Data := DTree;
  NewNode.SelectedIndex := NewNode.ImageIndex;
  for i := 0 to DTree.Child.Count - 1 do
    AddChildNode(NewNode, DTree.Child.Items[i]);
end;

procedure TfrmMain.actDzenOpenUpdate(Sender: TObject);
begin
  actDzenOpen.Enabled := True;
end;

procedure TfrmMain.FindImages(const dir: string);
var
  nlList: TNodeList;
  sSrc, sTmp, sNew, sAlt, sExt: string;
  i, n: Integer;
begin
  lvImages.Items.BeginUpdate;
  nlList := TNodeList.Create;
  try
    lvImages.Items.Clear;
    fDomTree.RootNode.FindNode('img', 0, 'src="', True, nlList);
    n := 0;
    for i := 0 to nlList.Count - 1 do
    begin
      if nlList[i].Attributes.TryGetValue('src', sSrc) then
      begin
        sSrc := rCsv_ExtractQuotedStr(sSrc);
        if Copy(sSrc, 1, 2) = './' then
        begin
          sTmp := IncludeTrailingPathDelimiter(dir) +
            StringReplace(Copy(sSrc, 3, Length(sSrc) - 2), '/', '\', [rfReplaceAll, rfIgnoreCase]);
          if FileExists(sTmp) then
          begin
            n := n + 1;
            sExt := ExtractFileExt(sTmp);
            if sExt = '' then sExt := '.webp';
            sNew := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(sTmp))) + 'images\' + Format('image%.3d%s', [n, sExt]);
            ForceDirectories(ExtractFilePath(sNew));
            CopyFile(PWideChar(sTmp), PWideChar(sNew), False);
            if not FileExists(sNew) then
              sNew := sTmp;
          end;
        end
        else sNew := sSrc;

        sAlt := '';
        nlList[i].Attributes.TryGetValue('alt', sAlt);
        sAlt := rCsv_ExtractQuotedStr(sAlt);

        with lvImages.Items.Add do
        begin
          Caption := sNew;
          Subitems.Add(sSrc);
          Subitems.Add(sAlt);
        end;
      end;
    end;
  finally
    lvImages.Items.EndUpdate;
    nlList.Free;
  end;
end;

procedure TfrmMain.FindLinks();
var
  nlList: TNodeList;
  hRef, hOpt: string;
  i, j, n: Integer;
begin
  lvLinks.Items.BeginUpdate;
  nlList := TNodeList.Create;
  try
    lvLinks.Items.Clear;
    fDomTree.RootNode.FindNode('a', 0, '', True, nlList);
    for i := 0 to nlList.Count - 1 do
    begin
      if nlList[i].Attributes.TryGetValue('href', hRef) then
      begin
        hRef := rCsv_ExtractQuotedStr(hRef);
        // rCsv_ExtractQuotedStr(hRef);
        // rStrUtils.ExtractValueQuoted()

        n := -1;
        for j := 0 to lvLinks.Items.Count - 1 do
        begin
          if AnsiSameText(lvLinks.Items[j].Caption, hRef) then
          begin
            n := j;
            Break;
          end;
        end;

        if n = -1 then
        begin
          with lvLinks.Items.Add do
          begin
            Caption := hRef;
            Subitems.Add(hRef);
            Subitems.Add(nlList[i].GetTextRequsive);
          end;
        end;
      end;
    end;
  finally
    lvLinks.Items.EndUpdate;
    nlList.Free;
  end;
end;

procedure TfrmMain.ProcessBuffer(const html: string; const dir: string);
var
  sBuffer: string;
  i: Integer;

  procedure RemoveTags(const tagStart, tagEnd: string);
  var
    iStart, iEnd: Integer;
  begin
    repeat
      iStart := Pos(tagStart, sBuffer, 1);
      if iStart > 0 then
      begin
        iEnd := Pos(tagEnd, sBuffer, iStart + Length(tagStart));
        if iEnd > iStart then
          Delete(sBuffer, iStart, iEnd - iStart + Length(tagEnd))
        else
          raise Exception.CreateFmt('Не удалось найти пару идентификаторов: %s (%d), %s (%d)', [tagStart, iStart, tagEnd, iEnd]);
      end;
    until iStart = 0;
  end;

  procedure ReplaceImageCaptions();
  const
    tagStart = '<div class="article-image-caption article-image-caption_theme_white article-image-with-viewer__caption" aria-hidden="true">';
    tagEnd   = '</div>';
  var
    iStart, iEnd: Integer;
  begin
    repeat
      iStart := Pos(tagStart, sBuffer, 1);
      if iStart > 0 then
      begin
        iEnd := Pos(tagEnd, sBuffer, iStart + Length(tagStart));
        sBuffer := Copy(sBuffer, 1, iStart - 1)
          + '<img_caption>'
          + Copy(sBuffer, iStart + Length(tagStart), iEnd - iStart - Length(tagStart))
          + '</img_caption>'
          + Copy(sBuffer, iEnd + Length(tagEnd), Length(sBuffer));
      end;
    until iStart = 0;
  end;

begin
  StartWait;
  tvDzen.Items.BeginUpdate;
  edDzen.Lines.BeginUpdate;
  try
    tvDzen.Items.Clear;
    edDzen.Lines.Clear;

    // Лишние теги
    sBuffer := StringReplace(html, '<span>', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</span>', '', [rfReplaceAll, rfIgnoreCase]);

    // Обычный текст
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_unstyled"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_h2"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_h3"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_ul"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_ol"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_li"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-render__striked-text"', '', [rfReplaceAll, rfIgnoreCase]);
    // Цитаты
    sBuffer := StringReplace(sBuffer, ' class="article-render__block article-render__block_theme_white article-render__block_quote"', '', [rfReplaceAll, rfIgnoreCase]);
    // Ссылки
    sBuffer := StringReplace(sBuffer, ' class="article-link article-link_theme_undefined article-link_color_default"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="ui-lib-embed-view-base__link"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '?from_embed=true', '', [rfReplaceAll, rfIgnoreCase]);
    // Изображения
    sBuffer := StringReplace(sBuffer, ' class="article-image-item__image"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-image-item__image-item"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' class="article-image-item__image-capture"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' itemscope=""', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' itemprop="image"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' itemtype="http://schema.org/ImageObject"', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' style="background-color: rgb(255, 255, 255)', '', [rfReplaceAll, rfIgnoreCase]);
    // ReplaceImageCaptions();
    RemoveTags('<use', '/use>');
    RemoveTags('<svg', '/svg>');
    RemoveTags('<meta', '>');
    RemoveTags('<figcaption', '/figcaption>');
    RemoveTags('<div class="auto-height-transition-block__inner-block"', '</div>');
    RemoveTags('<div class="article-image-caption', '</div>');
    RemoveTags('<span class="ui-lib-embed-view-text__publish', '</div>');
    RemoveTags('<div', '>');
    sBuffer := StringReplace(sBuffer, '</div>', '', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, ' srcset=""', '', [rfReplaceAll, rfIgnoreCase]);
    // sBuffer := StringReplace(sBuffer, 'width="1200px"', 'width="1024px"', [rfReplaceAll, rfIgnoreCase]);
    // sBuffer := StringReplace(sBuffer, '<img width', '<img class="aligncenter" width', [rfReplaceAll, rfIgnoreCase]);

    // Data-points
    for i := 1 to 32 do
      sBuffer := StringReplace(sBuffer, Format(' data-points="%d"', [i]), '', [rfReplaceAll, rfIgnoreCase]);

    sBuffer := StringReplace(sBuffer, '<h2', #13#10'<hr/>'#13#10'<h2', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '<br>', '<br/>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '<figure', #13#10'<figure', [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</figure><p>', '</figure>'#13#10'<p>', [rfReplaceAll, rfIgnoreCase]);
    // sBuffer := StringReplace(sBuffer, '><figcaption', '>'#13#10'<figcaption', [rfReplaceAll, rfIgnoreCase]);
    // sBuffer := StringReplace(sBuffer, '</img_caption>', '</img_caption>'#13#10#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</p>', '</p>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</h2>', '</h2>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</h3>', '</h3>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '<ul>', '<ul>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '<ol>', '<ol>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</li>', '</li>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</ul>', '</ul>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    sBuffer := StringReplace(sBuffer, '</ol>', '</ol>'#13#10, [rfReplaceAll, rfIgnoreCase]);
    edDzen.Lines.Text := sBuffer;

    if fDomTree.RootNode.RunParse(sBuffer) then
    begin
      DrawTree(fDomTree.RootNode);

      FindImages(dir);
      FindLinks;
    end
    else ErrorBox('Ошибка парсинга!');
    tvDzen.FullExpand;
  finally
    edDzen.Lines.EndUpdate;
    tvDzen.Items.EndUpdate;
    StopWait;
  end;
end;

procedure TfrmMain.actDzenOpenExecute(Sender: TObject);
var
  sSourceFile: string;
  slBuffer: TStringList;
begin
  if PromptForFileName(sSourceFile, 'Web-files (*.html)|*.html') then
  begin
    slBuffer := TStringList.Create;
    try
      slBuffer.LoadFromFile(sSourceFile, TEncoding.UTF8);
      ProcessBuffer(Parse_GetValue(slBuffer.Text, '<div class="article-render" itemProp="articleBody">', '<div id="content-ending">'),
        ExtractFilePath(sSourceFile));
    finally
      slBuffer.Free;
    end;
  end;
end;

procedure TfrmMain.actDzenSelectAllUpdate(Sender: TObject);
begin
  actDzenSelectAll.Enabled := edDzen.Lines.Count > 0;
end;

procedure TfrmMain.actDzenSelectAllExecute(Sender: TObject);
begin
  edDzen.SelectAll;
end;

procedure TfrmMain.actSiteSelectAllUpdate(Sender: TObject);
begin
  actSiteSelectAll.Enabled := edSite.Lines.Count > 0;
end;

procedure TfrmMain.actSiteSelectAllExecute(Sender: TObject);
begin
  edSite.SelectAll;
end;

procedure TfrmMain.actSiteCopyUpdate(Sender: TObject);
begin
  actSiteCopy.Enabled := edSite.SelLength > 0;
end;

procedure TfrmMain.actSiteCopyExecute(Sender: TObject);
begin
  Clipboard.AsText := edSite.SelText;
end;

procedure TfrmMain.actSiteToBufferUpdate(Sender: TObject);
begin
  actSiteToBuffer.Enabled := edSite.Lines.Count > 0;
end;

procedure TfrmMain.actSiteToBufferExecute(Sender: TObject);
begin
  StartWait;
  try
    Clipboard.AsText := edSite.Text;
  finally
    StopWait;
  end;
end;

procedure TfrmMain.actSizeSaveUpdate(Sender: TObject);
begin
  actSizeSave.Enabled := edSite.Lines.Count > 0;
end;

procedure TfrmMain.actSizeSaveExecute(Sender: TObject);
var
  sTargetFile: string;
begin
  if PromptForFileName(sTargetFile, 'Web-files (*.html)|*.html') then
  begin
    StartWait;
    try
      edSite.Lines.SaveToFile(sTargetFile, TEncoding.UTF8);
    finally
      StopWait;
    end;
  end;
end;

procedure TfrmMain.actOpenImageUpdate(Sender: TObject);
begin
  actOpenImage.Enabled := Assigned(lvImages.Selected);
end;

procedure TfrmMain.actOpenImageExecute(Sender: TObject);
begin
  if Assigned(lvImages.Selected) then
    rSysUtils.OpenFile32('open', lvImages.Selected.Caption, '', SW_SHOWNORMAL, False, nil, 0);
end;

procedure TfrmMain.lvImagesDblClick(Sender: TObject);
begin
  if Assigned(lvImages.Selected) then
  begin
    with TfrmImage.Create(Self) do
    begin
      try
        edNewLink.Text := lvImages.Selected.Caption;
        edOldLink.Text := lvImages.Selected.SubItems[0];
        edAlt.Text := lvImages.Selected.SubItems[1];
        cbCaption.Checked := lvImages.Selected.Checked;
        if ShowModal = mrOk then
        begin
          lvImages.Selected.Caption := edNewLink.Text;
          lvImages.Selected.SubItems[0] := edOldLink.Text;
          lvImages.Selected.SubItems[1] := edAlt.Text;
          lvImages.Selected.Checked := cbCaption.Checked;
        end;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TfrmMain.lvLinksDblClick(Sender: TObject);
begin
  if Assigned(lvLinks.Selected) then
  begin
    with TfrmLink.Create(Self) do
    begin
      try
        edNewLink.Text := lvLinks.Selected.Caption;
        edOldLink.Text := lvLinks.Selected.SubItems[0];
        edText.Text := lvLinks.Selected.SubItems[1];
        if ShowModal = mrOk then
        begin
          lvLinks.Selected.Caption := edNewLink.Text;
          lvLinks.Selected.SubItems[0] := edOldLink.Text;
          lvLinks.Selected.SubItems[1] := edText.Text;
        end;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TfrmMain.actProcessUpdate(Sender: TObject);
begin
  actProcess.Enabled := edDzen.Lines.Count > 0;
end;

procedure TfrmMain.actProcessExecute(Sender: TObject);
var
  i, iImgS, iImgE, iImgWidth: Integer;
  tagSrcImage, tagTrgImage: string;
  sImgSrc, sImgAlt, sImgWidth, sImgCaption: string;
begin
  StartWait;
  edSite.Lines.BeginUpdate;
  try
    edSite.Text := edDzen.Text;

    (*
    for i := 0 to lvImages.Items.Count - 1 do
    begin
      if not SameText(lvImages.Items[i].Caption, lvImages.Items[i].Subitems[0]) then
      begin
        edSite.Text := StringReplace(edSite.Text,
            Format('src="%s"', [lvImages.Items[i].Subitems[0]]),
            Format('src="%s"', [lvImages.Items[i].Caption]),
          [rfReplaceAll, rfIgnoreCase]);
      end;
    end;
    *)

    // Замена ссылок
    for i := 0 to lvLinks.Items.Count - 1 do
    begin
      if not SameText(lvLinks.Items[i].Caption, lvLinks.Items[i].Subitems[0]) then
      begin
        edSite.Text := StringReplace(edSite.Text,
            Format('href="%s"', [lvLinks.Items[i].Subitems[0]]),
            Format('href="%s"', [lvLinks.Items[i].Caption]),
          [rfReplaceAll, rfIgnoreCase]);
      end;
    end;

    // Обработка изображений
    iImgS := 0;
    repeat
      iImgS := Pos('<figure', edSite.Text, iImgS + 1);
      if (iImgS > 0) then
      begin
        iImgE := Pos('>', edSite.Text, Pos('/figure', edSite.Text, iImgS + 1));
        if iImgE > 0 then
        begin
          tagSrcImage := Copy(edSite.Text, iImgS, iImgE - iImgS + 1);
          if (tagSrcImage <> '') then
          begin
            tagTrgImage := tagSrcImage;

            sImgSrc := Parse_GetValue(tagSrcImage, 'src="', '"');
            sImgAlt := Parse_GetValue(tagSrcImage, 'alt="', '"');
            sImgWidth := Parse_GetValue(tagSrcImage, 'width="', '"');
            sImgCaption := '';

            for i := 0 to lvImages.Items.Count - 1 do
              if SameText(sImgSrc, lvImages.Items[i].Subitems[0]) then
              begin
                sImgSrc := lvImages.Items[i].Caption;
                if lvImages.Items[i].Checked then
                  sImgCaption := lvImages.Items[i].Subitems[1];

                Break;
              end;

            if cbImgLimitSize.Checked then
            begin
              iImgWidth := RStrToIntDef(sImgWidth, 1024);
              if iImgWidth > edImgLimitSize.Value then
                iImgWidth := edImgLimitSize.Value;
              sImgWidth := Format('%d', [iImgWidth]);
            end;

            // <figure><img width="1200px" height="900px" src="./Обзор ESP32R4 v3_files/scale_1200(8)" alt="Интерфейсы и кнопки условно вне корпуса"></figure>

            // <p><img class="aligncenter" style="border-width: 1px; border-style: solid;" src="https://i.ibb.co/hyWKWZb/image-002.jpg" alt="Обзор ESP32R4 v3 + 8 relay i2c expander" width="640" align="aligncenter" /></p>
            // [caption id="" align="aligncenter" width="1200"]<img src="https://i.ibb.co/z4Jp8k7/image-007.jpg" alt="Версия с внешней антенной и питанием 12В" width="1200" height="900" /> Версия с внешней антенной и питанием 12В[/caption]

            tagTrgImage := Format('<img class="aligncenter" width="%s"', [sImgWidth]);
            if (cbImageFrame.Checked) then
              tagTrgImage := tagTrgImage + ' style="border-width: 1px; border-style: solid;"';
            tagTrgImage := tagTrgImage + Format(' src="%s" alt="%s"', [sImgSrc, sImgAlt]);
            tagTrgImage := tagTrgImage + '/>';

            if sImgCaption = ''
            then tagTrgImage := Format('<p>%s</p>', [tagTrgImage])
            else begin
              if cbImgCaption.Checked
              then tagTrgImage := Format('[caption id="" align="aligncenter" width="%s"]%s%s[/caption]', [sImgWidth, tagTrgImage, sImgCaption])
              else tagTrgImage := Format('<figure>%s<figcaption>%s</figcaption></figure>', [tagTrgImage, sImgCaption])
            end;

            if cbAppendNpsb.Checked then
              tagTrgImage := tagTrgImage + #13#10'<p>&nbsp;</p>';

            // InfoBox(tagSrcImage + #10#10 + tagTrgImage);

            edSite.Text := Copy(edSite.Text, 1, iImgS - 1)
              + tagTrgImage
              + Copy(edSite.Text, iImgE + 1, Length(edSite.Text) - iImgE);
          end;
        end
        else Break;
      end;
    until (iImgS = 0);

  finally
    edSite.Lines.EndUpdate;
    StopWait;
  end;
end;

procedure TfrmMain.actPastleImagesUpdate(Sender: TObject);
begin
  actPastleImages.Enabled := (lvImages.Items.Count > 0) and Clipboard.HasFormat(CF_TEXT);
end;

procedure TfrmMain.actPastleImagesExecute(Sender: TObject);
var
  slBuf: TStringList;
  i, j: Integer;

function ExtractFileNameU(const FileName: string): string;
var
  I: Integer;
begin
  I := FileName.LastDelimiter(['/', '\']);
  if I >= 0 then
    Result := Copy(FileName, I + 2)
  else
    Result := FileName;
end;

begin
  StartWait;
  slBuf := TStringList.Create;
  try
    slBuf.Text := Clipboard.AsText;
    for i := 0 to slBuf.Count - 1 do
    begin
      for j := 0 to lvImages.Items.Count - 1 do
      begin
        if SameText(
          ChangeFileExt(ExtractFileNameU(slBuf[i]), ''),
          ChangeFileExt(ExtractFileNameU(lvImages.Items[j].Caption), '')) then
        begin
          lvImages.Items[j].Caption := slBuf[i];
          Break;
        end;
      end;
    end;
  finally
    slBuf.Free;
    StopWait;
  end;
end;


end.
