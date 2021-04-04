
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Fragment;


interface

  uses
    Classes,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlFragment = class(TXmlNode, IXmlFragment)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlFragment
      function get_Nodes: IXmlNodeList;
    public
      procedure Add(const aNode: IXmlNode);
      procedure Clear;

    private
      fNodes: IXmlNodeList;
    protected
      procedure Assign(const aSource: TXmlNode); override;
      function Accepts(const aNode: TXmlNode): Boolean; override;
    public
      constructor Create; overload;
//      procedure LoadFromFile(const aFilename: String);
//      procedure LoadFromStream(const aStream: TStream);
//      function SelectNode(const aQuery: Utf8String): TXmlNode;
//      function SelectNodes(const aQuery: Utf8String): IXmlNodeSelection;
      property Nodes: IXmlNodeList read fNodes;
    end;


implementation

  uses
    Deltics.InterfacedObjects,
    Deltics.Xml.Types;


{ TXmlFragment ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlFragment.Create;
  begin
    inherited Create(xmlFragment);

    fNodes    := TXmlNodeList.Create(self);
  end;


  function TXmlFragment.get_Name: Utf8String;
  begin
    result := '#document fragment';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFragment.get_Nodes: IXmlNodeList;
  begin
    result := fNodes;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFragment.Accepts(const aNode: TXmlNode): Boolean;
  begin
    result := aNode.NodeType in [xmlElement, xmlProcessingInstruction, xmlComment,
                                  xmlText, xmlCDATA, xmlEntityReference];
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Add(const aNode: IXmlNode);
  var
    nodes: TXmlNodeList;
  begin
    InterfaceCast(fNodes, TXmlNodeList, nodes);

    nodes.Add(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Assign(const aSource: TXmlNode);
  var
    src: TXmlFragment absolute aSource;
  begin
    TXmlNodeList.Assign(src.Nodes, fNodes);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Clear;
  var
    nodes: TXmlNodeList;
  begin
    InterfaceCast(fNodes, TXmlNodeList, nodes);

    nodes.Clear;
  end;


(*
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.LoadFromFile(const aFilename: String);
  var
    strm: TFileStream;
  begin
    strm := TFileStream.Create(aFilename, fmOpenRead);
    try
      LoadFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.LoadFromStream(const aStream: TStream);
  var
    reader: TXmlReader;
  begin
    reader := TXmlReader.Create;
    try
      reader.LoadFragment(self, aStream);

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFragment.SelectNode(const aQuery: Utf8String): TXmlNode;
  var
    i: Integer;
    query: Utf8String;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    result  := NIL;
    query   := aQuery;

    if (query <> '') and (query[1] = '/') then
      System.Delete(query, 1, 1);

    elements  := TXmlElementSelection.Create(fNodes);
    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.Create;
    try
      if template.Matches(STR.FromUtf8(query), match) then
      begin
        root      := Utf8.FromString(match.Values['root']);
        subquery  := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = root) then
          begin
            result := elements[i].SelectNode(subquery);
            if Assigned(result) then
              BREAK;
          end;
      end
      else
        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = query) then
          begin
            result := elements[i];
            BREAK;
          end;

    finally
      match.Free;
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFragment.SelectNodes(const aQuery: Utf8String): IXmlNodeSelection;
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
    query     := aQuery;

    if (query <> '') and (query[1] = '/') then
      System.Delete(query, 1, 1);

    elements  := TXmlElementSelection.Create(fNodes);
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
*)



end.
