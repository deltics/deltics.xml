
{$i deltics.xml.inc}

  unit Deltics.Xml.Schema;


interface

  uses
    Contnrs,
    Deltics.Xml,
    Deltics.Xml.Schema.Consts;


  type
    TXsdElementType = (
                       xsdUnknown,
                       xsdSchema,
                       xsdImport,
                       xsdElement,
                       xsdChoice,
                       xsdGroup,
                       xsdSequence,
                       xsdAll
                      );

    TXsdFormDefault = (
                       fdDefault,
                       fdQualified,
                       fdUnqualified
                      );


    TXsdDeclaration = class;
      TXsdSchema = class;
      TXsdAttribute = class;
      TXsdElement = class;
      TXsdRestriction = class;
      TXsdSimpleType = class;
      TXsdComplexType = class;

    TXsdDeclarationList = class;
      TXsdElementList = class;


    TXsdDeclaration = class
    private
      fOwner: TXsdDeclaration;
      function get_Schema: TXsdSchema;
      function NameInSchema(const aValue: Utf8String): Utf8String;
    public
      constructor Create(const aOwner: TXsdDeclaration); reintroduce;
      property Owner: TXsdDeclaration read fOwner;
      property Schema: TXsdSchema read get_Schema;
    end;


    TXsdSchema = class(TXsdDeclaration)
    private
      fAttributeFormDefault: TXsdFormDefault;
      fElementFormDefault: TXsdFormDefault;
      fID: Utf8String;
      fNamespace: Utf8String;
      fNamespaceDeclarations: TXMLAttributeList;
      fNamespaces: TXMLNamespaceBindings;
      fRootElements: TXsdElementList;
      fTargetNamespace: TXMLNamespace;

    public
      constructor Create; reintroduce;
      destructor Destroy; override;
      procedure AddNamespace(const aPrefix, aName: Utf8String);
      procedure Clear;
      procedure LoadFromFile(const aFilename: String);
      procedure SetTargetNamespace(const aName: Utf8String);
      property AttributeFormDefault: TXsdFormDefault read fAttributeFormDefault write fAttributeFormDefault;
      property ElementFormDefault: TXsdFormDefault read fAttributeFormDefault write fAttributeFormDefault;
      property ID: Utf8String read fID write fID;
      property Namespace: Utf8String read fNamespace write fNamespace;
      property Namespaces: TXMLNamespaceBindings read fNamespaces;
      property RootElements: TXsdElementList read fRootElements;
      property TargetNamespace: TXMLNamespace read fTargetNamespace;
    end;


    TXsdImport = class(TXsdDeclaration)
    private
      fSchemaLocation: Utf8String;
      fID: Utf8String;
      fNamespace: Utf8String;
    public
      property SchemaLocation: Utf8String read fSchemaLocation write fSchemaLocation;
      property ID: Utf8String read fID write fID;
      property Namespace: Utf8String read fNamespace write fNamespace;
    end;


    TXsdAttribute = class(TXsdDeclaration)
    end;


    TXsdElement = class(TXsdDeclaration)
    private
      fDataType: TXsdDataType;
      fDataTypeName: Utf8String;
      fName: Utf8String;
      procedure set_DataType(const aValue: TXsdDataType);
      procedure set_DataTypeName(const aValue: Utf8String);
    public
      property DataType: TXsdDataType read fDataType write set_DataType;
      property DataTypeName: Utf8String read fDataTypeName write set_DataTypeName;
      property Name: Utf8String read fName write fName;
    end;


    TXsdRestriction = class(TXsdDeclaration)
    end;


    TXsdSimpleType = class(TXsdDeclaration)
    end;


    TXsdComplexType = class(TXsdDeclaration)
    end;


    TXsdDeclarationList = class
    private
      fItems: TObjectList;
      fOwner: TXsdDeclaration;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): TXsdDeclaration;
    protected
      procedure Add(const aItem: TXsdDeclaration); reintroduce;
      procedure InternalAdd(const aItem: TXsdDeclaration);
    public
      constructor Create(const aOwner: TXsdDeclaration);
      destructor Destroy; override;
      procedure Clear;
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: TXsdDeclaration read get_Item; default;
      property Owner: TXsdDeclaration read fOwner;
    end;


      TXsdElementList = class(TXsdDeclarationList)
      private
        function get_Item(const aIndex: Integer): TXsdElement; reintroduce;
      public
        procedure Add(const aElement: TXsdElement); reintroduce; overload;
        function Add(const aName: Utf8String): TXsdElement; overload;
        property Items[const aIndex: Integer]: TXsdElement read get_Item; default;
      end;


implementation

  uses
  {$ifdef InlineMethodsSupported}
    Classes,
  {$endif}
    SysUtils,
    Deltics.Strings,
    Deltics.Xml.Schema.Reader;



{ TXsdDeclaration -------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXsdDeclaration.Create(const aOwner: TXsdDeclaration);
  begin
    inherited Create;

    fOwner := aOwner;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdDeclaration.get_Schema: TXsdSchema;
  begin
    if (ClassType = TXsdSchema) then
      result := TXsdSchema(self)
    else if Assigned(Owner) then
      result := Owner.Schema
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdDeclaration.NameInSchema(const aValue: Utf8String): Utf8String;
  var
    parts: UnicodeStringArray;
  begin
    case Wide.Split(Wide.FromUtf8(aValue), ':', parts) of
      1 : result := aValue;
      2 : if (parts[0] = Wide.FromUtf8(Schema.Namespace)) then
            result:= Utf8.FromWIDE(parts[1])
          else
            result := aValue;
    else
      raise Exception.Create('Unexpected error');
    end;
  end;









{ TXsdSchema ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXsdSchema.Create;
  begin
    inherited Create(NIL);

    fNamespaceDeclarations  := TXMLAttributeList.Create(NIL);
    fRootElements           := TXsdElementList.Create(self);

    fNamespaces   := TXMLNamespaceBindings.Create(fNamespaceDeclarations);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXsdSchema.Destroy;
  begin
    FreeAndNIL(fNamespaces);
    FreeAndNIL(fRootElements);
    FreeAndNIL(fNamespaceDeclarations);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdSchema.AddNamespace(const aPrefix, aName: Utf8String);
  begin
    fNamespaces.Add('xmlns:' + aPrefix, aName);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdSchema.Clear;
  begin
    fAttributeFormDefault := fdDefault;
    fElementFormDefault   := fdDefault;
    fID                   := '';
    fNamespace            := '';
    fTargetNamespace      := NIL;

    fNamespaceDeclarations.Clear;
    fRootElements.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdSchema.LoadFromFile(const aFilename: String);
  var
    xsd: TXMLDocument;
    reader: TXsdReader;
  begin
    xsd := TXMLDocument.CreateFromFile(aFilename);
    try
      reader := TXsdReader.Create;
      try
        Clear;
        reader.ReadXsd(xsd, self);

        // TODO: Validate;

      finally
        reader.Free;
      end;

    finally
      xsd.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdSchema.SetTargetNamespace(const aName: Utf8String);
  begin
    fTargetNamespace := fNamespaceDeclarations.ByValue(aName).AsNamespace;
  end;








{ TXsdElement ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdElement.set_DataType(const aValue: TXsdDataType);
  begin
    if (fDataType = aValue) then
      EXIT;

    if (aValue = xsCustom) and (fDataType <> xsCustom) then
      fDataTypeName := '';

    fDataType := aValue;

    if (aValue <> xsCustom)  then
      fDataTypeName := XS_datatypeName[aValue];
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdElement.set_DataTypeName(const aValue: Utf8String);
  var
    dt: TXsdDataType;
  begin
    fDataTypeName := NameInSchema(aValue);

    for dt := Low(TXsdDataType) to High(TXsdDataType) do
      if (fDataTypeName = XS_datatypeName[dt]) then
      begin
        fDataType := dt;
        EXIT;
      end;

    fDataType := xsCustom;
  end;









{ TXsdDeclarationList ---------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXsdDeclarationList.Create(const aOwner: TXsdDeclaration);
  begin
    inherited Create;

    fItems  := TObjectList.Create(TRUE);
    fOwner  := aOwner;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXsdDeclarationList.Destroy;
  begin
    FreeAndNIL(fItems);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdDeclarationList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdDeclarationList.get_Item(const aIndex: Integer): TXsdDeclaration;
  begin
    result := TXsdDeclaration(fItems[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdDeclarationList.Clear;
  begin
    fItems.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdDeclarationList.InternalAdd(const aItem: TXsdDeclaration);
  begin
    fItems.Add(aItem);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdDeclarationList.Add(const aItem: TXsdDeclaration);
  begin
    // TODO: Implement "CanAdd()" item filter as per XML.nodelist
    InternalAdd(aItem);
  end;







{ TXsdElementList -------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdElementList.Add(const aElement: TXsdElement);
  begin
    InternalAdd(aElement);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdElementList.Add(const aName: Utf8String): TXsdElement;
  begin
    result := TXsdElement.Create(Owner);
    result.Name     := aName;
    result.DataType := xsString;

    InternalAdd(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdElementList.get_Item(const aIndex: Integer): TXsdElement;
  begin
    result := TXsdElement(inherited get_Item(aIndex));
  end;






end.
