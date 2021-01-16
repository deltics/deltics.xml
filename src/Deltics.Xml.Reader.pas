
{$i deltics.xml.inc}

  unit Deltics.Xml.Reader;


interface

  uses
    Classes,
    SysUtils,
    Deltics.Strings,
    Deltics.Xml,
    Deltics.Xml.Parser;


  type
    TXmlReader = class;


    EXmlReader = class(Exception);


    TXmlReader = class
    private
      fParser: TXmlParser;
    protected
      function ReadCDATA: TXmlCDATA;
      function ReadComment: TXmlComment;
      function ReadDocType: TXmlDocType;
      function ReadElement: TXmlElement;
      function ReadInternalDtd: TXmlDocType;
      function ReadNode: TXmlNode;
      function ReadProcessingInstruction: TXmlNode;
      function ReadText: TXmlText;
      function ReadDtdAttList: TXmlDtdAttListDeclaration;
      function ReadDtdContentParticles: TXmlDtdContentParticleList;
      function ReadDtdDeclaration: TXmlDtdDeclaration;
      function ReadDtdElement: TXmlDtdElementDeclaration;
      function ReadDtdEntity: TXmlDtdEntityDeclaration;
      function ReadDtdNotation: TXmlDtdNotationDeclaration;
      procedure UnexpectedNode(const aNode: TXmlNode);
    public
      procedure LoadDocument(const aDocument: TXmlDocument; const aStream: TStream);
      procedure LoadFragment(const aFragment: TXmlFragment; const aStream: TStream);
    end;





implementation

  {$ifdef profile_XmlReader}
  uses
  { deltics: }
    Deltics.Profiler;
  {$endif}


{$ifdef profile_XmlReader}
  var
    profiler: TProfile;
{$endif}


  type
    Utf8Char = ANSIChar;


  type
    TXmlEndTag = class(TXmlNode)
      Name: String;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
      constructor Create(const aName: String);
    end;


{ TXmlEndTag }

  constructor TXmlEndTag.Create(const aName: String);
  begin
    inherited Create(xmlEndTag);
    Name := aName;
  end;


  function TXmlEndTag.get_Xml: Utf8String;
  begin
    result := Utf8.FromString('</' + Name + '>');
  end;


  procedure TXmlEndTag.Assign(const aSource: TXmlNode);
  begin
    inherited;
    Name := STR.FromUtf8(aSource.Name);
  end;







{ TXmlReader }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlReader.LoadDocument(const aDocument: TXmlDocument;
                                    const aStream: TStream);
  var
    node: TXmlNode;
  begin
  {$ifdef profile_XmlReader} profiler.Start('LoadDocument'); try {$endif}

    aDocument.Clear;

    fParser := TXmlParser.Create(aStream);
    try
      fParser.Errors    := aDocument.Errors;
      fParser.Warnings  := aDocument.Warnings;

      try
        while NOT fParser.EOF do
        begin
          node := ReadNode;
          if NOT Assigned(node) then
            BREAK;

          case node.NodeType of
            xmlDocType  : begin
                            if Assigned(aDocument.DocType) then
                            begin
                              fParser.Error('An Xml document may only have one !DOCTYPE declaration or reference');
                              EXIT;
                            end;

                            aDocument.DocType  := TXmlDocType(node);
                          end;

            xmlElement  : begin
                            if Assigned(aDocument.Root) then
                            begin
                              fParser.Error('An Xml document may only have one root node' {, '2.1.[1].1', 'http://www.w3.org/TR/REC-Xml/#NT-document'});
                              EXIT;
                            end;

                            aDocument.Root := TXmlElement(node);
                          end;
          else
            aDocument.Nodes.Add(node);
          end;
        end;

        if NOT Assigned(aDocument.Root) then
          fParser.Error('No root node');

      except
        on EAbort do ;
        on EXmlParser do ;
        on EXmlReader do ;

        on e: Exception do
        begin
          fParser.Error('Exception: ' + e.ClassName + ', ' + e.Message);
        end;
      end;

    finally
      FreeAndNIL(fParser);
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlReader.LoadFragment(const aFragment: TXmlFragment;
                                    const aStream: TStream);
  begin
  {$ifdef profile_XmlReader} profiler.Start('LoadFragment'); try {$endif}

    aFragment.Clear;

    fParser := TXmlParser.Create(aStream);
    try
      fParser.Errors    := aFragment.Errors;
      fParser.Warnings  := aFragment.Warnings;

      try
        while NOT fParser.EOF do
          aFragment.Add(ReadNode);

      except
        on EAbort do ;

        on e: Exception do
        begin
          fParser.Error('Exception: ' + e.ClassName + ', ' + e.Message);
        end;
      end;

    finally
      FreeAndNIL(fParser);
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlReader.UnexpectedNode(const aNode: TXmlNode);
  begin
    fParser.Error('Unexpected node type: ' + aNode.ClassName);
    aNode.Free;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadCDATA: TXmlCDATA;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadCDATA'); try {$endif}

    result := TXmlCDATA.Create(fParser.ReadStringUntil(']]>'))

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadComment: TXmlComment;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadComment'); try {$endif}

    result := TXmlComment.Create(fParser.ReadStringUntil('-->'))

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDocType: TXmlDocType;
  var
    root: Utf8String;
    name: Utf8String;
    scope: Utf8String;
    location: Utf8String;
    internal: TXmlDocType;
    c: Utf8Char;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDocType'); try {$endif}

    result  := NIL;
    root    := fParser.ReadName;

    c := fParser.NextCharSkippingWhitespace;

    if c = '[' then
    begin
      result := ReadInternalDtd;
      result.Name := root;
      EXIT;
    end;

    fParser.MoveBack;
    scope := fParser.ReadString;

    case STR.IndexOf(STR.FromUtf8(scope), ['PUBLIC',
                                           'SYSTEM']) of
      0:  begin
            name      := fParser.ReadQuotedString;
            location  := fParser.ReadQuotedString;

            result    := TXmlDocType.CreatePublic(root, name, location);
          end;

      1:  begin
            location  := fParser.ReadString;
            result    := TXmlDocType.CreateSystem(root, location);
          end;
    else
      fParser.UnexpectedString(STR.FromUtf8(scope), 'Not a valid DOCTYPE declaration (expected internal subset, SYSTEM or PUBLIC)');
    end;

    try
      c := fParser.NextCharSkippingWhitespace;
      case c of
        '[' : begin
                internal := ReadInternalDtd;
                try
                  result.InternalSubset := internal.Nodes;
                  EXIT;

                finally
                  internal.Free;
                end;
              end;

        '>' : EXIT;
      end;

      fParser.UnexpectedChar(c, 'Expected internal subset or DOCTYPE end');

    except
      result.Free;
      raise;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadElement: TXmlElement;
  var
    c: Utf8Char;
    name: Utf8String;
    value: Utf8String;
    child: TXmlNode;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadElement'); try {$endif}

    result := TXmlElement.CreateEmpty(fParser.ReadName);
    try
      while NOT fParser.EOF do
      begin
        c := fParser.NextCharSkippingWhitespace;
        case c of
          '/' : begin
                  fParser.ExpectChar('>');
                  EXIT;
                end;

          '>' : begin
                  result.IsEmpty := FALSE;

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
                      child.Free;
                      EXIT;
                    end
                    else
                      result.Nodes.Add(child);
                  end;

                  // TODO: Report unclosed tag!
                end;
        else
          fParser.MoveBack;
          name  := fParser.ReadStringUntil(Utf8Char('='));
          value := fParser.ReadAttributeValue;

          result.Attributes.Add(TXmlAttribute.Create(name, value));
        end;
      end;

      fParser.UnexpectedEOF;

    except
      FreeAndNIL(result);
      raise;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadInternalDtd: TXmlDocType;
  var
    c: Utf8Char;
    node: TXmlNode;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadInternalDtd'); try {$endif}

    result := TXmlDocType.CreateInternal('');
    try
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

        if NOT (node.NodeType in [xmlComment,
                                  xmlProcessingInstruction,
                                  dtdAttList,
                                  dtdElement,
                                  dtdEntity,
                                  dtdNotation]) then
          UnexpectedNode(node)
        else
          result.Nodes.Add(node);
      end;

      fParser.UnexpectedEOF;

    except
      result.Free;
      raise;
    end;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadNode: TXmlNode;
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
                        result := TXmlEndTag.Create(STR.FromUtf8(fParser.ReadNameWithoutValidation));

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
  function TXmlReader.ReadProcessingInstruction: TXmlNode;
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

    if target = 'Xml' then
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

            result := TXmlDeclaration.Create(version, encoding, standalone);
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
  function TXmlReader.ReadText: TXmlText;
  var
    txt: Utf8String;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadText'); try {$endif}

    txt     := fParser.ReadStringUntil('<');
    result  := TXmlText.Create(txt);

    fParser.MoveBack;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdAttList: TXmlDtdAttListDeclaration;

    function ReadEnum: TStringList;
    var
      c: Utf8Char;
    begin
      fParser.ExpectChar('(');

      result := TStringList.Create;
      while NOT fParser.EOF do
      begin
        fParser.SkipWhiteSpace;
        result.Add(STR.FromUtf8(fParser.ReadName));

        c := fParser.NextCharSkippingWhitespace;
        case c of
          '|': { NO-OP} ;
          ')': EXIT;
        else
          FreeAndNIL(result);
          fParser.UnexpectedChar(c);
        end;
      end;
    end;

  var
    c: Utf8Char;
    typeidx: Integer;
    element: Utf8String;
    attrName: Utf8String;
    attrType: TXmlDtdAttributeType;
    attr: TXmlDtdAttributeDeclaration;
    enum: TStringList;
  begin
    fParser.SkipWhitespace;
    element := fParser.ReadName;

    result := TXmlDtdAttListDeclaration.Create;
    result.ElementName := element;
    try
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
          enum      := ReadEnum;
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
                  enum := ReadEnum;
                end;
          else
            fParser.UnexpectedChar(c, 'Not a valid ATTLIST type declaration');
            attrType := atUnknown;
          end;
        end;

        attr := result.Add(attrName, attrType);

        if attrType in [atEnum, atNotation] then
        begin
          attr.Members.Assign(enum);
          FreeAndNIL(enum);
        end;

        try
          c := fParser.PeekCharSkippingWhitespace;
          if (c = '#') then
          begin
            fParser.MarkLocation;
            try
              case fParser.ExpectOneOf(['#REQUIRED',
                                        '#IMPLIED',
                                        '#FIXED']) of
                0 : attr.Constraint := acRequired;
                1 : attr.Constraint := acImplied;
                2 : attr.Constraint := acFixed;
              else
                fParser.Abort('Invalid attribute constraint');
              end;

              c := fParser.PeekCharSkippingWhitespace;

            finally
              fParser.UnmarkLocation;
            end;
          end;

          if (c = '"') then
            attr.DefaultValue := fParser.ReadQuotedString;

        except
          FreeAndNIL(result);
          raise;
        end;
      end;

    except
      result.Free;
      raise;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdDeclaration: TXmlDtdDeclaration;
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
  function TXmlReader.ReadDtdContentParticles: TXmlDtdContentParticleList;

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

        if (result[i].NodeType = dtdContentParticleList) then
          CONTINUE;

        for j := 0 to Pred(result.Count) do
        begin
          if (i = j) or (result[j].NodeType = dtdContentParticleList) then
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
    part: TXmlDtdContentParticle;
    listTypeSet: Boolean;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDtdContentParticles'); try {$endif}

    listTypeSet := FALSE;

    result := TXmlDtdContentParticleList.Create;
    result.ListType := cpChoice;

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
                  result.ListType := cpSequence;  // Choice by default so only need to set it if it is a sequence

                listTypeSet := TRUE;
              end;

        '(' : result.Add(ReadDtdContentParticles);

        '#' : begin
                fParser.ExpectString('PCDATA');

                part := TXmlDtdContentParticle.CreatePCDATA;

                ReadCardinality(req, rpt);
                part.IsRequired     := req;
                part.AllowMultiple  := rpt;

                result.Add(part);
              end;

        ')' : begin
                ReadCardinality(req, rpt);
                result.IsRequired     := req;
                result.AllowMultiple  := rpt;

                Validate;

                EXIT;
              end;

        '%' : begin
                // TODO: Check this: CP using parameter entity ref
                name := fParser.ReadStringUntil(';');

                part := TXmlDtdContentParticle.Create(name);
                ReadCardinality(req, rpt);
                part.IsRequired     := req;
                part.AllowMultiple  := rpt;

                result.Add(part);
              end;
      else
        fParser.MoveBack;
        name := fParser.ReadName;
        ReadCardinality(req, rpt);

        part := TXmlDtdContentParticle.Create(name);
        part.IsRequired     := req;
        part.AllowMultiple  := rpt;

        result.Add(part);
      end;
    end;

    fParser.UnexpectedEOF;

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdElement: TXmlDtdElementDeclaration;
  var
    name: String;
    c: Utf8Char;
    content: TXmlDtdContentParticleList;
  begin
  {$ifdef profile_XmlReader} profiler.Start('ReadDtdElement'); try {$endif}

    result := NIL;

    fParser.SkipWhitespace;
    name := STR.FromUtf8(fParser.ReadName);

    c := fParser.NextCharSkippingWhitespace;

    case c of
      'A' : begin
              fParser.MoveBack;
              fParser.ExpectString('ANY');

              result := TXmlDtdElementDeclaration.CreateANY(name);
            end;

      'E' : begin
              fParser.MoveBack;
              fParser.ExpectString('EMPTY');

              result := TXmlDtdElementDeclaration.CreateEMPTY(name);
            end;

      '(' : begin
              content := ReadDtdContentParticles;
              result  := TXmlDtdElementDeclaration.Create(name, content);

              if (result.Category = ecMixed) and Assigned(result.Content) then
              begin
                if result.Content.IsRequired then
                  fParser.Error('DTD ''Mixed'' ELEMENT (' + name + ') constraint error: Content cannot be required.');

                if NOT result.Content.AllowMultiple then
                  fParser.Error('DTD ''Mixed'' ELEMENT (' + name + ') constraint error: Content cannot be limited to one occurence.');
              end;
            end;

      '%' : begin
              content := TXmlDtdContentParticleList.Create;
              repeat
                content.Add(TXmlDtdContentParticle.Create('%' + fParser.ReadStringUntil(';') + ';'));
              until (fParser.PeekCharSkippingWhitespace <> '%');
              result := TXmlDtdElementDeclaration.Create(name, content);
            end;

    else
      fParser.Abort('''' + c + ''' not expected in !ELEMENT at %location');
    end;

    fParser.ExpectRealChar('>');

  {$ifdef profile_XmlReader} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdEntity: TXmlDtdEntityDeclaration;
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

    result := TXmlDtdEntityDeclaration.Create(name, content);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlReader.ReadDtdNotation: TXmlDtdNotationDeclaration;
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

    result := TXmlDtdNotationDeclaration.Create(name);
  end;





{$ifdef profile_XmlReader}
initialization
  profiler := TProfile.Create(2, 'reader', 'Xml Reader', '', TRUE);
{$endif}

end.
