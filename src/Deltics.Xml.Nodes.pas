
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Types;


  type
    TXmlNode = class(TComInterfacedObject, IXmlNode)
    protected // IXmlNode
      function get_AsAttribute: IXmlAttribute;
      function get_AsElement: IXmlElement;
      function get_Document: IXmlDocument;
      function get_Index: Integer;
      function get_Name: Utf8String; virtual; abstract;
      function get_NodeType: TXmlNodeType;
      function get_Parent: IXmlNode;
      function get_Text: Utf8String; virtual;
//      function get_Path: Utf8String;
//      function get_Text: Utf8String;
    public
      function Clone: IXmlNode;
      procedure Delete;
//      function SelectAttribute(const aPath: Utf8String): IXmlAttribute; overload;
//      function SelectAttribute(const aElementPath: Utf8String; const aAttribute: Utf8String): IXmlAttribute; overload;
//      function SelectElement(const aPath: Utf8String): IXmlElement;
//      function SelectNode(const aPath: Utf8String): TXmlNode;
//      function SelectNodes(const aPath: Utf8String): IXmlNodeSelection;

    private
      fNodeType: TXmlNodeType;
      fParent: TXmlNode;
//      procedure set_Text(const Value: Utf8String);
    protected
      constructor Create(const aNodeType: TXmlNodeType);
      function Accepts(const aNode: TXmlNode): Boolean; virtual;
      procedure Assign(const aSource: TXmlNode); virtual;
      procedure DeleteNode(const aNode: IXmlNode); virtual;
      procedure NodeAdded(const aNode: IXmlNode); virtual;
      procedure NodeDeleted(const aNode: IXmlNode); virtual;
    public
      property Document: IXmlDocument read get_Document;
      property Name: Utf8String read get_Name;
      property NodeType: TXmlNodeType read fNodeType;
      property Parent: TXmlNode read fParent write fParent;
    end;



    TXmlNamespaceNode = class(TXmlNode, IXmlNamespaceNode)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlNamespaceNode
      function get_LocalName: Utf8String;
      function get_Namespace: IXmlNamespace; virtual;
      function get_NamespacePrefix: Utf8String;
      procedure set_Name(const aValue: Utf8String); virtual;
    private
      fLocalName: Utf8String;
      fNamespacePrefix: Utf8String;
    protected
      constructor Create(const aNodeType: TXmlNodeType;
                         const aName: Utf8String);
      procedure Assign(const aSource: TXmlNode); override;
    public
      function FindNamespaceByPrefix(const aPrefix: Utf8String; var aNamespace: IXmlNamespace): Boolean;
      property LocalName: Utf8String read fLocalName;
      property Name: Utf8String read get_Name write set_Name;
      property Namespace: IXmlNamespace read get_Namespace;
      property NamespacePrefix: Utf8String read fNamespacePrefix;
    end;



    TXmlNodeList = class(TInterfacedObjectList, IXmlNodeList)
    protected // IXmlNodeList
      function get_Item(const aIndex: Integer): IXmlNode;

    private
      fOwner: TXmlNode;
      function get_Node(const aIndex: Integer): TXmlNode;
    protected
      function Accepts(const aNode: TXmlNode): Boolean; virtual;
      function InternalAdd(const aNode: IXmlNode; const aIndex: Integer = -1): Integer;
      procedure InternalDelete(const aIndex: Integer);
    public
      constructor Create(const aOwner: TXmlNode);
      function Add(const aNode: IXmlNode): Integer;
      class procedure Assign(const aSource: IXmlNodeList; const aDest: IXmlNodeList); overload;
      procedure Assign(const aSource: IXmlNodeList); overload;
      procedure Assign(const aSource: TXmlNodeList); overload;
      procedure Clear;
      procedure Delete(const aIndex: Integer); overload;
      procedure Delete(const aNode: IXmlNode); overload;
      function IndexOf(const aNode: IXmlNode): Integer;
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: IXmlNode read get_Item;
      property Nodes[const aIndex: Integer]: TXmlNode read get_Node; default;
    end;






implementation

  uses
    SysUtils,
    Deltics.Exceptions,
    Deltics.Strings,
    Deltics.Xml.Exceptions,
    Deltics.Xml.Nodes.Attributes,
    Deltics.Xml.Nodes.Elements,
    Deltics.Xml.Utils;



{ TXmlNode --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNode.Create(const aNodeType: TXmlNodeType);
  begin
    inherited Create;

    fNodeType := aNodeType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_AsAttribute: IXmlAttribute;
  begin
    if NOT (fNodeType = xmlAttribute) then
      raise EXmlNodeTypeException.Create('Xml node is not an attribute');

    result := self as IXmlAttribute;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_AsElement: IXmlElement;
  begin
    if NOT (fNodeType = xmlElement) then
      raise EXmlNodeTypeException.Create('Xml node is not an element');

    result := self as IXmlElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Document: IXmlDocument;
  var
    node: IXmlNode;
  begin
    node := self;

    while Assigned(node) and (node.NodeType <> xmlDocument) do
      node := node.Parent;

    result := node as IXmlDocument;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Index: Integer;
  var
    parent: IXmlElement;
  begin
    result := -1;

    case NodeType of
      xmlAttribute,
      xmlNamespace  : if InterfaceCast(fParent, IXmlElement, parent) then
//                      if fParent.Supports(IXmlElement, parent) then
                        result := parent.Attributes.IndexOf(self as IXmlAttribute);
    else
      if InterfaceCast(fParent, IXmlElement, parent) then
//      if fParent.Supports(IXmlElement, parent) then
        result := parent.Nodes.IndexOf(self);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_NodeType: TXmlNodeType;
  begin
    result := fNodeType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Parent: IXmlNode;
  begin
    if Assigned(fParent) then
      result := fParent as IXmlNode
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Text: Utf8String;
  begin
    result := '';
  end;


(*
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Path: Utf8String;
  begin
    if Assigned(fParent) then
      result := Parent.Path + '/' + Name
    else
      result := Name;
  end;
*)


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.Accepts(const aNode: TXmlNode): Boolean;
  begin
    result := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.Assign(const aSource: TXmlNode);
  begin
    // NOTE: Parent is NOT assigned

    fNodeType := aSource.NodeType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.Clone: IXmlNode;
  var
    node: TXmlNode;
  begin
    node := TXmlNode(ClassType.Create);
    node.Assign(self);

    result := node;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.Delete;
  begin
    if NOT Assigned(fParent) then
      raise Exception.Create('Node does not have a parent');

    fParent.DeleteNode(self);
    fParent.NodeDeleted(self);

    fParent := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.DeleteNode(const aNode: IXmlNode);
  begin
    raise ENotImplemented.Create(self, 'DeleteNode(IXmlNode)');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.NodeAdded(const aNode: IXmlNode);
  begin
    // NO-OP
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.NodeDeleted(const aNode: IXmlNode);
  begin
    // NO-OP
  end;



(*
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectAttribute(const aPath: Utf8String): IXmlAttribute;
  var
    node: IXmlNode;
  begin
    node := SelectNode(aPath);

    if NOT Assigned(node) or (node.NodeType <> xmlAttribute) then
      raise Exception.CreateFmt('''%s'' is not a valid attribute path', [aPath]);

    result := node.AsAttribute;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectAttribute(const aElementPath: Utf8String;
                                    const aAttribute: Utf8String): IXmlAttribute;
  var
    node: IXmlNode;
  begin
    node := SelectNode(aElementPath + '@' + aAttribute);

    if NOT Assigned(node) or (node.NodeType <> xmlAttribute) then
      raise Exception.CreateFmt('''%s'' is not a valid attribute path', [aElementPath + '@' + aAttribute]);

    result := node as IXmlAttribute;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectElement(const aPath: Utf8String): IXmlElement;
  var
    node: IXmlNode;
  begin
    node := SelectNode(aPath);
    if NOT Assigned(node) or (node.NodeType <> xmlElement) then
      raise Exception.CreateFmt('''%s'' is not a valid element path', [aPath]);

    result := node as IXmlElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectNode(const aPath: Utf8String): TXmlNode;
  var
    element: TXmlElement absolute result;
    i: Integer;
    query: Utf8String;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    subquery: Utf8String;
    parts: StringArray;
    elementName: Utf8String;
    attrName: Utf8String;
  begin
    result  := NIL;
    query   := aPath;

    if (query <>'') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(Document.Nodes);
      System.Delete(query, 1, 1);
    end
    else case NodeType of
      xmlElement  : elements := TXmlElementSelection.Create(TXmlElement(self).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(TXmlDocument(self).Nodes);
    else
      EXIT;
    end;

    template := TStringTemplate.Create('', '{', '}');
    match    := TStringList.Create;
    try
      if template.Matches('{root}/{subquery}', STR.FromUtf8(query), match) then
      begin
        elementName := Utf8.FromString(match.Values['root']);
        subquery    := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = elementName) then
          begin
            result := elements[i].SelectNode(subquery);
            if Assigned(result) then
              BREAK;
          end;
      end
      else
      begin
        case STR.Split(STR.FromUtf8(query), '@', parts) of
          1 : begin
                elementName := query;
                attrName    := ''
              end;

          2 : begin
                elementName := Utf8.FromString(parts[0]);
                attrName    := Utf8.FromString(parts[1]);
              end;
        end;

        result := elements.ItemByName(elementName);

        if Assigned(result) and (attrName <> '') then
        begin
          if (result.NodeType <> xmlElement) then
            raise Exception.CreateFmt('''%s'' is not an element', [result.Path]);

          result := element.Attributes.ByName(attrName);
        end;
      end;

    finally
      match.Free;
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectNodes(const aPath: Utf8String): IXmlNodeSelection;
  var
    i: Integer;
    query: Utf8String;
    selection: TXmlNodeSelection;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    selection := TXmlNodeSelection.Create;
    result    := selection;

    query := aPath;
    if (query <> '') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(Document.Nodes);
      System.Delete(query, 1, 1);
    end
    else case NodeType of
      xmlElement  : elements := TXmlElementSelection.Create(TXmlElement(self).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(TXmlDocument(self).Nodes);
    else
      EXIT;
    end;

    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.Create;
    try
      if template.Matches(STR.FromUtf8(query), match) then
      begin
        root      := Utf8.FromString(match.Values['root']);
        subquery  := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = root) then
            selection.Add(elements[i].SelectNodes(subquery));
      end
      else
        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = query) then
            selection.Add(elements[i]);

    finally
      match.Free;
      template.Free;
    end;
  end;
*)






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

    fLocalName        := src.fLocalName;
    fNamespacePrefix  := src.fNamespacePrefix;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_LocalName: Utf8String;
  begin
    result := fLocalName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_Name: Utf8String;
  begin
    if (fNamespacePrefix <> '') then
      result := fNamespacePrefix + ':' + LocalName
    else
      result := LocalName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_Namespace: IXmlNamespace;
  begin
    if NOT FindNamespaceByPrefix(fNamespacePrefix, result) then
      raise Exception.Create('Invalid namespace reference')
    else if (result.Prefix = '') and (result.Name = '') then
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_NamespacePrefix: Utf8String;
  begin
    result := fNamespacePrefix;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespaceNode.set_Name(const aValue: Utf8String);
  var
    parts: StringArray;
  begin
    case STR.Split(STR.FromUtf8(aValue), ':', parts) of
      1 : fLocalName := aValue;

      2 : begin
            fNamespacePrefix  := Utf8.FromString(parts[0]);
            fLocalName        := Utf8.FromString(parts[1]);
          end;
    else
      raise Exception.CreateFmt('''%s'' is not a valid node name', [aValue]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.FindNamespaceByPrefix(const aPrefix: Utf8String;
                                                   var aNamespace: IXmlNamespace): Boolean;
  var
    element: TXmlElement;
  begin
    case NodeType of
      xmlAttribute  : InterfaceCast(Parent, TXmlElement, element);
      xmlElement    : element := TXmlElement(self);
    else
      element := NIL;
    end;

    while Assigned(element) do
    begin
      aNamespace := element.FindNamespace(aPrefix);
      if NOT Assigned(aNamespace) and (element.Parent.NodeType = xmlElement) then
        element := TXmlElement(element.Parent)
      else
        BREAK;
    end;

    result := Assigned(aNamespace);
  end;





{ TXmlNodeList ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure TXmlNodeList.Assign(const aSource, aDest: IXmlNodeList);
  var
    dest: TXmlNodeList;
    src: TXmlNodeList;
  begin
    InterfaceCast(aSource, TXmlNodeList, src);
    InterfaceCast(aDest, TXmlNodeList, dest);

    dest.Assign(src);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNodeList.Create(const aOwner: TXmlNode);
  begin
    inherited Create;

    fOwner := aOwner;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.Add(const aNode: IXmlNode): Integer;
  begin
    result := InternalAdd(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Assign(const aSource: IXmlNodeList);
  var
    src: TXmlNodeList;
  begin
    InterfaceCast(aSource, TXmlNodeList, src);
    Assign(src);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Assign(const aSource: TXmlNodeList);
  var
    i: Integer;
  begin
    Clear;
    Capacity := aSource.Count;

    for i := 0 to Pred(aSource.Count) do
      Add(aSource[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.Accepts(const aNode: TXmlNode): Boolean;
  begin
    result := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Clear;
  begin
    while Count > 0 do
      Delete(0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Delete(const aIndex: Integer);
  begin
    inherited Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Delete(const aNode: IXmlNode);
  begin
    inherited Delete(IndexOf(aNode));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.get_Item(const aIndex: Integer): IXmlNode;
  begin
    result := inherited Items[aIndex] as IXmlNode;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.get_Node(const aIndex: Integer): TXmlNode;
  begin
    result := TXmlNode(inherited Objects[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.IndexOf(const aNode: IXmlNode): Integer;
  begin
    result := inherited IndexOf((aNode as IInterfacedObject).AsObject);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.InternalAdd(const aNode: IXmlNode; const aIndex: Integer): Integer;
  var
    cloned: Boolean;
    node: TXmlNode;
  begin
    result := -1;

    if NOT Assigned(aNode) then
      EXIT;

    InterfaceCast(aNode, TXmlNode, node);

    if NOT Accepts(node) then
      raise Exception.CreateFmt('Invalid operation.  Cannot add a %s to a %s', [node.ClassName, self.ClassName]);

    if Assigned(fOwner) and NOT fOwner.Accepts(node) then
      raise Exception.CreateFmt('Invalid operation.  Cannot add a %s to a %s', [node.ClassName, fOwner.ClassName]);

    // If the node we are adding already has a parent then we add a CLONE of the
    //  node rather than detaching it from it's current document

    cloned := Assigned(node.Parent);
    if cloned then
      InterfaceCast(node.Clone, TXmlNode, node);

    node.fParent := fOwner;

    if (aIndex = -1) or (aIndex >= Count) then
      result := inherited Add(node)
    else
      result := inherited Insert(aIndex, node);

    fOwner.NodeAdded(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.InternalDelete(const aIndex: Integer);
  var
    nodeRef: IXmlNode;
    node: TXmlNode;
  begin
    if (aIndex < 0) or (aIndex >= Count) then
      EXIT;

    inherited Delete(aIndex);

    // Ensure there is at least one intf ref to the node after it has been deleted
    //  to ensure it is not destroyed before the owner has been notified
    nodeRef := Items[aIndex];

    InterfaceCast(nodeRef, TXmlNode, node);

    fOwner.NodeDeleted(node);
  end;




end.
