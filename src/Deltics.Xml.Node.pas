
{$i deltics.xml.inc}

  unit Deltics.Xml.Node;


interface

  uses
    Deltics.Xml.Types;


  type
    TXmlNode = class
    private
      fNodeType: TXmlNodeType;
      fParent: TXmlNode;
//      function get_AsAttribute: TXmlAttribute;
//      function get_AsElement: TXmlElement;
//      function get_Document: TXmlDocument;
    protected
      constructor Create(const aNodeType: TXmlNodeType);
      function get_Index: Integer;
      function get_Name: Utf8String; virtual;
      function get_Path: Utf8String;
      function get_Text: Utf8String; virtual;
      function get_Xml: Utf8String; virtual; abstract;
      procedure set_Text(const Value: Utf8String); virtual;
      procedure Assign(const aSource: TXmlNode); virtual; abstract;
      procedure DeleteNode(const aNode: TXmlNode); virtual;
    public
      destructor Destroy; override;
      procedure Delete;
      function SelectAttribute(const aPath: Utf8String): TXmlAttribute; overload;
      function SelectAttribute(const aElementPath: Utf8String; const aAttribute: Utf8String): TXmlAttribute; overload;
      function SelectElement(const aPath: Utf8String): TXmlElement;
      function SelectNode(const aPath: Utf8String): TXmlNode;
      function SelectNodes(const aPath: Utf8String): IXmlNodeSelection;
      function Clone: TXmlNode;
//      property AsAttribute: TXmlAttribute read get_AsAttribute;
//      property AsElement: TXmlElement read get_AsElement;
//      property Document: TXmlDocument read get_Document;
      property Index: Integer read get_Index;
      property Name: Utf8String read get_Name;
      property NodeType: TXmlNodeType read fNodeType;
      property Parent: TXmlNode read fParent;
      property Path: Utf8String read get_Path;
      property Text: Utf8String read get_Text;
      property Xml: Utf8String read get_Xml;
    end;




implementation


{ TXmlNode --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNode.Create(const aNodeType: TXmlNodeType);
  begin
    inherited Create;
    fNodeType := aNodeType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlNode.Destroy;
  begin
    inherited;
  end;


//  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
//  function TXmlNode.get_AsAttribute: TXmlAttribute;
//  begin
//    if NOT (fNodeType = xmlAttribute) then
//      raise EConvertError.Create('Xml node is not an attribute');
//
//    result := TXmlAttribute(self);
//  end;
//
//
//  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
//  function TXmlNode.get_AsElement: TXmlElement;
//  begin
//    if NOT (fNodeType = xmlElement) then
//      raise EConvertError.Create('Xml node is not an element');
//
//    result := TXmlElement(self);
//  end;
//
//
//  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
//  function TXmlNode.get_Document: TXmlDocument;
//  var
//    node: TXmlNode absolute result;
//  begin
//    node := self;
//
//    while Assigned(node) and (node.NodeType <> xmlDocument) do
//      node := node.Parent;
//  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Index: Integer;
  var
    parent: TXmlElement;
  begin
    result := -1;

    if fParent is TXmlElement then
    begin
      parent := TXmlElement(fParent);
      result := parent.Nodes.fItems.IndexOf(self);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Name: Utf8String;
  begin
    result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Path: Utf8String;
  begin
    if Assigned(Parent) then
      result := Parent.Path + '/' + Name
    else
      result := Name;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Text: Utf8String;
  begin
    result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.set_Text(const Value: Utf8String);
  begin
    // NO-OP
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.Clone: TXmlNode;
  begin
    result := TXmlElement(ClassType.Create);
    result.Assign(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.Delete;
  begin
    if NOT Assigned(Parent) then
      raise Exception.Create('Cannot delete orphan node');

    Parent.DeleteNode(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.DeleteNode(const aNode: TXmlNode);
  begin
    // NO-OP
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectAttribute(const aPath: Utf8String): TXmlAttribute;
  var
    node: TXmlNode;
  begin
    node := SelectNode(aPath);

    if NOT Assigned(node) or (node.NodeType <> xmlAttribute) then
      raise Exception.CreateFmt('''%s'' is not a valid attribute path', [aPath]);

    result := TXmlAttribute(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectAttribute(const aElementPath: Utf8String;
                                    const aAttribute: Utf8String): TXmlAttribute;
  var
    node: TXmlNode;
  begin
    node := SelectNode(aElementPath + '@' + aAttribute);

    if NOT Assigned(node) or (node.NodeType <> xmlAttribute) then
      raise Exception.CreateFmt('''%s'' is not a valid attribute path', [aElementPath + '@' + aAttribute]);

    result := TXmlAttribute(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectElement(const aPath: Utf8String): TXmlElement;
  var
    node: TXmlNode;
  begin
    node := SelectNode(aPath);
    if NOT Assigned(node) or (node.NodeType <> xmlElement) then
      raise Exception.CreateFmt('''%s'' is not a valid element path', [aPath]);

    result := TXmlElement(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectNode(const aPath: Utf8String): TXmlNode;
  var
    element: TXmlElement absolute result;
    i: Integer;
    query: Utf8String;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    subquery: Utf8String;
    parts: TStringArray;
    elementName: Utf8String;
    attrName: Utf8String;
  begin
    result  := NIL;
    query   := aPath;

    if (query <>'') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(Document.Nodes);
      System.Delete(query, 1, 1);
    end
    else case NodeType of
      xmlElement  : elements := TXmlElementSelection.Create(TXmlElement(self).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(TXmlDocument(self).Nodes);
    else
      EXIT;
    end;

    template := TStringTemplate.Create('', '{', '}');
    match    := TStringList.Create;
    try
      if template.Matches('{root}/{subquery}', STR.FromUtf8(query), match) then
      begin
        elementName := Utf8.FromString(match.Values['root']);
        subquery    := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = elementName) then
          begin
            result := elements[i].SelectNode(subquery);
            if Assigned(result) then
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

        result := elements.ItemByName(elementName);

        if Assigned(result) and (attrName <> '') then
        begin
          if (result.NodeType <> xmlElement) then
            raise Exception.CreateFmt('''%s'' is not an element', [result.Path]);

          result := element.Attributes.ByName(attrName);
        end;
      end;

    finally
      match.Free;
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectNodes(const aPath: Utf8String): IXmlNodeSelection;
  var
    i: Integer;
    query: Utf8String;
    selection: TXmlNodeSelection;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    selection := TXmlNodeSelection.Create;
    result    := selection;

    query := aPath;
    if (query <> '') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(Document.Nodes);
      System.Delete(query, 1, 1);
    end
    else case NodeType of
      xmlElement  : elements := TXmlElementSelection.Create(TXmlElement(self).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(TXmlDocument(self).Nodes);
    else
      EXIT;
    end;

    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.Create;
    try
      if template.Matches(STR.FromUtf8(query), match) then
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
      match.Free;
      template.Free;
    end;
  end;







end.
