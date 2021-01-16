

  unit Deltics.Xml.Selections;


interface

  uses
    Classes,
    Types,
    Deltics.InterfacedObjects,
    Deltics.XML;

  type
    TXMLNodeSelection = class(TComInterfacedObject, IXMLNodeSelection)
    private
      fList: TList;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(const aNode: TXMLNode); overload;
      procedure Add(const aSelection: IXMLNodeSelection); overload;
      procedure Remove(const aNode: TXMLNode);

    protected // IXMLNodeSelection
      function get_Count: Integer;
      function get_First: TXmlNode;
      function get_Last: TXmlNode;
      function get_Node(const aIndex: Integer): TXMLNode;
    public
      property Count: Integer read get_Count;
      property Nodes[const aIndex: Integer]: TXMLNode read get_Node;
    end;


    TXMLElementSelection = class(TXMLNodeSelection, IXMLElementSelection)
    protected
      function get_ElementItem(const aIndex: Integer): TXMLElement;
    public
      constructor Create(const aNodes: TXMLNodeList);
      function ItemByName(const aName: UTF8String): TXMLElement;
      property Items[const aIndex: Integer]: TXMLElement read get_ElementItem; default;
      function IXMLElementSelection.get_Item = get_ElementItem;
    end;


    TXMLNamespaceSelection = class(TXMLNodeSelection, IXMLNamespaceSelection)
    protected
      function get_NamespaceItem(const aIndex: Integer): TXMLNamespace;
    public
      constructor Create(const aNodes: TXMLNodeList);
      function ItemByPrefix(const aPrefix: UTF8String): TXMLNamespace;
      property Items[const aIndex: Integer]: TXMLNamespace read get_NamespaceItem; default;
      function IXMLNamespaceSelection.get_Item = get_NamespaceItem;
    end;



implementation

  uses
    SysUtils;


{ TXMLNodeSelection ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXMLNodeSelection.Create;
  begin
    inherited Create;

    fList := TList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXMLNodeSelection.Destroy;
  begin
    FreeAndNIL(fList);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLNodeSelection.get_Count: Integer;
  begin
    result := fList.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLNodeSelection.get_First: TXmlNode;
  begin
    result := NIL;

    if fList.Count > 0 then
      result := TXmlNode(fList[0]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLNodeSelection.get_Last: TXmlNode;
  begin
    result := NIL;

    if fList.Count > 0 then
      result := TXmlNode(fList[fList.Count - 1]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLNodeSelection.get_Node(const aIndex: Integer): TXMLNode;
  begin
    result := TXMLNode(fList[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLNodeSelection.Add(const aNode: TXMLNode);
  begin
    fList.Add(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLNodeSelection.Add(const aSelection: IXMLNodeSelection);
  var
    i: Integer;
  begin
    for i := 0 to Pred(aSelection.Count) do
      Add(aSelection[i]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLNodeSelection.Remove(const aNode: TXMLNode);
  begin
    fList.Remove(aNode);
  end;







{ TXMLElementSelection --------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXMLElementSelection.Create(const aNodes: TXMLNodeList);
  var
    i: Integer;
  begin
    inherited Create;

    for i := 0 to Pred(aNodes.Count) do
      if (aNodes[i].NodeType = xmlElement) then
        Add(aNodes[i]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLElementSelection.get_ElementItem(const aIndex: Integer): TXMLElement;
  begin
    result := TXMLElement(inherited get_Node(aIndex));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLElementSelection.ItemByName(const aName: UTF8String): TXMLElement;
  var
    i: Integer;
  begin
    result := NIL;

    for i := 0 to Pred(Count) do
      if (Items[i].Name = aName) then
      begin
        result := Items[i];
        BREAK;
      end;
  end;




{ TXMLNamespaceSelection ------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXMLNamespaceSelection.Create(const aNodes: TXMLNodeList);
  var
    i: Integer;
    node: TXMLNode;
    attr: TXMLAttribute absolute node;
  begin
    inherited Create;

    for i := 0 to Pred(aNodes.Count) do
    begin
      node := aNodes[i];
      if (node.NodeType = xmlAttribute) and attr.IsNamespaceBinding then
        Add(node);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLNamespaceSelection.get_NamespaceItem(const aIndex: Integer): TXMLNamespace;
  begin
    result := TXMLNamespace(inherited get_Node(aIndex));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLNamespaceSelection.ItemByPrefix(const aPrefix: UTF8String): TXMLNamespace;
  var
    i: Integer;
  begin
    result := NIL;

    for i := 0 to Pred(Count) do
      if (Items[i].Prefix = aPrefix) then
      begin
        result := Items[i];
        BREAK;
      end;
  end;





end.
