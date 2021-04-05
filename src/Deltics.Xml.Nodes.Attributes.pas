
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Attributes;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Types;



  type
    TXmlAttribute = class(TXmlNamespaceNode, IXmlAttribute)
    private // IXmlAttribute
      fValue: Utf8String;
    protected
//        function get_AsNamespace: IXmlNamespace;
//        function get_IsNamespaceBinding: Boolean;
      function get_Value: Utf8String;
      procedure set_Value(const aValue: Utf8String);
    protected
      constructor Create(const aNodeType: TXmlNodeType; const aName, aValue: Utf8String); overload;
//        function get_Namespace: IXmlNamespace; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aName, aValue: Utf8String); overload;
//        property AsNamespace: IXmlNamespace read get_AsNamespace;
//        property IsNamespaceBinding: Boolean read get_IsNamespaceBinding;
      property Value: Utf8String read fValue write fValue;
    end;


    TXmlAttributeList = class(TXmlNodeList, IXmlAttributeList)
    protected // IXmlAttributeList
      function get_Item(const aIndex: Integer): IXmlAttribute; overload;
      function Contains(const aName: Utf8String; var aAttribute: IXmlAttribute): Boolean; overload;
      function Contains(const aName: Utf8String; var aIndex: Integer): Boolean; overload;
      function Contains(const aName: Utf8String; var aValue: Utf8String): Boolean; overload;
    public
      procedure Delete(const aItem: IXmlAttribute); overload;
      function IndexOf(const aItem: IXmlAttribute): Integer; overload;
      function ItemByName(const aName: Utf8String): IXmlAttribute; overload;

      property Items[const aIndex: Integer]: IXmlAttribute read get_Item;

    public
      procedure Assign(const aSource: IXmlAttributeList); overload;
    end;


implementation

  uses
    Deltics.Xml.Utils;


{ TXmlAttribute ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlAttribute.Create(const aNodeType: TXmlNodeType;
                                   const aName: Utf8String;
                                   const aValue: Utf8String);
  begin
    inherited Create(aNodeType, aName);

    fValue := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlAttribute.Create(const aName: Utf8String;
                                   const aValue: Utf8String);
  begin
    Create(xmlAttribute, aName, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Value: Utf8String;
  begin
    result := fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttribute.set_Value(const aValue: Utf8String);
  begin
    fValue := aValue;
  end;



(*
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_AsNamespace: IXmlNamespace;
  begin
    if NOT IsNamespace then
      raise EConvertError.Create('Attribute is not a namespace declaration');

    result := TXmlNamespace(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_IsNamespaceBinding: Boolean;
  begin
    result := (NamespaceName = 'xmlns') or ((NamespaceName = '') and (LocalName = 'xmlns'));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Namespace: IXmlNamespace;
  begin
    if (NamespaceName <> '') then
      result := inherited get_Namespace
    else
      result := NIL;
  end;
*)

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttribute.Assign(const aSource: TXmlNode);
  var
    src: TXmlAttribute absolute aSource;
  begin
    inherited;

    fValue  := src.fValue;
  end;






{ TXmlAttributeList }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.get_Item(const aIndex: Integer): IXmlAttribute;
  begin
    result := inherited Items[aIndex] as IXmlAttribute;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.Contains(const aName: Utf8String;
                                      var   aAttribute: IXmlAttribute): Boolean;
  var
    i: Integer;
  begin
    result      := FALSE;
    aAttribute  := NIL;

    for i := 0 to Pred(Count) do
    begin
      result := Nodes[i].Name = aName;
      if result then
      begin
        aAttribute := Items[i];
        EXIT;
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.Contains(const aName: Utf8String;
                                      var   aIndex: Integer): Boolean;
  var
    i: Integer;
  begin
    result  := FALSE;
    aIndex  := -1;

    for i := 0 to Pred(Count) do
    begin
      if Nodes[i].Name = aName then
      begin
        aIndex := i;
        result := TRUE;
        EXIT;
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttributeList.Assign(const aSource: IXmlAttributeList);
  begin
    Assign(AsObject(aSource));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.Contains(const aName: Utf8String;
                                      var   aValue: Utf8String): Boolean;
  var
    attr: IXmlAttribute;
  begin
    result := Contains(aName, attr);
    if result then
      aValue := attr.Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttributeList.Delete(const aItem: IXmlAttribute);
  begin
    inherited Delete(aItem);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.IndexOf(const aItem: IXmlAttribute): Integer;
  begin
    result := inherited IndexOf(aItem);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.ItemByName(const aName: Utf8String): IXmlAttribute;
  begin
    result := inherited ItemByName(aName) as IXmlAttribute;
  end;




end.
