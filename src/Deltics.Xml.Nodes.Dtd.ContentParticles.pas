
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Dtd.ContentParticles;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Nodes.Dtd,
    Deltics.Xml.Types;


  type
    TXmlDtdContentParticle = class(TXmlDtdDeclaration, IXmlDtdContentParticle)
    protected //IXmlNode
      function get_Name: Utf8String; override;

    protected //IXmlDtdContentParticle
      function get_AllowMultiple: Boolean;
      function get_Element: IXmlDtdElement;
      function get_IsPCDATA: Boolean;
      function get_IsRequired: Boolean;
      function get_Parent: IXmlDtdContentParticle; overload;

    private
      fAllowMultiple: Boolean;
      fElement: IXmlDtdElement;
      fIsPCDATA: Boolean;
      fIsRequired: Boolean;
      fName: Utf8String;
      procedure set_Parent(const aValue: IXmlDtdContentParticle);
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create; reintroduce; overload;
      constructor Create(const aName: Utf8String); reintroduce; overload;
      constructor CreatePCDATA;
      property AllowMultiple: Boolean read fAllowMultiple write fAllowMultiple;
      property Element: IXmlDtdElement read fElement write fElement;
      property IsPCDATA: Boolean read fIsPCDATA write fIsPCDATA;
      property IsRequired: Boolean read fIsRequired write fIsRequired;
      property Name: Utf8String read fName;
      property Parent: IXmlDtdContentParticle read get_Parent write set_Parent;
    end;



    TXmlDtdContentParticleList = class(TXmlDtdContentParticle, IXmlDtdContentParticleList, IXmlHasNodes)
    protected // IXmlHasNodes
      function get_Nodes: IXmlNodeList;

    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDtdContentParticleList
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): IXmlDtdContentParticle;
      function get_ListType: TXmlDtdContentParticleListType;

    private
      fItems: IXmlNodeList;
      fListType: TXmlDtdContentParticleListType;

    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create; reintroduce;
      procedure Delete(const aIndex: Integer); overload;
      property Count: Integer read get_Count;
      property ItemList: IXmlNodeList read fItems;
      property Items[const aIndex: Integer]: IXmlDtdContentParticle read get_Item; default;
      property ListType: TXmlDtdContentParticleListType read fListType write fListType;
    end;




implementation

  uses
    Deltics.InterfacedObjects;



{ TXmlDtdContentParticle ------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticle.Create;
  begin
    inherited Create(xmlDtdContentParticle);

    fIsRequired     := TRUE;
    fAllowMultiple  := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticle.Create(const aName: Utf8String);
  begin
    Create;

    fName := aName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticle.CreatePCDATA;
  begin
    Create;

    fIsPCDATA := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_AllowMultiple: Boolean;
  begin
    result := fAllowMultiple;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_Element: IXmlDtdElement;
  var
    n: IXmlNode;
  begin
    result := NIL;

    n := self;
    while Assigned(n) and (n.NodeType <> xmlDtdElement) do
      n := n.Parent;

    if Assigned(n) then
      result := n as IXmlDtdElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_IsPCDATA: Boolean;
  begin
    result := fIsPCDATA;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_IsRequired: Boolean;
  begin
    result := fIsRequired;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_Parent: IXmlDtdContentParticle;
  var
    p: IXmlNode;
  begin
    p := inherited Parent;

    if (p.NodeType = xmlDtdContentParticle) then
      result := p as IXmlDtdContentParticle
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticle.set_Parent(const aValue: IXmlDtdContentParticle);
  begin
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticle.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdContentParticle absolute aSource;
  begin
    inherited;

    fAllowMultiple  := src.fAllowMultiple;
    fIsPCDATA       := src.fIsPCDATA;
    fIsRequired     := src.fIsRequired;
    fName           := src.fName;

    if Assigned(src.fElement) then
      fElement := src.fElement.Clone as IXmlDtdElement;
  end;






{ TXmlDtdContentParticleList --------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticleList.Create;
  begin
    inherited Create(xmlDtdContentParticleList);

    fItems := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticleList.Delete(const aIndex: Integer);
  var
    list: TXmlNodeList;
  begin
    InterfaceCast(fItems, TXmlNodeList, list);
    list.Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticleList.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdContentParticleList absolute aSource;
  begin
    inherited;

    fListType := src.fListType;

    TXmlNodeList.Assign(src.fItems, fItems);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Item(const aIndex: Integer): IXmlDtdContentParticle;
  begin
    result := fItems[aIndex] as IXmlDtdContentParticle;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_ListType: TXmlDtdContentParticleListType;
  begin
    result := fListType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Name: Utf8String;
  begin
    result := '#dtd-content-particle-list';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Nodes: IXmlNodeList;
  begin
    result := fItems;
  end;




end.
