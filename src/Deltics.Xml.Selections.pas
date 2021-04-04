

  unit Deltics.Xml.Selections;


interface

  uses
    Classes,
    Types,
    Deltics.InterfacedObjects,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces;

  type
    TXmlNodeSelection = class(TComInterfacedObject, IXmlNodeSelection)
    private
      fList: IInterfacedObjectList;
    public
      constructor Create;
      procedure Add(const aNode: IXmlNode); overload;
      procedure Add(const aSelection: IXmlNodeSelection); overload;
      procedure Remove(const aNode: IXmlNode);

    protected // IXmlNodeSelection
      function get_Count: Integer;
      function get_First: IXmlNode;
      function get_Last: IXmlNode;
      function get_Item(const aIndex: Integer): IXmlNode;
    public
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: IXmlNode read get_Item;
    end;


    TXmlElementSelection = class(TXmlNodeSelection, IXmlElementSelection)
    protected
      function get_Item(const aIndex: Integer): IXmlElement; overload;
    public
      constructor Create(const aElement: IXmlElement); overload;
      constructor Create(const aNodes: IXmlNodeList); overload;
      function ItemByName(const aName: Utf8String): IXmlElement;
      property Items[const aIndex: Integer]: IXmlElement read get_Item;
    end;


    TXmlNamespaceSelection = class(TXmlNodeSelection, IXmlNamespaceSelection)
    protected
      function get_Item(const aIndex: Integer): IXmlNamespace; overload;
    public
      constructor Create(const aNodes: IXmlNodeList);
      function ItemByPrefix(const aPrefix: Utf8String): IXmlNamespace;
      property Items[const aIndex: Integer]: IXmlNamespace read get_Item;
    end;



implementation

  uses
    SysUtils,
    Deltics.Xml.Types;


{ IXmlNodeSelection ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNodeSelection.Create;
  begin
    inherited Create;

    fList := TInterfacedObjectList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeSelection.get_Count: Integer;
  begin
    result := fList.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeSelection.get_First: IXmlNode;
  begin
    result := NIL;

    if fList.Count > 0 then
      result := IXmlNode(fList[0]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeSelection.get_Last: IXmlNode;
  begin
    result := NIL;

    if fList.Count > 0 then
      result := IXmlNode(fList[fList.Count - 1]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeSelection.get_Item(const aIndex: Integer): IXmlNode;
  begin
    result := IXmlNode(fList[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeSelection.Add(const aNode: IXmlNode);
  begin
    fList.Add(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeSelection.Add(const aSelection: IXmlNodeSelection);
  var
    i: Integer;
  begin
    for i := 0 to Pred(aSelection.Count) do
      Add(aSelection[i]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeSelection.Remove(const aNode: IXmlNode);
  begin
    fList.Remove(aNode);
  end;







{ IXmlElementSelection --------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlElementSelection.Create(const aNodes: IXmlNodeList);
  var
    i: Integer;
  begin
    inherited Create;

    for i := 0 to Pred(aNodes.Count) do
      if (aNodes[i].NodeType = xmlElement) then
        Add(aNodes[i]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlElementSelection.Create(const aElement: IXmlElement);
  begin
    inherited Create;

    Add(aElement);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElementSelection.get_Item(const aIndex: Integer): IXmlElement;
  begin
    result := inherited Items[aIndex] as IXmlElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElementSelection.ItemByName(const aName: Utf8String): IXmlElement;
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




{ IXmlNamespaceSelection ------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNamespaceSelection.Create(const aNodes: IXmlNodeList);
  var
    i: Integer;
    node: IXmlNode;
  begin
    inherited Create;

    for i := 0 to Pred(aNodes.Count) do
    begin
      node := Items[i];
      if (node.NodeType = xmlNamespace) then
        Add(node);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceSelection.get_Item(const aIndex: Integer): IXmlNamespace;
  begin
    result := inherited Items[aIndex] as IXmlNamespace;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceSelection.ItemByPrefix(const aPrefix: Utf8String): IXmlNamespace;
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
