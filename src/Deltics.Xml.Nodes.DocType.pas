
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.DocType;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Types;


  type
    {
      `<!DOCTYPE` <root-element> <scope [`PUBLIC`|`SYSTEM`]> "<fpi>" ["<uri>"] `[` <internal-subset> `]>`

      fpi = Formal Public Identifier
    }
    TXmlDocType = class(TXmlNode, IXmlDocType)
    protected // IXmlNode
      function get_Name: Utf8String; override;
    protected // IXmlDocType
      function get_Fpi: Utf8String;
      function get_InternalSubset: IXmlNodeList;
      function get_RootElement: Utf8String;
      function get_Scope: TXmlDocTypeScope;
      function get_Uri: Utf8String;

    private
      fFpi: Utf8String;
      fInternalSubset: IXmlNodeList;
      fRootElement: Utf8String;
      fScope: TXmlDocTypeScope;
      fUri: Utf8String;
    public
      constructor Create(const aScope: TXmlDocTypeScope; const aRootElement: Utf8String; const aFpi: Utf8String = ''; const aUri: Utf8String = '');
      procedure Assign(const aSource: TXmlNode); override;
      property Fpi: Utf8String read fFpi;
      property InternalSubset: IXmlNodeList read fInternalSubset;
      property RootElement: Utf8String read fRootElement;
      property Scope: TXmlDocTypeScope read fScope;
      property Uri: Utf8String read fUri;
    end;


    XmlDocType = class
    public
      class function CreateInternal(const aRootElement: Utf8String): IXmlDocType;
      class function CreatePublic(const aRootElement, aFpi, aUri: Utf8String): IXmlDocType;
      class function CreateSystem(const aRootElement, aFpi: Utf8String): IXmlDocType;
    end;



implementation

  uses
    Deltics.InterfacedObjects;




  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocType.CreateInternal(const aRootElement: Utf8String): IXmlDocType;
  begin
    result := TXmlDocType.Create(dtInternal, aRootElement);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocType.CreatePublic(const aRootElement, aFpi, aUri: Utf8String): IXmlDocType;
  begin
    result := TXmlDocType.Create(dtPUBLIC, aRootElement, afpi, aUri);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocType.CreateSystem(const aRootElement, aFpi: Utf8String): IXmlDocType;
  begin
    result := TXmlDocType.Create(dtSYSTEM, aRootElement, aFpi);
  end;








{ TXmlDocType ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocType.Create(const aScope: TXmlDocTypeScope;
                                 const aRootElement: Utf8String;
                                 const aFpi: Utf8String;
                                 const aUri: Utf8String);
  begin
    inherited Create(Deltics.Xml.Types.xmlDocType);

    fScope        := aScope;
    fRootElement  := aRootElement;
    fFpi          := aFpi;
    fUri          := aUri;

    if fScope <> dtInternal then
      fInternalSubset := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_Fpi: Utf8String;
  begin
    result := fFpi;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_Name: Utf8String;
  begin
    result := '!DOCTYPE';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_InternalSubset: IXmlNodeList;
  begin
    result := fInternalSubset;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_RootElement: Utf8String;
  begin
    result := fRootElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_Scope: TXmlDocTypeScope;
  begin
    result := fScope;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_Uri: Utf8String;
  begin
    result := fUri;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocType.Assign(const aSource: TXmlNode);
  var
    src: TXmlDocType absolute aSource;
    subset: TXmlNodeList;
  begin
    inherited;

    InterfaceCast(fInternalSubset, TXmlNodeList, subset);
    subset.Assign(src.InternalSubset);

    fScope        := src.Scope;
    fRootElement  := src.RootElement;
    fFpi          := src.Fpi;
    fUri          := src.Uri;
  end;





end.
