
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Text;


interface

  uses
    Deltics.Nullable,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlText = class(TXmlNode, IXmlText)
    protected // IXmlNode
      function get_Name: Utf8String; override;
      function get_Text: Utf8String; override;

    protected // IXmlText
      function get_ContainsEntities: Boolean;
      procedure set_Text(const aValue: Utf8String);

    private
      fContainsEntities: NullableBoolean;
      fText: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aText: Utf8String); overload;
      property ContainsEntities: Boolean read get_ContainsEntities;
    end;


implementation

  uses
    Deltics.Strings,
    Deltics.Xml.Types;


{ TXmlText --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlText.Create(const aText: Utf8String);
  begin
    inherited Create(xmlText);

    fText := aText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlText.get_ContainsEntities: Boolean;
  var
    i: Integer;
  begin
    if fContainsEntities.IsNull then
    begin
      result := fContainsEntities.Value;
      EXIT;
    end;

    result := FALSE;

    for i := 1 to Length(fText) do
    begin
      result := (fText[i] = '&');
      if result then
        BREAK;
    end;

    fContainsEntities.Value := result;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlText.get_Name: Utf8String;
  begin
    result := '[TEXT]';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlText.get_Text: Utf8String;
  begin
    result := fText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlText.set_Text(const aValue: Utf8String);
  begin
    fText := aValue;
    fContainsEntities.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlText.Assign(const aSource: TXmlNode);
  var
    src: TXmlText absolute aSource;
  begin
    inherited;

    fText             := src.fText;
    fContainsEntities := src.fContainsEntities;
  end;




end.
