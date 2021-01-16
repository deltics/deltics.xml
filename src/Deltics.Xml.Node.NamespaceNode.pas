
{$i deltics.xml.inc}

  unit Deltics.Xml.Node.NamespaceNode;


interface

  uses
    Deltics.Strings,
    Deltics.Xml.Node,
    Deltics.Xml.Types;


  type
    TXmlNamespaceNode = class(TXmlNode)
    private
      fLocalName: Utf8String;
      fNamespaceName: Utf8String;
      procedure set_Name(const aValue: Utf8String);
    protected
      constructor Create(const aNodeType: TXmlNodeType;
                         const aName: Utf8String);
      function get_Name: Utf8String; override;
      function get_Namespace: TXmlNamespace; virtual;
      procedure Assign(const aSource: TXmlNode); override;
    public
      function FindNamespaceByPrefix(const aPrefix: Utf8String; var aNamespace: TXmlNamespace): Boolean;
      property LocalName: Utf8String read fLocalName;
      property Namespace: TXmlNamespace read get_Namespace;
      property NamespaceName: Utf8String read fNamespaceName;
      property Name: Utf8String read get_Name write set_Name;
    end;



implementation



{ TXmlNamespaceNode ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNamespaceNode.Create(const aNodeType: TXmlNodeType;
                                       const aName: Utf8String);
  begin
    inherited Create(aNodeType);

    set_Name(aName);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespaceNode.Assign(const aSource: TXmlNode);
  var
    src: TXmlNamespaceNode absolute aSource;
  begin
    inherited;

    fLocalName      := src.fLocalName;
    fNamespaceName  := src.fNamespaceName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_Name: Utf8String;
  begin
    if (fNamespaceName <> '') then
      result := fNamespaceName + ':' + LocalName
    else
      result := LocalName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_Namespace: TXmlNamespace;
  begin
    if NOT FindNamespaceByPrefix(fNamespaceName, result) then
      raise Exception.Create('Invalid namespace reference')
    else if (result.Prefix = '') and (result.Name = '') then
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespaceNode.set_Name(const aValue: Utf8String);
  var
    parts: TStringArray;
  begin
    case STR.Split(STR.FromUtf8(aValue), ':', parts) of
      1 : fLocalName := aValue;

      2 : begin
            fNamespaceName  := Utf8.FromString(parts[0]);
            fLocalName      := Utf8.FromString(parts[1]);
          end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.FindNamespaceByPrefix(const aPrefix: Utf8String;
                                                   var aNamespace: TXmlNamespace): Boolean;
  var
    element: TXmlElement;
  begin
    case NodeType of
      xmlAttribute  : element := Parent.AsElement;
      xmlElement    : element := self.AsElement;
    else
      element := NIL;
    end;

    while Assigned(element) do
    begin
      aNamespace := element.NamespaceByPrefix(aPrefix);
      if NOT Assigned(aNamespace) and (element.Parent.NodeType = xmlElement) then
        element := TXmlElement(element.Parent)
      else
        BREAK;
    end;

    result := Assigned(aNamespace);
  end;












end.
