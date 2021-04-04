
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Elements;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlElement = class(TXmlNamespaceNode, IXmlElement, IXmlHasNodes)
    protected // IXmlNode
      function get_Text: Utf8String; override;

    protected // IXmlElement + IXmlHasNodes
      function get_Attributes: IXmlAttributeList;
      function get_IsEmpty: Boolean;
      function get_Namespaces: IXmlNamespaceList;
      function get_Nodes: IXmlNodeList;
      procedure set_IsEmpty(const aValue: Boolean);
      procedure set_Text(const aValue: Utf8String);
    public
      function Add(const aNode: IXmlNode): Integer;
      function AddAttribute(const aName: Utf8String; const aValue: Utf8String): IXmlAttribute;
      function AddElement(const aName: Utf8String): IXmlElement; overload;
      function AddElement(const aName: Utf8String; const aText: Utf8String): IXmlElement; overload;
      function Clone: IXmlElement; overload;
      function ContainsElement(const aName: Utf8String; var aElement: IXmlElement): Boolean;
      function FindNamespace(const aPrefix: Utf8String): IXmlNamespace;
      function HasAttribute(const aName: Utf8String): Boolean; overload;
      function HasAttribute(const aName: Utf8String; var aValue: Utf8String): Boolean; overload;
//      function AllNamespaces: IXmlNamespaceSelection;

    private
      fAttributes: IXmlAttributeList;
      fNodes: IXmlNodeList;
    protected
      function Accepts(const aNode: TXmlNode): Boolean; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aName: Utf8String); overload;
      constructor Create(const aName: Utf8String; const aText: Utf8String); overload;
//      function AllNamespaces: IXmlNamespaceSelection;
      property Attributes: IXmlAttributeList read fAttributes;
      property Nodes: IXmlNodeList read fNodes;
      property Text: Utf8String read get_Text write set_Text;
    end;



implementation

  uses
    Deltics.Exceptions,
    Deltics.InterfacedObjects,
    Deltics.Strings,
    Deltics.Xml.Nodes.Attributes,
    Deltics.Xml.Nodes.Attributes.Namespaces,
    Deltics.Xml.Nodes.Text,
    Deltics.Xml.Types,
    Deltics.Xml.Utils;


{ TXmlElement ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlElement.Create(const aName: Utf8String);
  begin
    inherited Create(xmlElement, aName);

    fAttributes := TXmlAttributeList.Create(self);
    fNodes      := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlElement.Create(const aName: Utf8String;
                                 const aText: Utf8String);
  var
    nodes: TXmlNodeList;
  begin
    inherited Create(xmlElement, aName);

    nodes := TXmlNodeList.Create(self);

    fAttributes := TXmlAttributeList.Create(self);
    fNodes      := nodes;

    nodes.Add(TXmlText.Create(aText));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Attributes: IXmlAttributeList;
  begin
    result := fAttributes;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Nodes: IXmlNodeList;
  begin
    result := fNodes;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_IsEmpty: Boolean;
  begin
    result := (fNodes.Count = 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Text: Utf8String;
  var
    i: Integer;
    nodes: TXmlNodeList;
    node: TXmlNode;
  begin
    result := '';

    InterfaceCast(fNodes, TXmlNodeList, nodes);

    for i := 0 to Pred(nodes.Count) do
    begin
      node := nodes[i];
      case node.NodeType of
        xmlElement  : result := Utf8.Append(result, (node as IXmlElement).Text);
        xmlText     : result := Utf8.Append(result, (node as IXmlText).Text);
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.Clone: IXmlElement;
  begin
    result := inherited Clone as IXmlElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.ContainsElement(const aName: Utf8String;
                                       var   aElement: IXmlElement): Boolean;
  var
    i: Integer;
    node: TXmlNode;
    element: TXmlElement absolute node;
    list: TXmlNodeList;
  begin
    result    := FALSE;
    aElement  := NIL;

    InterfaceCast(fNodes, TXmlNodeList, list);

    for i := 0 to Pred(list.Count) do
    begin
      node    := list[i];
      result  := (node.NodeType = xmlElement) and (node.Name = aName);

      if result then
      begin
        aElement := element;
        EXIT;
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.HasAttribute(const aName: Utf8String): Boolean;
  var
    notUsed: Utf8String;
  begin
    result := HasAttribute(aName, notUsed);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.HasAttribute(const aName: Utf8String;
                                    var   aValue: Utf8String): Boolean;
  var
    attr: IXmlAttribute;
  begin
    result := Attributes.Contains(aName, attr);
    if result then
      aValue := attr.Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.FindNamespace(const aPrefix: Utf8String): IXmlNamespace;
  var
    i: Integer;
    attr: TXmlAttribute;
    namespace: TXmlNamespace absolute attr;
    list: TXmlAttributeList;
  begin
    result := NIL;

    InterfaceCast(fAttributes, TXmlAttributeList, list);

    for i := 0 to Pred(list.Count) do
    begin
      attr := TXmlAttribute(list[i]);
      if (attr.NodeType = xmlNamespace) and (namespace.Prefix = aPrefix) then
      begin
        result := namespace;
        BREAK;
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Namespaces: IXmlNamespaceList;
  begin

  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.set_IsEmpty(const aValue: Boolean);
  begin
    case aValue of
      FALSE : if (fNodes.Count = 0) then
                Text := '';

      TRUE  : if (fNodes.Count > 0) then
                AsObject(fNodes).Clear;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.set_Text(const aValue: Utf8String);
  var
    i: Integer;
    list: TXmlNodeList;
    existing: IXmlText;
  begin
    InterfaceCast(fNodes, TXmlNodeList, list);

    if (list.Count = 1) and InterfaceCast(list[0], IXmlText, existing) then
    begin
      existing.Text := aValue;
      EXIT;
    end;

    for i := Pred(list.Count) downto 0 do
      if list[i].NodeType in [xmlElement, xmlText] then
        list.Delete(i);

    // TODO: Parse the text content to add text and elements as required.
    //
    //   i.e.  Text := 'This text <b>is</b> made up of text <u>and</u> <i>elements</i>.';

    list.Add(TXmlText.Create(aValue));
  end;


(*
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.AllNamespaces: IXmlNamespaceSelection;
  {
    Returns a NamespaceSelection that identifies all in scope namespaces
     for the element.
  }
  var
    i: Integer;
    element: TXmlElement;
    selection: TXmlNamespaceSelection;
    namespace: TXmlNamespace;
  begin
    selection := TXmlNamespaceSelection.Create(fAttributes);
    result := selection;

    if (Parent.NodeType <> xmlElement) then
      EXIT;

    element := self;

    while TRUE do
    begin
      element := TXmlElement(element.Parent);

      for i := 0 to Pred(element.Namespaces.Count) do
      begin
        namespace := element.Namespaces[i];
        if NOT Assigned(selection.ItemByPrefix(namespace.Prefix)) then
          selection.Add(namespace);
      end;

      if (element.Parent.NodeType <> xmlElement) then
        BREAK;
    end;

    if FindNamespaceByPrefix('', namespace)
     and (namespace.Prefix = '') and (namespace.Name = '') then
    begin
      namespace := selection.ItemByPrefix('');
      selection.Remove(namespace);
    end;
  end;
*)

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.Accepts(const aNode: TXmlNode): Boolean;
  begin
    result := aNode.NodeType in [xmlAttribute,
                                 xmlNamespace,
                                 xmlElement,
                                 xmlText,
                                 xmlComment,
                                 xmlProcessingInstruction,
                                 xmlCDATA,
                                 xmlEntityReference];
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.Add(const aNode: IXmlNode): Integer;
  var
    dest: IXmlNodeList;
    node: TXmlNode;
    nodes: TXmlNodeList;
  begin
    InterfaceCast(aNode, TXmlNode, node);

    case node.NodeType of
      xmlAttribute,
      xmlNamespace              : dest := fAttributes;

      xmlElement,
      xmlText,
      xmlComment,
      xmlProcessingInstruction,
      xmlCDATA,
      xmlEntityReference        : dest := fNodes;
    else
      raise Exception.Create('');
    end;

    InterfaceCast(dest, TXmlNodeList, nodes);

    result := nodes.Add(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.AddAttribute(const aName, aValue: Utf8String): IXmlAttribute;
  begin
    result := TXmlAttribute.Create(aName, aValue);
    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.AddElement(const aName: Utf8String): IXmlElement;
  begin
    result := TXmlElement.Create(aName);
    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.AddElement(const aName, aText: Utf8String): IXmlElement;
  begin
    result := TXmlElement.Create(aName, aText);
    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.Assign(const aSource: TXmlNode);
  var
    src: TXmlElement absolute aSource;
  begin
    inherited;

    TXmlNodeList.Assign(src.Attributes, fAttributes);
    TXmlNodeList.Assign(src.Nodes, fNodes);
  end;








end.
