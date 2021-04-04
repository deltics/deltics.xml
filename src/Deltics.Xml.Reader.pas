
{$i deltics.xml.inc}

  unit Deltics.Xml.Reader;


interface

  uses
    Classes,
    SysUtils,
    Deltics.InterfacedObjects,
    Deltics.IO.Streams,
    Deltics.StringLists,
    Deltics.Strings,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Parser;


  type
    TXmlReader = class;


    EXmlReader = class(Exception);


    TXmlReader = class(TComInterfacedObject)
    private
      fParser: IXmlReader;
    protected
      function ReadCDATA: IXmlCDATA;
      function ReadComment: IXmlComment;
      function ReadDocType: IXmlDocType;
      function ReadElement: IXmlElement;
      function ReadInternalDtd(const aRootElement: Utf8String = ''): IXmlDocType;
      function ReadNode: IXmlNode;
      function ReadProcessingInstruction: IXmlNode;
      function ReadText: IXmlText;
      function ReadDtdAttList: IXmlDtdAttributeList;
      function ReadDtdContentParticles: IXmlDtdContentParticleList;
      function ReadDtdDeclaration: IXmlDtdDeclaration;
      function ReadDtdElement: IXmlDtdElement;
      function ReadDtdEntity: IXmlDtdEntity;
      function ReadDtdNotation: IXmlDtdNotation;
      procedure UnexpectedNode(const aNode: IXmlNode);
    public
      class procedure LoadDocument(const aDocument: IXmlDocument; const aStream: TStream; const aErrors: IStringList; const aWarnings: IStringList);
      function LoadFragment(const aStream: TStream; const aErrors: IStringList; const aWarnings: IStringList): IXmlFragment;
    end;





implementation

  {$ifdef profile_XmlReader}
  uses
  { deltics: }
    Deltics.Profiler;
  {$endif}


  uses
    Windows,
    Deltics.Xml.Nodes,
    Deltics.Xml.Nodes.Attributes,
    Deltics.Xml.Nodes.Attributes.Namespaces,
    Deltics.Xml.Nodes.CDATA,
    Deltics.Xml.Nodes.Comment,
    Deltics.Xml.Nodes.DocType,
    Deltics.Xml.Nodes.Document,
    Deltics.Xml.Nodes.Dtd.Attributes,
    Deltics.Xml.Nodes.Dtd.ContentParticles,
    Deltics.Xml.Nodes.Dtd.Elements,
    Deltics.Xml.Nodes.Dtd.Entities,
    Deltics.Xml.Nodes.Dtd.Notation,
    Deltics.Xml.Nodes.Elements,
    Deltics.Xml.Nodes.Fragment,
    Deltics.Xml.Nodes.ProcessingInstruction,
    Deltics.Xml.Nodes.Prolog,
    Deltics.Xml.Nodes.Text,
    Deltics.Xml.Types;


{$ifdef profile_XmlReader}
  var
    profiler: TProfile;
{$endif}


  type
    Utf8Char = ANSIChar;


  type
    TXmlEndTag = class(TXmlNode)
      Name: Utf8String;
      function get_Name: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
      constructor Create(const aName: Utf8String);
    end;


{ TXmlEndTag }

  constructor TXmlEndTag.Create(const aName: Utf8String);
  begin
    inherited Create(xmlEndTag);

    Name := aName;
  end;


  function TXmlEndTag.get_Name: Utf8String;
  begin
    result := Name;
  end;


  procedure TXmlEndTag.Assign(const aSource: TXmlNode);
  begin
    inherited;

    Name := aSource.Name;
  end;







{ TXmlReader }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class procedure TXmlReader.LoadDocument(const aDocument: IXmlDocument;
                                          const aStream: TStream;
                                          const aErrors: IStringList;
                                          const aWarnings: IStringList);
  var
    doc: TXmlDocument;
    node: IXmlNode;
    nodes: TXmlNodeList;
    reader: TXmlReader;
  begin
  {$ifdef profile_XmlReader} profiler.Start('LoadDocument'); try {$endif}

    InterfaceCast(aDocument, TXmlDocument, doc);

    doc.Reset;

    InterfaceCast(aDocument.Nodes, TXmlNodeList, nodes);

    reader := TXmlReader.Create;

    reader.fParser := TXmlParser.Create(aStream, aErrors, aWarnings);
    try
      try
        while NOT reader.fParser.EOF do
        begin
          node := reader.ReadNode;
          if NOT Assigned(node) then
            BREAK;

          case node.NodeType of
            xmlDocType  : begin
                            if Assigned(aDocument.DocType) then
                            begin
                              reader.fParser.Error('An Xml document may only have one !DOCTYPE declaration or reference');
                              EXIT;
                            end;

                            aDocument.DocType  := node as IXmlDocType;
                          end;

            xmlElement  : begin
                            if Assigned(aDocument.RootElement) then
                            begin
                              reader.fParser.Error('An Xml document may only have one root node' {, '2.1.[1].1', 'http://www.w3.org/TR/REC-Xml/#NT-document'});
                              EXIT;
                            end;

                            aDocument.RootElement := node as IXmlElement;
                          end;
          else
            nodes.Add(node);
          end;
        end;

        if NOT Assigned(aDocument.RootElement) then
          reader.fParser.Error('No root node');

      except
//        on EAbort do ;
//        on EXmlParser do ;
//        on EXmlReader do ;

        on e: Exception do
        begin
          reader.fParser.Error('Exception: ' + e.ClassName + ', ' + e.Message);
        end;
      end;

      doc.SourceEncoding := reader.fParser.SourceEncoding;

    finally
      reader.Free;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.LoadFragment(const aStream: TStream;
                                   const aErrors: IStringList;
                                   const aWarnings: IStringList): IXmlFragment;
  begin
  {$ifdef profile_XmlReader} profiler.Start('LoadFragment'); try {$endif}

    result := TXmlFragment.Create;

    fParser := TXmlParser.Create(aStream, aErrors, aWarnings);
    try
      try
        while NOT fParser.EOF do
          result.Add(ReadNode);

      except
        on EAbort do ;

        on e: Exception do
        begin
          fParser.Error('Exception: ' + e.ClassName + ', ' + e.Message);
        end;
      end;

    finally
      fParser := NIL;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlReader.UnexpectedNode(const aNode: IXmlNode);
  var
    node: TXmlNode;
  begin
    InterfaceCast(aNode, TXmlNode, node);
    fParser.Error('Unexpected node type: ' + node.ClassName);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadCDATA: IXmlCDATA;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadCDATA'); try {$endif}

    result := TXmlCDATA.Create(fParser.ReadStringUntil(']]>'))

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadComment: IXmlComment;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadComment'); try {$endif}

    result := TXmlComment.Create(fParser.ReadStringUntil('-->'))

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDocType: IXmlDocType;
  var
    root: Utf8String;
    name: Utf8String;
    scope: Utf8String;
    location: Utf8String;
    c: Utf8Char;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDocType'); try {$endif}

    result  := NIL;
    root    := fParser.ReadName;

    c := fParser.NextCharSkippingWhitespace;

    if c = '[' then
    begin
      result := ReadInternalDtd(root);
      EXIT;
    end;

    fParser.MoveBack;
    scope := fParser.ReadString;

    case STR.IndexOf(STR.FromUtf8(scope), ['PUBLIC',
                                           'SYSTEM']) of
      0:  begin
            name      := fParser.ReadQuotedString;
            location  := fParser.ReadQuotedString;

            result    := TXmlDocType.Create(dtPUBLIC, root, name, location);
          end;

      1:  begin
            location  := fParser.ReadString;
            result    := TXmlDocType.Create(dtSYSTEM, root, location);
          end;
    else
      fParser.UnexpectedString(STR.FromUtf8(scope), 'Not a valid DOCTYPE declaration (expected internal subset, SYSTEM or PUBLIC)');
    end;

    c := fParser.NextCharSkippingWhitespace;
    case c of
      '[' : begin
              result := ReadInternalDtd;
              EXIT;
            end;

      '>' : EXIT;
    end;

    fParser.UnexpectedChar(c, 'Expected internal subset or DOCTYPE end');

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadElement: IXmlElement;
  var
    c: Utf8Char;
    name: Utf8String;
    value: Utf8String;
    child: IXmlNode;
    attr: IXmlAttribute;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadElement'); try {$endif}

    name    := fParser.ReadName;
    result  := TXmlElement.Create(name);

    while NOT fParser.EOF do
    begin
      c := fParser.NextCharSkippingWhitespace;
      case c of
        '/' : begin
                fParser.ExpectChar('>');
                EXIT;
              end;

        '>' : begin
                while NOT fParser.EOF do
                begin
                  child := ReadNode;

                  if NOT Assigned(child) then
                    BREAK;

                  if (child.NodeType = xmlEndTag) then
                  begin
                    // TODO: properly...
                    // if NOT (child.Name = result.Name) then
                    //   UnexpectedEndTag(TXmlEndTag(child).Name, result.Name);
                    EXIT;
                  end
                  else
                    result.Add(child);
                end;

                // TODO: Report unclosed tag!
              end;
      else
        fParser.MoveBack;
        name  := fParser.ReadStringUntil(Utf8Char('='));
        value := fParser.ReadAttributeValue;

        if (name = 'xmlns') or Utf8.BeginsWith(name, 'xmlns:') then
          attr := TXmlNamespace.Create(name, value)
        else
          attr := TXmlAttribute.Create(name, value);

        result.Add(attr);
      end;
    end;

    fParser.UnexpectedEOF;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadInternalDtd(const aRootElement: Utf8String): IXmlDocType;
  var
    c: Utf8Char;
    node: IXmlNode;
    subset: TXmlNodeList;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadInternalDtd'); try {$endif}

    result := TXmlDocType.Create(dtInternal, aRootElement);

    InterfaceCast(result.InternalSubset, TXmlNodeList, subset);

    while NOT fParser.EOF do
    begin
      c := fParser.NextCharSkippingWhitespace;
      if (c = ']') then
      begin
        fParser.ExpectRealChar('>');
        EXIT;
      end;

      fParser.MoveBack;
      node := ReadNode;

      if (node.NodeType in [xmlComment,
                            xmlProcessingInstruction,
                            xmlDtdAttributeList,
                            xmlDtdElement,
                            xmlDtdEntity,
                            xmlDtdNotation]) then
        subset.Add(node)
      else
        UnexpectedNode(node);
    end;

    fParser.UnexpectedEOF;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadNode: IXmlNode;
  var
    element: TXmlElement absolute result;
    c: Utf8Char;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadNode'); try {$endif}

    result := NIL;
    if fParser.EOF then
      EXIT;

    c := fParser.NextCharSkippingWhitespace;

    case c of
      #0  : { NO-OP : Read beyond EOF somehow };

      '<' : begin
              c := fParser.NextChar;
              case c of
                '?' : begin
                        result := ReadProcessingInstruction;
                        EXIT;
                      end;

                '!' : begin
                        c := fParser.NextChar;
                        fParser.MoveBack;
                        case c of
                          'D' : begin
                                  fParser.ExpectString('DOCTYPE');
                                  fParser.SkipWhitespace;
                                  result := ReadDocType;
                                end;

                          '[' : begin
                                  fParser.ExpectString('[CDATA[');
                                  result := ReadCDATA;
                                end;

                          '-' : begin
                                  fParser.ExpectString('--');
                                  result := ReadComment;
                                end;
                        else
                          result := ReadDtdDeclaration;
                        end;

                        EXIT;
                      end;

                '/' : begin
                        result := TXmlEndTag.Create(fParser.ReadNameWithoutValidation);

                        c := fParser.NextCharSkippingWhitespace;
                        if c <> '>' then
                          fParser.UnexpectedChar(c, 'Expected ''>''');

                        EXIT;
                      end;
              else
                fParser.MoveBack;
                result := ReadElement;
              end;
            end;
    else
      fParser.MoveBack;
      result := ReadText;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadProcessingInstruction: IXmlNode;
  {
    Returns either a true Processing Instruction OR an Xml Declaration (often
     erroneously called a processing instruction when it is not, although it
     superficially looks like one).
  }
  var
    i: Integer;
    target: Utf8String;
    content: Utf8String;
    nextChar: Utf8Char;
    version: Utf8String;
    encoding: Utf8String;
    standalone: Utf8String;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadProcessingInstruction'); try {$endif}

    result := NIL;

    version     := '';
    encoding    := '';
    standalone  := '';

    target := fParser.ReadName;

    if target = 'xml' then
    begin
      try
        for i := 1 to 4 do  // We need to read up to 3 attributes + the closing tag
        begin
          nextChar := fParser.PeekCharSkippingWhitespace;

          if nextChar in ['v', 'e', 's'] then
          begin
            case nextChar of
              'v' : begin
                      fParser.ExpectString('version');
                      fParser.ExpectChar('=');
                      version := fParser.ReadQuotedString;
                    end;

              'e' : begin
                      fParser.ExpectString('encoding');
                      fParser.ExpectChar('=');
                      encoding := fParser.ReadQuotedString;
                    end;

              's' : begin
                      fParser.ExpectString('standalone');
                      fParser.ExpectChar('=');
                      standalone := fParser.ReadQuotedString;
                    end;

            end;
          end
          else
          begin
            fParser.ExpectString('?>');

            result := TXmlProlog.Create(version, encoding, standalone);
            BREAK;
          end;
        end;

      except
        fParser.Abort('Xml Declaration is malformed or not supported');
      end;

    end
    else
    begin
      content := fParser.ReadStringUntil('?>');

      result := TXmlProcessingInstruction.Create(target, content);
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadText: IXmlText;
  var
    txt: Utf8String;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadText'); try {$endif}

    // TODO: Also stop on '&' (entity reference).  i.e. support entity references

    txt     := fParser.ReadStringUntil('<');
    result  := TXmlText.Create(txt);

    fParser.MoveBack;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdAttList: IXmlDtdAttributeList;

    function ReadEnum: IUtf8StringList;
    var
      c: Utf8Char;
    begin
      fParser.ExpectChar('(');

      result := TUtf8StringList.CreateManaged;
      while NOT fParser.EOF do
      begin
        fParser.SkipWhiteSpace;
        result.Add(fParser.ReadName);

        c := fParser.NextCharSkippingWhitespace;
        case c of
          '|': { NO-OP} ;
          ')': EXIT;
        else
          fParser.UnexpectedChar(c);
        end;
      end;
    end;

  var
    c: Utf8Char;
    typeidx: Integer;
    element: Utf8String;
    attr: IXmlDtdAttribute;
    attr_: TXmlDtdAttribute;
    attrs: TXmlDtdAttributeList;
    list: TXmlNodeList;
    attrName: Utf8String;
    attrType: TXmlDtdAttributeType;
    members: IUtf8StringList;
  begin
    fParser.SkipWhitespace;
    element := fParser.ReadName;

    result := TXmlDtdAttributeList.Create(element);

    InterfaceCast(result, TXmlDtdAttributeList, attrs);
    InterfaceCast(attrs.Attributes, TXmlNodeList, list);

    while NOT fParser.EOF do
    begin
      c := fParser.NextCharSkippingWhitespace;
      if (c = '>') then
        BREAK;

      fParser.MoveBack;

      attrName := fParser.ReadName;

      c := fParser.PeekCharSkippingWhitespace;
      if (c = '(') then
      begin
        attrType  := atEnum;
        members   := ReadEnum;
      end
      else
      begin
        typeidx := fParser.ExpectOneOf(['CDATA',
                                        'ENTITY',
                                        'ENTITIES',
                                        'ID',
                                        'IDREF',
                                        'IDREFS',
                                        'NMTOKEN',
                                        'NMTOKENS',
                                        'NOTATION']);

        case typeidx of
          0 : attrType := atCDATA;
          1 : attrType := atEntity;
          2 : attrType := atEntities;
          3 : attrType := atID;
          4 : attrType := atIDREF;
          5 : attrType := atIDREFS;
          6 : attrType := atNmToken;
          7 : attrType := atNmTokens;
          8 : begin
                attrType := atNotation;

                fParser.ExpectChar('(');
                fParser.MoveBack;

                members := ReadEnum;
              end;
        else
          fParser.UnexpectedChar(c, 'Not a valid ATTLIST type declaration');
          attrType := atUnknown;
        end;
      end;

      attr := TXmlDtdAttribute.Create(attrName, attrType);
      InterfaceCast(attr, TXmlDtdAttribute, attr_);

      if Assigned(attr_.Members) then
        attr_.Members := members;

      c := fParser.PeekCharSkippingWhitespace;
      if (c = '#') then
      begin
        fParser.MarkLocation;
        try
          case fParser.ExpectOneOf(['#REQUIRED',
                                    '#IMPLIED',
                                    '#FIXED']) of
            0 : attr_.Constraint := acRequired;
            1 : attr_.Constraint := acImplied;
            2 : attr_.Constraint := acFixed;
          else
            fParser.Abort('Invalid attribute constraint');
          end;

          c := fParser.PeekCharSkippingWhitespace;

        finally
          fParser.UnmarkLocation;
        end;
      end;

      if (c = '"') then
        attr_.DefaultValue := fParser.ReadQuotedString;

      list.Add(attr);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdDeclaration: IXmlDtdDeclaration;
  var
    decl: String;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDtdDeclaration'); try {$endif}

    fParser.MarkLocation;
    try
      decl := STR.FromUtf8(fParser.ReadString);

      case STR.IndexOf(decl, ['ATTLIST',
                              'ELEMENT',
                              'ENTITY',
                              'NOTATION']) of

        0: result := ReadDtdAttList;
        1: result := ReadDtdElement;
        2: result := ReadDtdEntity;
        3: result := ReadDtdNotation;
      else
        fParser.UnexpectedString(decl, 'Illegal entity (!' + decl + ') in Dtd.  Expected: !ATTLIST, !ELEMENT, !ENTITY or !NOTATION');
        result := NIL;
      end;

    finally
      fParser.UnmarkLocation;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdContentParticles: IXmlDtdContentParticleList;

    procedure ReadCardinality(var isRequired: Boolean; var isRepeating: Boolean);
    var
      c: Utf8Char;
    begin
      c := fParser.NextChar;

      if NOT (c in ['?', '*', '+']) then
        fParser.MoveBack;

      isRequired  := NOT (c in ['?', '*']);
      isRepeating := c in ['+', '*'];
    end;

    procedure Validate;
    var
      i, j: Integer;
      errNotAChoice: Boolean;
    begin
      errNotAChoice := FALSE;

      for i := 0 to Pred(result.Count) do
      begin
        if result[i].IsPCDATA and (result.ListType <> cpChoice) then
          errNotAChoice := TRUE;

        if (result[i].NodeType = xmlDtdContentParticleList) then
          CONTINUE;

        for j := 0 to Pred(result.Count) do
        begin
          if (i = j) or (result[j].NodeType = xmlDtdContentParticleList) then
            CONTINUE;

          if (result[i].Name = result[j].Name) then
            fParser.Error('DTD ELEMENT declaration error: Duplicate child name (' + STR.FromUtf8(result[i].Name) + ').');
        end;
      end;

      if errNotAChoice then
        fParser.Error('DTD ELEMENT ''Mixed'' declaration error: Should be a choice but is declared as a sequence.');
    end;

  const
    LIST_DELIM: array[cpChoice..cpSequence] of Utf8Char = ('?',',');
  var
    c: Utf8Char;
    req, rpt: Boolean;
    name: Utf8String;
    mutableResult: TXmlDtdContentParticleList;
    resultList: TXmlNodeList;
    particle: TXmlDtdContentParticle;
    listTypeSet: Boolean;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDtdContentParticles'); try {$endif}

    listTypeSet := FALSE;

    result := TXmlDtdContentParticleList.Create;

    InterfaceCast(result, TXmlDtdContentParticleList, mutableResult);
    InterfaceCast(mutableResult.ItemList, TXmlNodeList, resultList);

    mutableResult.ListType := cpChoice;

    while NOT fParser.EOF do
    begin
      c := fParser.NextCharSkippingWhitespace;

      case c of
        '|',
        ',' : if listTypeSet then
              begin
                if (c <> LIST_DELIM[result.ListType]) then
                  fParser.Abort('Cannot mix CHOICE and SEQUENCE lists in a single Content Particle list');
              end
              else
              begin
                if (c = ',') then
                  mutableResult.ListType := cpSequence;  // Choice by default so only need to set it if it is a sequence

                listTypeSet := TRUE;
              end;

        '(' : resultList.Add(ReadDtdContentParticles);

        '#' : begin
                fParser.ExpectString('PCDATA');

                particle := TXmlDtdContentParticle.CreatePCDATA;

                ReadCardinality(req, rpt);
                particle.IsRequired     := req;
                particle.AllowMultiple  := rpt;

                resultList.Add(particle);
              end;

        ')' : begin
                ReadCardinality(req, rpt);
                mutableResult.IsRequired     := req;
                mutableResult.AllowMultiple  := rpt;

                Validate;

                EXIT;
              end;

        '%' : begin
                // TODO: Check this: CP using parameter entity ref
                name := fParser.ReadStringUntil(';');

                particle := TXmlDtdContentParticle.Create(name);
                ReadCardinality(req, rpt);
                particle.IsRequired     := req;
                particle.AllowMultiple  := rpt;

                resultList.Add(particle);
              end;
      else
        fParser.MoveBack;
        name := fParser.ReadName;
        ReadCardinality(req, rpt);

        particle := TXmlDtdContentParticle.Create(name);
        particle.IsRequired     := req;
        particle.AllowMultiple  := rpt;

        resultList.Add(particle);
      end;
    end;

    fParser.UnexpectedEOF;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdElement: IXmlDtdElement;
  var
    name: Utf8String;
    c: Utf8Char;
    content: IXmlDtdContentParticleList;
    content_: TXmlDtdContentParticleList;
    list: TXmlNodeList;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDtdElement'); try {$endif}

    result := NIL;

    fParser.SkipWhitespace;
    name := fParser.ReadName;

    c := fParser.NextCharSkippingWhitespace;

    case c of
      'A' : begin
              fParser.MoveBack;
              fParser.ExpectString('ANY');

              result := TXmlDtdElement.CreateANY(name);
            end;

      'E' : begin
              fParser.MoveBack;
              fParser.ExpectString('EMPTY');

              result := TXmlDtdElement.CreateEMPTY(name);
            end;

      '(' : begin
              content := ReadDtdContentParticles;
              result  := TXmlDtdElement.Create(name, content);

              if (result.Category = ecMixed) and Assigned(result.Content) then
              begin
                if result.Content.IsRequired then
                  fParser.Error('DTD ''Mixed'' ELEMENT (' + Str.FromUtf8(name) + ') constraint error: Content cannot be required.');

                if NOT result.Content.AllowMultiple then
                  fParser.Error('DTD ''Mixed'' ELEMENT (' + Str.FromUtf8(name) + ') constraint error: Content cannot be limited to one occurence.');
              end;
            end;

      '%' : begin
              content_ := TXmlDtdContentParticleList.Create;
              InterfaceCast(content_.ItemList, TXmlNodeList, list);
              repeat
                list.Add(TXmlDtdContentParticle.Create('%' + fParser.ReadStringUntil(';') + ';'));
              until (fParser.PeekCharSkippingWhitespace <> '%');

              result := TXmlDtdElement.Create(name, content_);
            end;

    else
      fParser.Abort('''' + c + ''' not expected in !ELEMENT at %location');
    end;

    fParser.ExpectRealChar('>');

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdEntity: IXmlDtdEntity;
  var
    name: Utf8String;
    content: Utf8String;
    isPE: Boolean;
  begin
    isPE := (fParser.PeekCharSkippingWhitespace = '%');
    if isPE then
    begin
      fParser.NextChar;         // Read the %
      fParser.ExpectWhitespace; //  and expect some whitespace after it
    end;

    name := fParser.ReadName;
    fParser.SkipWhitespace;
    content := fParser.ReadQuotedString;

    fParser.ExpectRealChar('>');

    result := TXmlDtdEntity.Create(name, content);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdNotation: IXmlDtdNotation;
  var
    name: Utf8String;
  begin
    name := fParser.ReadName;
    fParser.SkipWhitespace;

    fParser.MarkLocation;
    try
      case fParser.ExpectOneOf(['SYSTEM', 'PUBLIC']) of
        0 : begin
              // TODO:
              fParser.ReadQuotedString;
            end;

        1 : begin
              // TODO:
              fParser.ReadQuotedString;
              fParser.SkipWhitespace;
              fParser.ReadQuotedString;
            end;
      else
        fParser.Error('Expect either SYSTEM or PUBLIC in a !NOTATION declaration');
      end;

    finally
      fParser.UnmarkLocation;
    end;

    fParser.ExpectRealChar('>');

    result := TXmlDtdNotation.Create(name);
  end;





{$ifdef profile_XmlReader}
initialization
  profiler := TProfile.Create(2, 'reader', 'Xml Reader', '', TRUE);
{$endif}

end.
