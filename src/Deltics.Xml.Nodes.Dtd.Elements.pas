
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Dtd.Elements;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Nodes.Dtd,
    Deltics.Xml.Types;


  type
    TXmlDtdElement = class(TXmlDtdDeclaration, IXmlDtdElement)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDtdElement
      function get_Category: TXmlDtdElementCategory;
      function get_Content: IXmlDtdContentParticleList;

    private
      fCategory: TXmlDtdElementCategory;
      fContent: IXmlDtdContentParticleList;
      fName: Utf8String;
      procedure SetElement(const aParticle: IXmlDtdContentParticle);

    protected
      procedure Assign(const aSource: TXmlNode); override;

    public
      constructor Create(const aName: Utf8String); overload;
      constructor Create(const aName: Utf8String; const aContent: IXmlDtdContentParticleList); overload;
      constructor CreateANY(const aName: Utf8String);
      constructor CreateEMPTY(const aName: Utf8String);
      property Category: TXmlDtdElementCategory read fCategory;
      property Content: IXmlDtdContentParticleList read fContent;
      property Name: Utf8String read fName;
    end;



implementation

  uses
    Deltics.InterfacedObjects,
    Deltics.Xml.Nodes.Dtd.ContentParticles;



{ TXmlDtdElementDeclaration ----------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElement.Create(const aName: Utf8String);
  begin
    inherited Create(xmlDtdElement);

    fName     := aName;
    fCategory := ecMixed;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElement.Create(const aName: Utf8String;
                                    const aContent: IXmlDtdContentParticleList);
  var
    content_: TXmlDtdContentParticleList;
  begin
    Create(aName);

    fContent := aContent;

    if NOT Assigned(Content) then
      EXIT;

    if (Content.Count > 0) and (Content[0].IsPCDATA) then
    begin
      // The content list contains at least one initial #PCDATA in addition to
      //  further children.  We can remove the initial #PCDATA particle as this
      //  is required/assumed for MIXED elements

      InterfaceCast(Content, TXmlDtdContentParticleList, content_);
      content_.Delete(0);

      // If there are no other children then we can dispose of the content
      //  list entirely.  Either way our work is done.

      if Content.Count = 0 then
        fContent := NIL;
    end
    else
      fCategory := ecChildren;

    if Assigned(Content) then
      SetElement(Content);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElement.CreateANY(const aName: Utf8String);
  begin
    Create(aName);

    fCategory := ecAny;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElement.CreateEMPTY(const aName: Utf8String);
  begin
    Create(aName);

    fCategory := ecEmpty;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdElement.get_Category: TXmlDtdElementCategory;
  begin
    result := fCategory;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdElement.get_Content: IXmlDtdContentParticleList;
  begin
    result := fContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdElement.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdElement.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdElement absolute aSource;
  begin
    inherited;

    fName     := src.Name;
    fCategory := src.Category;

    if Assigned(src.Content) then
    begin
      fContent := src.Content.Clone as IXmlDtdContentParticleList;
      SetElement(fContent);
    end
    else
      fContent := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdElement.SetElement(const aParticle: IXmlDtdContentParticle);
  var
    i: Integer;
    particle: TXmlDtdContentParticle;
    list: IXmlDtdContentParticleList;
  begin
    InterfaceCast(aParticle, TXmlDtdContentParticle, particle);

    particle.Element := self;

    if particle.NodeType <> xmlDtdContentParticleList then
      EXIT;

    list := aParticle as IXmlDtdContentParticleList;

    for i := 0 to Pred(list.Count) do
      SetElement(list[i]);
  end;








end.

