
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Dtd.Attributes;


interface

  uses
    Deltics.StringLists,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Nodes.Dtd,
    Deltics.Xml.Types;

  type
    TXmlDtdAttribute = class(TXmlDtdDeclaration, IXmlDtdAttribute)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDtdAttribute
      function get_AttributeType: TXmlDtdAttributeType;
      function get_Constraint: TXmlDtdAttributeConstraint;
      function get_DefaultValue: Utf8String;
      function get_Members: IUtf8StringList;

    private
      fAttributeType: TXmlDtdAttributeType;
      fConstraint: TXmlDtdAttributeConstraint;
      fDefaultValue: Utf8String;
      fMembers: IUtf8StringList;
      fName: Utf8String;
      procedure set_Members(const aValue: IUtf8StringList);
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aName: Utf8String; const aType: TXmlDtdAttributeType); reintroduce;
      property AttributeType: TXmlDtdAttributeType read fAttributeType;
      property Constraint: TXmlDtdAttributeConstraint read fConstraint write fConstraint;
      property DefaultValue: Utf8String read fDefaultValue write fDefaultValue;
      property Members: IUtf8StringList read fMembers write set_Members;
      property Name: Utf8String read fName;
    end;



    TXmlDtdAttributeList = class(TXmlDtdDeclaration, IXmlDtdAttributeList, IXmlHasNodes)
    protected // IXmlHasNodes
      function get_Nodes: IXmlNodeList;

    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDtdAttributeDeclarationList
      function get_Count: Integer;
      function get_ElementName: Utf8String;
      function get_Item(const aIndex: Integer): IXmlDtdAttribute;

    private
      fItems: IXmlNodeList;
      fElementName: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aElementName: Utf8String); reintroduce;
      property Attributes: IXmlNodeList read fItems;
      property Count: Integer read get_Count;
      property ItemList: IXmlNodeList read fItems;
      property Items[const aIndex: Integer]: IXmlDtdAttribute read get_Item;
    end;



implementation

  uses
    Deltics.Exceptions,
    Deltics.InterfacedObjects;



{ TXmlDtdAttributeDeclaration -------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdAttribute.Create(const aName: Utf8String;
                                      const aType: TXmlDtdAttributeType);
  begin
    inherited Create(xmlDtdAttribute);

    fName           := aName;
    fAttributeType  := aType;

    if fAttributeType in [atEnum, atNotation] then
      fMembers := TUtf8StringList.CreateManaged;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttribute.get_AttributeType: TXmlDtdAttributeType;
  begin
    result := fAttributeType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttribute.get_Constraint: TXmlDtdAttributeConstraint;
  begin
    result := fConstraint;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttribute.get_DefaultValue: Utf8String;
  begin
    result := fDefaultValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttribute.get_Members: IUtf8StringList;
  begin
    result := fMembers;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttribute.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdAttribute.set_Members(const aValue: IUtf8StringList);
  begin
    if NOT (fAttributeType in [atEnum, atNotation]) then
      raise Exception.Create('Only Enum and Notation attributes can have Members');

    fMembers.Clear;
    fMembers.Add(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdAttribute.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdAttribute absolute aSource;
  begin
    inherited;

    fAttributeType  := src.fAttributeType;
    fConstraint     := src.fConstraint;
    fDefaultValue   := src.fDefaultValue;
    fName           := src.fName;

    fMembers.Clear;
    fMembers.Add(src.fMembers);
  end;







{ TXmlDtdAttListDeclaration ---------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdAttributeList.Create(const aElementName: Utf8String);
  begin
    inherited Create(xmlDtdAttributeList);

    fItems   := TXmlNodeList.Create(self);
    fElementName  := aElementName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeList.get_ElementName: Utf8String;
  begin
    result := fElementName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeList.get_Item(const aIndex: Integer): IXmlDtdAttribute;
  begin
    result := fItems[aIndex] as IXmlDtdAttribute;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeList.get_Name: Utf8String;
  begin
    result := '#dtd-attribute-list';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeList.get_Nodes: IXmlNodeList;
  begin
    result := fItems;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdAttributeList.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdAttributeList absolute aSource;
  begin
    inherited;

    fElementName := src.fElementName;

    TXmlNodeList.Assign(src.fItems, fItems);
  end;



end.

