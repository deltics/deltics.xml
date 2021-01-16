

  unit Deltics.XML.Parser;


interface

  uses
  { vcl: }
    Classes,
  { deltics: }
    Deltics.Parser,
    Deltics.Unicode;


  type
    TReadStringMethod = function: String of object;


    TXMLParser = class(TParser)
    private
      fErrors: TStringList;
      fWarnings: TStringList;
      procedure Abort(const aError: String);
      procedure Warn(const aMessage: String);
    protected
      procedure Initialise; override;
    public
      procedure GetLocation(var aLineNo, aCharPos: Integer);
      function NextChar: WideChar; override;
      function NextChar(var aWhitespace: String): WideChar; override;

      procedure ExpectChar(const aExpected: Char);
      procedure ExpectRealChar(const aExpected: WideChar);
      procedure ExpectString(const aExpected: String);
      function ReadName: String;
      function ReadAttributeValue: String;
      function ReadQuotedString: String;
      function ReadString: String; overload;
      function ReadString(const aTerminator: Char): String; overload;
      function ReadString(const aTerminator: String): String; overload;
      procedure UnexpectedChar(const aChar: WideChar; const aMessage: String = '');
      procedure UnexpectedEOF;
      procedure UnexpectedString(const aString: String; const aMessage: String = '');
      function IsNameEndChar(const aChar: WideChar): Boolean;
      function IsValidNameChar(const aChar: WideChar): Boolean;
      function IsValidNameStartChar(const aChar: WideChar): Boolean;
      property Errors: TStringList read fErrors write fErrors;
      property Warnings: TStringList read fWarnings write fWarnings;
    end;


implementation

  uses
  { vcl: }
    SysUtils
  {$ifdef profile_xmlParser}
    ,Deltics.Profiler
  {$endif}
    ;


{$ifdef profile_xmlParser}
  var
    profiler: TProfile;
{$endif}


  const // ----------------------------------------        0      1      2      3      4      5      6      7      8      9
    Is_WHITESPACE     : array[#0..#127] of Boolean  = (false, false, false, false, false, false, false, false, false,  TRUE,
                                              { 1.}     TRUE, false, false,  TRUE, false, false, false, false, false, false,
                                              { 2.}    false, false, false, false, false, false, false, false, false, false,
                                              { 3.}    false, false,  TRUE, false, false, false, false, false, false, false,
                                              { 4.}    false, false, false, false, false, false, false, false, false, false,
                                              { 5.}    false, false, false, false, false, false, false, false, false, false,
                                              { 6.}    false, false, false, false, false, false, false, false, false, false,
                                              { 7.}    false, false, false, false, false, false, false, false, false, false,
                                              { 8.}    false, false, false, false, false, false, false, false, false, false,
                                              { 9.}    false, false, false, false, false, false, false, false, false, false,
                                              {10.}    false, false, false, false, false, false, false, false, false, false,
                                              {11.}    false, false, false, false, false, false, false, false, false, false,
                                              {12.}    false, false, false, false, false, false, false, false);

    Is_VALIDNAMESTART : array[#0..#127] of Boolean  = (false, false, false, false, false, false, false, false, false, false,
                                              { 1.}    false, false, false, false, false, false, false, false, false, false,
                                              { 2.}    false, false, false, false, false, false, false, false, false, false,
                                              { 3.}    false, false, false, false, false, false, false, false, false, false,
                                              { 4.}    false, false, false, false, false, false, false, false, false, false,
                                              { 5.}    false, false, false, false, false, false, false, false,  TRUE, false,
                                              { 6.}    false, false, false, false, false,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 7.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 8.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 9.}     TRUE, false, false, false, false,  TRUE, false,  TRUE,  TRUE,  TRUE,
                                              {10.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              {11.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              {12.}     TRUE,  TRUE,  TRUE, false, false, false, false, false);

    Is_VALIDNAMECHAR  : array[#0..#127] of Boolean  = (false, false, false, false, false, false, false, false, false, false,
                                              { 1.}    false, false, false, false, false, false, false, false, false, false,
                                              { 2.}    false, false, false, false, false, false, false, false, false, false,
                                              { 3.}    false, false, false, false, false, false, false, false, false, false,
                                              { 4.}    false, false, false, false, false,  TRUE,  TRUE, false,  TRUE,  TRUE,
                                              { 5.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE, false,
                                              { 6.}    false, false, false, false, false,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 7.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 8.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 9.}     TRUE, false, false, false, false,  TRUE, false,  TRUE,  TRUE,  TRUE,
                                              {10.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              {11.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              {12.}     TRUE,  TRUE,  TRUE, false, false, false, false, false);

    Is_ATTRVALUEEND   : array[#0..#127] of Boolean  = (false, false, false, false, false, false, false, false, false,  TRUE,
                                              { 1.}     TRUE, false, false,  TRUE, false, false, false, false, false, false,
                                              { 2.}    false, false, false, false, false, false, false, false, false, false,
                                              { 3.}    false, false,  TRUE, false, false, false, false, false, false, false,
                                              { 4.}    false, false, false, false, false, false, false,  TRUE, false, false,
                                              { 5.}    false, false, false, false, false, false, false, false, false, false,
                                              { 6.}    false, false,  TRUE, false, false, false, false, false, false, false,
                                              { 7.}    false, false, false, false, false, false, false, false, false, false,
                                              { 8.}    false, false, false, false, false, false, false, false, false, false,
                                              { 9.}    false, false, false, false, false, false, false, false, false, false,
                                              {10.}    false, false, false, false, false, false, false, false, false, false,
                                              {11.}    false, false, false, false, false, false, false, false, false, false,
                                              {12.}    false, false, false, false, false, false, false, false);

    Is_NAMEEND        : array[#0..#127] of Boolean  = (false, false, false, false, false, false, false, false, false,  TRUE,
                                              { 1.}     TRUE, false, false,  TRUE, false, false, false, false, false, false,
                                              { 2.}    false, false, false, false, false, false, false, false, false, false,
                                              { 3.}    false, false,  TRUE, false, false, false, false, false, false, false,
                                              { 4.}    false, false, false, false, false, false, false,  TRUE, false, false,
                                              { 5.}    false, false, false, false, false, false, false, false, false, false,
                                              { 6.}    false,  TRUE,  TRUE, false, false, false, false, false, false, false,
                                              { 7.}    false, false, false, false, false, false, false, false, false, false,
                                              { 8.}    false, false, false, false, false, false, false, false, false, false,
                                              { 9.}    false, false, false, false, false, false, false, false, false, false,
                                              {10.}    false, false, false, false, false, false, false, false, false, false,
                                              {11.}    false, false, false, false, false, false, false, false, false, false,
                                              {12.}    false, false, false, false, false, false, false, false);




{ TXMLParser }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.GetLocation(var aLineNo, aCharPos: Integer);
  var
    i: Integer;
  begin
    aLineNo   := 1;
    aCharPos  := 0;

    for i := 0 to Pred(DataPos) do
    begin
      if (Data[i] = #13) and (Data[i + 1] = #10) then
        CONTINUE;

      if (Data[i] in [#13, #10]) then
      begin
        Inc(aLineNo);
        aCharPos := 0;
      end
      else
        Inc(aCharPos);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.Initialise;
  const
    BOM: array[0..7] of TBOMInfo = (
                                    (Data: ( '<', '?', 'x', 'm'); Len: 4; Encoding: ceUTF8;     IsHeuristic: TRUE),
                                    (Data: (  #0,  #0,  #0, '<'); Len: 4; Encoding: ceUTF32BE;  IsHeuristic: TRUE),
                                    (Data: ( '<',  #0,  #0,  #0); Len: 4; Encoding: ceUTF32LE;  IsHeuristic: TRUE),
                                    (Data: (  #0, '<',  #0, '?'); Len: 4; Encoding: ceUTF16BE;  IsHeuristic: TRUE),
                                    (Data: ( '<',  #0, '?',  #0); Len: 4; Encoding: ceUTF16LE;  IsHeuristic: TRUE),
                                    (Data: (  #0, '<', #99, #99); Len: 2; Encoding: ceUTF16BE;  IsHeuristic: TRUE),
                                    (Data: ( '<',  #0, #99, #99); Len: 2; Encoding: ceUTF16LE;  IsHeuristic: TRUE),
                                    (Data: ( '<', #99, #99, #99); Len: 1; Encoding: ceUTF8;     IsHeuristic: TRUE)
                                   );
  var
    i: Integer;
  begin
    inherited;

    for i := Low(BOM) to High(BOM) do
      AddBOMSignature(BOM[i]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.NextChar: WideChar;
  begin
    result := inherited NextChar;

    if result = #13 then
    begin
      result := NextChar;
      if NOT (result in [#0, #10]) then
        MoveBack;

      result := #10
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.NextChar(var aWhitespace: String): WideChar;
  begin
    result := inherited NextChar(aWhitespace);
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.Abort(const aError: String);
  begin
    fErrors.Add(aError);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.ExpectChar(const aExpected: Char);
  var
    c: WideChar;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectChar(%s)', [aExpected]); try {$endif}

    c := NextChar;
    if (c <> WideChar(aExpected)) then
      UnexpectedChar(c, 'Expected ''' + aExpected + '''');

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.ExpectRealChar(const aExpected: WideChar);
  var
    c: WideChar;
    ws: String;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectRealChar(%s)', [aExpected]); try {$endif}

    c := NextChar(ws);
    if (c <> aExpected) then
      UnexpectedChar(c, 'Expected ''' + aExpected + '''');

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.ExpectString(const aExpected: String);
  var
    i: Integer;
    s: WideString;
    ok: Boolean;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectString(%s)', [aExpected]); try {$endif}

    ok := TRUE;
    SetLength(s, Length(aExpected));

    for i := 1 to Length(aExpected) do
    begin
      s[i] := NextChar;
      ok   := (s[i] = WideChar(aExpected[i])) and ok;
    end;

    if NOT ok then
      UnexpectedString(s, 'Expected ''' + aExpected + '''');

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.UnexpectedChar(const aChar: WideChar;
                                      const aMessage: String);
  var
    s: String;
    msg: String;
    l, c: Integer;
  begin
    case ANSIChar(aChar) of
      #0    : s := 'NULL';
      #9    : s := '[tab]';
      #10   : s := '[LF]';
      #13   : s := '[CR]';
      #32   : s := '[space]';
    else
      s := '''' + aChar + '''';
    end;

    GetLocation(l, c);

    if aMessage = '' then
      Abort(Format(s + ' not expected at character %d, line %d', [c, l]))
    else
      Abort(Format(s + ' not expected at character %d, line %d.  ' + aMessage, [c, l]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.UnexpectedEOF;
  begin
    Abort('Unexpected end of file');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.UnexpectedString(const aString, aMessage: String);
  var
    l, c: Integer;
  begin
    GetLocation(l, c);

    if aMessage = '' then
      Abort(Format('''' + aString + ''' not expected at character %d, line %d', [c, l]))
    else
      Abort(Format('''' + aString + ''' not expected at character %d, line %d.  ' + aMessage, [c, l]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXMLParser.Warn(const aMessage: String);
  var
    msg: String;
    l, c: Integer;
  begin
    GetLocation(l, c);

    msg := StringReplace(aMessage, '%line', IntToStr(l), [rfIgnoreCase, rfReplaceAll]);
    msg := StringReplace(msg, '%char', IntToStr(c), [rfIgnoreCase, rfReplaceAll]);

    fWarnings.Add(msg);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.ReadName: String;
  var
    c: WideChar;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadName'); try {$endif}

    c := NextChar;
    if NOT IsValidNameStartChar(c) then
      Warn('Character not allowed to start a Name');

    result := c;

    while NOT EOF do
    begin
      c := NextChar;
      if Is_NAMEEND[ANSIChar(c)] then
      begin
        MoveBack;
        EXIT;
      end;

      if NOT IsValidNameChar(c) then
        Warn('Character not allowed in a Name');

      result := result + c;
    end;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.ReadAttributeValue: String;
  var
    c: WideChar;
    qt: Char;
    s: String;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadAttributeValue'); try {$endif}

    c := NextChar;

    if (ANSIChar(c) in ['"', '''']) then
      result := ReadString(c)
    else
    begin
      s := s + c;

      while NOT EOF do
      begin
        c := NextChar;

        if Is_ATTRVALUEEND[ANSIChar(c)] then
        begin
          result := s;
          MoveBack;
          EXIT;
        end;

        s := s + c;
      end;

      UnexpectedEOF;
    end;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.ReadQuotedString: String;
  var
    qt: ANSIChar;
    ws: String;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadQuotedString'); try {$endif}

    qt      := ANSIChar(NextChar(ws));
    result  := ReadString(qt);

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.ReadString: String;
  var
    c: WideChar;
    s: String;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadString'); try {$endif}

    s := '';

    while NOT EOF do
    begin
      c := NextChar;

      if Is_WHITESPACE[ANSIChar(c)] then
      begin
        result := s;
        EXIT;
      end;

      s := s + c;
    end;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.ReadString(const aTerminator: Char): String;
  var
    c: WideChar;
    s: String;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadString('+aTerminator+')'); try {$endif}

    s := '';

    while NOT EOF do
    begin
      c := NextChar;

      if (c = WideChar(aTerminator)) then
      begin
        result := s;
        EXIT;
      end;

      s := s + c;
    end;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.ReadString(const aTerminator: String): String;
  var
    i: Integer;
    c: WideChar;
    endChar: WideChar;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadString(%s)', [aTerminator]); try {$endif}

    result  := '';
    endChar := WideChar(aTerminator[Length(aTerminator)]);

    while NOT EOF do
    begin
      c := NextChar;
      result := result + c;

      if (c = endChar) then
      begin
        for i := Length(aTerminator) downto 1 do
        begin
          if result[Length(result) - (Length(aTerminator) - i)] <> aTerminator[i] then
            BREAK;

          if i = 1 then
          begin
            SetLength(result, Length(result) - Length(aTerminator));
            EXIT;
          end;
        end;
      end;
    end;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.IsNameEndChar(const aChar: WideChar): Boolean;
  begin
    result := Is_NAMEEND[ANSIChar(aChar)];
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.IsValidNameChar(const aChar: WideChar): Boolean;
  begin
    result := Is_VALIDNAMECHAR[ANSIChar(aChar)]
           or (Byte(aChar) = $b7)
           or ((Word(aChar) >= $0300) and (Word(aChar) <= $036f))
           or ((Word(aChar) >= $203f) and (Word(aChar) <= $2040))
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXMLParser.IsValidNameStartChar(const aChar: WideChar): Boolean;
  begin
    result := Is_VALIDNAMESTART[ANSIChar(aChar)]
           or (Byte(aChar) in [$c0..$d6, $d8..$f6])
           or ((Word(aChar) >= $00f8) and (Word(aChar) <= $02ff))
           or ((Word(aChar) >= $0370) and (Word(aChar) <= $037d))
           or ((Word(aChar) >= $037f) and (Word(aChar) <= $1fff))
           or ((Word(aChar) >= $200c) and (Word(aChar) <= $200d))
           or ((Word(aChar) >= $2070) and (Word(aChar) <= $218f))
           or ((Word(aChar) >= $2c00) and (Word(aChar) <= $2fef))
           or ((Word(aChar) >= $3001) and (Word(aChar) <= $dbff))
           or ((Word(aChar) >= $f900) and (Word(aChar) <= $fdcf))
           or ((Word(aChar) >= $fdf0) and (Word(aChar) <= $fffd))
  end;





{$ifdef profile_xmlParser}
initialization
  profiler := TProfile.Create(1, 'parser', 'XML Parser', '', FALSE);
{$endif}

end.
