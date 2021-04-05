
{$i deltics.xml.inc}

  unit Deltics.Xml.Insertion;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlNodeInsertion = class(TComInterfacedObject, IXmlNodeInsertion, IXmlAttributeInsertion)
    protected // IXmlNodeInsertion
      function After(const aNode: IXmlNode): Integer; overload;
      function AtIndex(const aIndex: Integer): Integer;
      procedure AsFirst;
      function AsLast: Integer;
      function Before(const aNode: IXmlNode): Integer; overload;
      function Replacing(const aIndex: Integer): Integer; overload;
      function Replacing(const aNode: IXmlNode): Integer; overload;

    protected // IXmlAttributeInsertion
      function After(const aNode: IXmlAttribute): Integer; overload;
      function Before(const aNode: IXmlAttribute): Integer; overload;
      function Replacing(const aNode: IXmlAttribute): Integer; overload;

    private
      fList: TXmlNodeList;
      fNode: IXmlNode;
      function InsertAt(aIndex: Integer): Integer;
    public
      constructor Create(const aList: TXmlNodeList; const aNode: IXmlNode);
    end;


implementation

  uses
    Deltics.Exceptions,
    Deltics.Xml.Utils;


{ TXmlNodeInsertion }

  constructor TXmlNodeInsertion.Create(const aList: TXmlNodeList; const aNode: IXmlNode);
  begin
    inherited Create;

    fList := aList;
    fNode := aNode;
  end;


  function TXmlNodeInsertion.InsertAt(aIndex: Integer): Integer;
  begin
    if fList.Contains(fNode) then
      raise Exception.Create('Cannot insert node as it is already present');

    if (aIndex < 0) then
      result := AsObject(fList).Insert(0, fNode)
    else if (aIndex >= fList.Count) then
      result := AsObject(fList).Add(fNode)
    else
      result := AsObject(fList).Insert(aIndex, fNode);
  end;


  function TXmlNodeInsertion.After(const aNode: IXmlNode): Integer;
  var
    idx: Integer;
  begin
    if NOT fList.Contains(aNode, idx) then
      raise Exception.Create('Cannot insert after the specified node as it is not present');

    result := InsertAt(idx + 1);
  end;


  function TXmlNodeInsertion.After(const aNode: IXmlAttribute): Integer;
  var
    idx: Integer;
  begin
    if NOT fList.Contains(aNode, idx) then
      raise Exception.Create('Cannot insert after the specified attribute as it is not present');

    result := InsertAt(idx + 1);
  end;


  procedure TXmlNodeInsertion.AsFirst;
  begin
    InsertAt(-1);
  end;


  function TXmlNodeInsertion.AsLast: Integer;
  begin
    result := InsertAt(fList.Count);
  end;


  function TXmlNodeInsertion.AtIndex(const aIndex: Integer): Integer;
  begin
    result := InsertAt(aIndex);
  end;


  function TXmlNodeInsertion.Before(const aNode: IXmlNode): Integer;
  var
    idx: Integer;
  begin
    if NOT fList.Contains(aNode, idx) then
      raise Exception.Create('Cannot insert after the specified node as it is not present');

    result := InsertAt(idx);
  end;


  function TXmlNodeInsertion.Before(const aNode: IXmlAttribute): Integer;
  var
    idx: Integer;
  begin
    if NOT fList.Contains(aNode, idx) then
      raise Exception.Create('Cannot insert after the specified node as it is not present');

    result := InsertAt(idx);
  end;


  function TXmlNodeInsertion.Replacing(const aNode: IXmlAttribute): Integer;
  var
    idx: Integer;
  begin
    if NOT fList.Contains(aNode, idx) then
      raise Exception.Create('Cannot replace the specified attribute as it is not present');

    aNode.Delete;

    result := InsertAt(idx);
  end;


  function TXmlNodeInsertion.Replacing(const aIndex: Integer): Integer;
  begin
    if (aIndex < 0) or (aIndex >= fList.Count) then
      raise Exception.Create('Invalid list index');

    fList[aIndex].Delete;

    result := InsertAt(aIndex);
  end;


  function TXmlNodeInsertion.Replacing(const aNode: IXmlNode): Integer;
  var
    idx: Integer;
  begin
    if NOT fList.Contains(aNode, idx) then
      raise Exception.Create('Cannot replace the specified node as it is not present');

    aNode.Delete;

    result := InsertAt(idx);
  end;



end.
