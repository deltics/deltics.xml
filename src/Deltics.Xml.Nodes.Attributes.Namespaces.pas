
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Attributes.Namespaces;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Nodes.Attributes,
    Deltics.Xml.Interfaces;

  type
    TXmlNamespace = class(TXmlAttribute, IXmlNamespace)
    protected
//      function get_IsDefault: Boolean;
      function get_Prefix: Utf8String;
      procedure set_Name(const aValue: Utf8String); override;
      procedure set_Prefix(const aValue: Utf8String);

    public
      constructor Create(const aName: Utf8String; const aUri: Utf8String);
//      property IsDefault: Boolean read get_IsDefault;
      property Name: Utf8String read get_Name write set_Name;
      property Prefix: Utf8String read get_Prefix write set_Prefix;
      property Url: Utf8String read get_Value write set_Value;
    end;


implementation

  uses
    Deltics.Strings,
    Deltics.Xml.Exceptions,
    Deltics.Xml.Types;


{ TXmlNamespace ---------------------------------------------------------------------------------- }

(*
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespace.get_IsDefault: Boolean;
  begin
    result := ((inherited Name) = 'Xmlns');
  end;
*)

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNamespace.Create(const aName: Utf8String;
                                   const aUri: Utf8String);
  begin
    inherited Create(xmlNamespace, aName, aUri);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespace.get_Prefix: Utf8String;
  var
    prefix, name: Utf8String;
  begin
    if Utf8.Split(get_Name, ':', prefix, name) then
      result := prefix
    else
      result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespace.set_Name(const aValue: Utf8String);
  begin
    if NOT ((aValue = 'xmlns') or Utf8.BeginsWith(aValue, 'xmlns:')) then
      raise EXmlException.CreateFmt('''%s'' is not a valid name for a Namespace attribute which must be of the form ''xmlns'' or ''xmlns:<prefix>''', [Str.FromUtf8(aValue)]);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespace.set_Prefix(const aValue: Utf8String);
  begin
    if (aValue = '') then
      inherited Name := 'xmlns'
    else
      inherited Name := 'xmlns:' + aValue;
  end;







end.
