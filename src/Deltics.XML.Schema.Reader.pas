
{$i deltics.xml.inc}

  unit Deltics.Xml.Schema.Reader;


interface

  uses
    Deltics.Xml,
    Deltics.Xml.Schema;


  type
    TXsdReader = class
    private
      fNamespace: Utf8String;
      function QName(const aName: Utf8String): Utf8String;
      function ReadAttribute(const aElement: TXmlElement; const aAttributeName: Utf8String): Utf8String;
      function ReadElement(const aOwner: TXsdDeclaration; const aNode: TXmlElement): TXsdElement;
      procedure ReadElements(const aContainer: TXmlElement; const aList: TXsdElementList);
    public
      procedure ReadXsd(const aXsd: TXmlDocument; const aSchema: TXsdSchema);
    end;


implementation

  uses
    Deltics.Strings,
    Deltics.Xml.Selections,
    Deltics.Xml.Schema.Consts;


{ TXsdReader ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdReader.QName(const aName: Utf8String): Utf8String;
  begin
    if (Pos(':', STR.FromUtf8(aName)) = 0) and (fNamespace <> '') then
      result := fNamespace + ':' + aName
    else
      result := aName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdReader.ReadAttribute(const aElement: TXmlElement;
                                    const aAttributeName: Utf8String): Utf8String;
  var
    attr: TXmlAttribute;
  begin
    attr := aElement.Attributes.ByName(QName(aAttributeName), FALSE);
    if Assigned(attr) then
      result := attr.Value
    else
      result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXsdReader.ReadElement(const aOwner: TXsdDeclaration;
                                  const aNode: TXmlElement): TXsdElement;
  begin
    result := TXsdElement.Create(aOwner)
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdReader.ReadElements(const aContainer: TXmlElement; const aList: TXsdElementList);
  var
    i: Integer;
//    decls: IXmlElementSelection;
    node: TXmlNode;
    element: TXsdElement;
  begin
//    decls := TXmlElementSelection.Create(aContainer.Nodes);
//    decls.WhereNameEquals(QName('element'));

    for i := 0 to Pred(aContainer.Nodes.Count) do
    begin
      node := aContainer.Nodes[i];
      if (node.Name <> QName(XS_element)) then
        CONTINUE;

      element := ReadElement(aList.Owner, node.AsElement);
      aList.Add(element);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXsdReader.ReadXsd(const aXsd: TXmlDocument; const aSchema: TXsdSchema);
  var
    i: Integer;
    s: Utf8String;
    ns: TXmlNamespace;
  begin
    aSchema.Clear;

    // Read namespaces and establish the schema namespace itself - if any

    for i := 0 to Pred(aXsd.Root.Namespaces.Count) do
    begin
      ns := aXsd.Root.Namespaces[i];
      if (ns.Prefix = aXsd.Root.NamespaceName) then
        fNamespace := ns.Prefix;

      aSchema.AddNamespace(ns.Prefix, ns.Name);
    end;
    aSchema.Namespace := fNamespace;

    // Read attribute and element FormDefault settings

    s := ReadAttribute(aXsd.Root, XS_attributeFormDefault);
    case STR.IndexOf(STR.FromUtf8(s), ['',
                                       XS_formDefaultQualified,
                                       XS_formDefaultUnqualified]) of
      0, 1  : aSchema.AttributeFormDefault := fdQualified;
      2     : aSchema.AttributeFormDefault := fdUnqualified;
    else
//      aSchema.AddWarning('Schema attributeFormDefault value not recognised (%s).  Using ''%s'' instead', [s, 'unqualified']);
    end;

    s := ReadAttribute(aXsd.Root, XS_elementFormDefault);
    case STR.IndexOf(STR.FromUtf8(s), ['',
                                       XS_formDefaultQualified,
                                       XS_formDefaultUnqualified]) of
      0, 1  : aSchema.AttributeFormDefault := fdQualified;
      2     : aSchema.AttributeFormDefault := fdUnqualified;
    else
//      aSchema.AddWarning('Schema elementFormDefault value not recognised (%s).  Using ''%s'' instead', [s, 'unqualified']);
    end;

    ReadElements(aXsd.Root, aSchema.RootElements);
  end;




end.
