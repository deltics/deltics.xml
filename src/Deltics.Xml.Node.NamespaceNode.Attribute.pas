
{$i deltics.xml.inc}

  unit Deltics.Xml.Node.NamespaceNode.Attribute;


interface

  uses
    Deltics.Strings,
    Deltics.Xml.Node.NamespaceNode,
    Deltics.Xml.Types;


  type
    TXmlAttribute = class(TXmlNamespaceNode)
    private
      fValue: Utf8String;
      function get_AsNamespace: TXmlNamespace;
      function get_IsNamespaceBinding: Boolean;
    protected
      constructor Create(const aNodeType: TXmlNodeType; const aName, aValue: Utf8String); overload;
      function get_Namespace: TXmlNamespace; override;
      function get_Text: Utf8String; override;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aName, aValue: Utf8String); overload;
      property AsNamespace: TXmlNamespace read get_AsNamespace;
      property IsNamespaceBinding: Boolean read get_IsNamespaceBinding;
      property Value: Utf8String read fValue write fValue;
    end;



implementation





{ TXmlAttribute ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlAttribute.Create(const aNodeType: TXmlNodeType; const aName, aValue: Utf8String);
  begin
    inherited Create(aNodeType, aName);

    fValue := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlAttribute.Create(const aName, aValue: Utf8String);
  begin
    Create(xmlAttribute, aName, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_AsNamespace: TXmlNamespace;
  begin
    if NOT IsNamespaceBinding then
      raise EConvertError.Create('Attribute is not a namespace binding');

    result := TXmlNamespace(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_IsNamespaceBinding: Boolean;
  begin
    result := (NamespaceName = 'Xmlns') or ((NamespaceName = '') and (LocalName = 'Xmlns'));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Namespace: TXmlNamespace;
  begin
    if (NamespaceName <> '') then
      result := inherited get_Namespace
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Text: Utf8String;
  begin
    result := fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Xml: Utf8String;
  begin
    result := Name + '="' + Value + '"';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttribute.Assign(const aSource: TXmlNode);
  var
    src: TXmlAttribute absolute aSource;
  begin
    inherited;

    fValue  := src.fValue;
  end;




end.
