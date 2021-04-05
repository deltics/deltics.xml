
{$i deltics.xml.inc}

  unit Deltics.Xml.XPath;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Selections;


  type
    XPath = class
    private
      class function SelectNodes(const aContext: IXmlNode; const aPath: Utf8String; const aSelectionClass: TXmlNodeSelectionClass): IXmlNodeSelection; overload;
    public
      class function SelectElements(const aContext: IXmlNode; const aPath: Utf8String): IXmlElementSelection;
      class function SelectNode(const aContext: IXmlNode; const aPath: Utf8String): IXmlNode; overload;
      class function SelectNode(const aContext: IXmlNode; const aPath: Utf8String; var aNode: IXmlNode): Boolean; overload;
      class function SelectNodes(const aContext: IXmlNode; const aPath: Utf8String): IXmlNodeSelection; overload;
    end;



implementation

  uses
    Deltics.Exceptions,
    Deltics.StringLists,
    Deltics.Strings,
    Deltics.StringTemplates,
    Deltics.Xml.Types;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XPath.SelectElements(const aContext: IXmlNode;
                                      const aPath: Utf8String): IXmlElementSelection;
  begin
    result := SelectNodes(aContext, aPath, TXmlElementSelection) as IXmlElementSelection;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XPath.SelectNode(const aContext: IXmlNode;
                                  const aPath: Utf8String): IXmlNode;
  begin
    SelectNode(aContext, aPath, result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XPath.SelectNode(const aContext: IXmlNode;
                                  const aPath: Utf8String;
                                  var   aNode: IXmlNode): Boolean;
  var
    i: Integer;
    element: IXmlElement;
    node: IXmlNode;
    query: Utf8String;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: IStringList;
    subquery: Utf8String;
    parts: StringArray;
    elementName: Utf8String;
    attrName: Utf8String;
  begin
    result  := FALSE;
    aNode   := NIL;
    query   := aPath;

    if (query <>'') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(aContext.Document.RootElement);
      System.Delete(query, 1, 1);
    end
    else case aContext.NodeType of
      xmlElement  : elements := TXmlElementSelection.Create((aContext as IXmlElement).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(aContext.Document.RootElement);
    else
      EXIT;
    end;

    template := TStringTemplate.Create('', '{', '}');
    match    := TStringList.CreateManaged;
    try
      if template.Matches('{root}/{subquery}', STR.FromUtf8(query), match.List) then
      begin
        elementName := Utf8.FromString(match.Values['root']);
        subquery    := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = elementName) then
          begin
            aNode   := elements[i].SelectNode(subquery);
            result  := Assigned(aNode);
            if result then
              BREAK;
          end;
      end
      else
      begin
        case STR.Split(STR.FromUtf8(query), '@', parts) of
          1 : begin
                elementName := query;
                attrName    := ''
              end;

          2 : begin
                elementName := Utf8.FromString(parts[0]);
                attrName    := Utf8.FromString(parts[1]);
              end;
        end;

        node    := elements.ItemByName(elementName);
        result  := Assigned(node) and (attrName = '');
        if result then
        begin
          aNode := node;
          EXIT;
        end;

        if (node.NodeType <> xmlElement) then
          raise Exception.CreateFmt('''%s'' is not an element', [node.Path]);

        aNode   := element.Attributes.ItemByName(attrName);
        result  := Assigned(aNode);
      end;

    finally
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XPath.SelectNodes(const aContext: IXmlNode;
                                   const aPath: Utf8String;
                                   const aSelectionClass: TXmlNodeSelectionClass): IXmlNodeSelection;
  var
    i: Integer;
    query: Utf8String;
    selection: TXmlNodeSelection;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: IStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    selection := aSelectionClass.Create;
    result    := selection;

    query := aPath;
    if (query <> '') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(aContext.Document.RootElement);
      System.Delete(query, 1, 1);
    end
    else case aContext.NodeType of
      xmlElement  : elements := TXmlElementSelection.Create((aContext as IXmlElement).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create((aContext as IXmlDocument).RootElement);
    else
      EXIT;
    end;

    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.CreateManaged;
    try
      if template.Matches(STR.FromUtf8(query), match.List) then
      begin
        root      := Utf8.FromString(match.Values['root']);
        subquery  := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = root) then
            selection.Add(elements[i].SelectNodes(subquery));
      end
      else
        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = query) then
            selection.Add(elements[i]);

    finally
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XPath.SelectNodes(const aContext: IXmlNode;
                                   const aPath: Utf8String): IXmlNodeSelection;
  begin
    result := SelectNodes(aContext, aPath, TXmlNodeSelection);
  end;



end.
