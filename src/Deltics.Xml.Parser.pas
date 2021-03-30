
{$i deltics.xml.inc}

  unit Deltics.Xml.Parser;


interface

  uses
  { vcl: }
    Classes,
    SysUtils,
  { deltics: }
    Deltics.Strings,
    Deltics.IO.Text;


  type
    TReadStringMethod = function: String of object;

    ExceptionClass = class of Exception;
    EXmlParser = class(Exception);


    IXmlReader = interface(IUtf8Reader)
    ['{7B49549F-7C9C-45DA-95F9-6B2C4B7FBEA4}']
      function get_Errors: TStringList;
      function get_Warnings: TStringList;

      procedure Abort(const aMessage: String; const aExceptionClass: ExceptionClass = NIL);
      procedure Error(const aMessage: String);
      procedure Warning(const aMessage: String);
      procedure ExpectChar(const aExpected: Utf8Char);
      function ExpectOneOf(const aExpected: array of Utf8String): Integer;
      procedure ExpectRealChar(const aExpected: Utf8Char);
      procedure ExpectString(const aExpected: Utf8String);
      procedure ExpectWhitespace;
      procedure MarkLocation;
      procedure UnmarkLocation;
      function ReadName: Utf8String;
      function ReadNameWithoutValidation: Utf8String;
      function ReadWideName(const aValidate: Boolean = TRUE): Utf8String; deprecated;
      function ReadAttributeValue: Utf8String;
      function ReadQuotedString: Utf8String;
      function ReadString: Utf8String; overload;
      function ReadStringUntil(const aTerminator: Utf8Char): Utf8String; overload;
      function ReadStringUntil(const aTerminator: Utf8String): Utf8String; overload;
      procedure UnexpectedChar(const aChar: Utf8Char; const aMessage: String = '');
      procedure UnexpectedEOF;
      procedure UnexpectedString(const aString: String; const aMessage: String = '');
      function IsNameEndChar(const aChar: WideChar): Boolean;
      function IsValidNameChar(const aChar: WideChar): Boolean;
      function IsValidNameStartChar(const aChar: WideChar): Boolean;

      property Errors: TStringList read get_Errors;
      property Warnings: TStringList read get_Warnings;
    end;


    TXmlParser = class(TUtf8Reader, IXmlReader)
    // IXmlReader
    protected
      function get_Errors: TStringList;
      function get_Warnings: TStringList;
      procedure Abort(const aMessage: String; const aExceptionClass: ExceptionClass = NIL);
      procedure Error(const aMessage: String);
      procedure Warning(const aMessage: String);
      procedure ExpectChar(const aExpected: Utf8Char);
      function ExpectOneOf(const aExpected: array of Utf8String): Integer;
      procedure ExpectRealChar(const aExpected: Utf8Char);
      procedure ExpectString(const aExpected: Utf8String);
      procedure ExpectWhitespace;
      procedure MarkLocation;
      procedure UnmarkLocation;
      function ReadName: Utf8String;
      function ReadNameWithoutValidation: Utf8String;
      function ReadWideName(const aValidate: Boolean = TRUE): Utf8String; deprecated;
      function ReadAttributeValue: Utf8String;
      function ReadQuotedString: Utf8String;
      function ReadString: Utf8String; overload;
      function ReadStringUntil(const aTerminator: Utf8Char): Utf8String; overload;
      function ReadStringUntil(const aTerminator: Utf8String): Utf8String; overload;
      procedure UnexpectedChar(const aChar: Utf8Char; const aMessage: String = '');
      procedure UnexpectedEOF;
      procedure UnexpectedString(const aString: String; const aMessage: String = '');
      function IsNameEndChar(const aChar: WideChar): Boolean;
      function IsValidNameChar(const aChar: WideChar): Boolean;
      function IsValidNameStartChar(const aChar: WideChar): Boolean;

    private
      fMarkedLocations: TList;
      fErrors: TStringList;
      fWarnings: TStringList;
      function ReplacePosTokens(const aMessage: String): String;
    public
      constructor Create(const aStream: TStream; const aErrors: TStringList; const aWarnings: TStringList);
      procedure AfterConstruction; override;
    public
      property Errors: TStringList read fErrors write fErrors;
      property Warnings: TStringList read fWarnings write fWarnings;
    end;


implementation

  uses
  {$ifdef InlineMethodsSupported}
    Types,
  {$endif}
    Windows
  {$ifdef profile_xmlParser}
    ,Deltics.Profiler
  {$endif} ;


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

    Is_NAMEEND        : array[#0..#127] of Boolean  = ( TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 1.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 2.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 3.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,
                                              { 4.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE, false, false,  TRUE, false, false,
                                              { 5.}    false, false, false, false, false, false, false, false, false,  TRUE,
                                              { 6.}     TRUE,  TRUE,  TRUE,  TRUE,  TRUE, false, false, false, false, false,
                                              { 7.}    false, false, false, false, false, false, false, false, false, false,
                                              { 8.}    false, false, false, false, false, false, false, false, false, false,
                                              { 9.}    false,  TRUE,  TRUE,  TRUE,  TRUE, false,  TRUE, false, false, false,
                                              {10.}    false, false, false, false, false, false, false, false, false, false,
                                              {11.}    false, false, false, false, false, false, false, false, false, false,
                                              {12.}    false, false, false,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE);


  {$ifNdef UNICODE}
  type
    RawByteString = String;
  {$endif}


  procedure SetUtf8(var s: RawByteString); inline;
  const
    Utf8 = 65001; // CodePage for Utf8
  begin
  {$ifdef UNICODE}
    if Length(s) > 0 then
      PWord(Integer(s) - 12)^ := Utf8;
  {$endif}
  end;




{ TXmlParser ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.AfterConstruction;
  begin
(*
  const
    BOM: array[0..7] of TBOMInfo = (
                                    (Data: ( '<', '?', 'x', 'm'); Len: 4; Encoding: ceUtf8;     IsHeuristic: TRUE),
                                    (Data: (  #0,  #0,  #0, '<'); Len: 4; Encoding: ceUTF32BE;  IsHeuristic: TRUE),
                                    (Data: ( '<',  #0,  #0,  #0); Len: 4; Encoding: ceUTF32LE;  IsHeuristic: TRUE),
                                    (Data: (  #0, '<',  #0, '?'); Len: 4; Encoding: ceUTF16BE;  IsHeuristic: TRUE),
                                    (Data: ( '<',  #0, '?',  #0); Len: 4; Encoding: ceUTF16LE;  IsHeuristic: TRUE),
                                    (Data: (  #0, '<', #99, #99); Len: 2; Encoding: ceUTF16BE;  IsHeuristic: TRUE),
                                    (Data: ( '<',  #0, #99, #99); Len: 2; Encoding: ceUTF16LE;  IsHeuristic: TRUE),
                                    (Data: ( '<', #99, #99, #99); Len: 1; Encoding: ceUtf8;     IsHeuristic: TRUE)
                                   );
  var
    i: Integer;
  begin
    inherited;

    fLocationPos  := 0;
    fLocationLine := 1;
    fLocationChar := 0;

    for i := Low(BOM) to High(BOM) do
      AddBOMSignature(BOM[i]);
*)
    inherited;

    fMarkedLocations := TList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlParser.Create(const aStream: TStream;
                                const aErrors: TStringList;
                                const aWarnings: TStringList);
  begin
    inherited Create(aStream);

    fErrors   := aErrors;
    fWarnings := aWarnings;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReplacePosTokens(const aMessage: String): String;

    function GetLocation: PCharLocation;
    begin
      result := Location;

      if fMarkedLocations.Count > 0 then
        result := fMarkedLocations.Last;
    end;

  var
    loc: PCharLocation;
    msg: String;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReplacePosTokens( .. )'); try {$endif}

    msg := aMessage;

    if System.Pos('%location', msg) <> 0 then
       msg := StringReplace(msg, '%location', 'line %line, character %char', [rfIgnoreCase, rfReplaceAll]);

    if (System.Pos('%line', msg) <> 0)
     or (System.Pos('%char', msg) <> 0) then
    begin
      loc := GetLocation;

      msg := StringReplace(msg, '%line', IntToStr(loc.Line), [rfIgnoreCase, rfReplaceAll]);
      msg := StringReplace(msg, '%char', IntToStr(loc.Character), [rfIgnoreCase, rfReplaceAll]);
    end;

    result := msg;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.Abort(const aMessage: String;
                             const aExceptionClass: ExceptionClass);
  var
    msg: String;
  begin
    msg := ReplacePosTokens(aMessage);

    fErrors.Add(msg);

    if Assigned(aExceptionClass) then
      raise aExceptionClass.Create(msg)
    else
      raise EXmlParser.Create(msg);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.Error(const aMessage: String);
  begin
    fErrors.Add(ReplacePosTokens(aMessage));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.Warning(const aMessage: String);
  begin
    fWarnings.Add(ReplacePosTokens(aMessage));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.ExpectChar(const aExpected: Utf8Char);
  var
    c: Utf8Char;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectChar(%s)', [aExpected]); try {$endif}

    c := NextChar;
    if (c <> aExpected) then
      UnexpectedChar(c, 'Expected ''' + aExpected + '''');

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ExpectOneOf(const aExpected: array of Utf8String): Integer;
  var
    i, j: Integer;
    c: Utf8Char;
    s: Utf8String;
    candidates: TStringList;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectOneOf(..)'); try {$endif}

    MarkLocation;
    try
      candidates := TStringList.Create;
      try
        for i := 0 to Pred(Length(aExpected)) do
          candidates.AddObject(STR.FromUtf8(aExpected[i]), TObject(i));

        j := 0;
        while (candidates.Count > 0) do
        begin
          c := NextChar;
          Inc(j);

          if (candidates.Count = 1) then
          begin
            if (s[j] <> c) then
              BREAK;

            if (j = Length(s)) then
            begin
              result := Integer(candidates.Objects[0]);
              EXIT;
            end;
          end
          else
          begin
            for i := Pred(candidates.Count) downto 0 do
            begin
              s := Utf8.FromString(candidates[i]);
              if (Length(s) < j) or (s[j] <> c) then
                candidates.Delete(i);
            end;

            case candidates.Count of
              0 : BREAK;
              1 : begin
                    s := Utf8.FromString(candidates[0]);

                    if (j = Length(s)) then
                    begin
                      result := Integer(candidates.Objects[0]);
                      EXIT;
                    end;
                  end;
            end;
          end;
        end;

      finally
        candidates.Free;
      end;

      result := -1;

      Abort('Found ''' + STR.FromUtf8(s) + ''' at character %char on line %line, instead of expected.');

    finally
      UnmarkLocation;
    end;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  procedure TXmlParser.ExpectRealChar(const aExpected: Utf8Char);
  var
    c: Utf8Char;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectRealChar(%s)', [aExpected]); try {$endif}

    c := NextCharSkippingWhitespace;
    if (c <> aExpected) then
      UnexpectedChar(c, 'Expected ''' + aExpected + '''');

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.ExpectString(const aExpected: Utf8String);
  var
    i: Integer;
    s: Utf8String;
    ok: Boolean;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ExpectString(%s)', [aExpected]); try {$endif}

    ok := TRUE;
    SetLength(s, Length(aExpected));

    for i := 1 to Length(aExpected) do
    begin
      s[i] := NextChar;
      ok   := (s[i] = aExpected[i]) and ok;
    end;

    if NOT ok then
      UnexpectedString(STR.FromUtf8(s), 'Expected ''' + STR.FromUtf8(aExpected) + '''');

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.ExpectWhitespace;
  var
    c: Utf8Char;
  begin
    if EOF then
      EXIT;

    c := NextChar;
    if NOT Is_WHITESPACE[c] then
      UnexpectedChar(c);

    repeat
      c := NextChar;
    until (NOT Is_WHITESPACE[c]) or EOF;

    if NOT EOF then
      MoveBack;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.get_Errors: TStringList;
  begin
    result := fErrors;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.get_Warnings: TStringList;
  begin
    result := fWarnings;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.UnexpectedChar(const aChar: Utf8Char;
                                      const aMessage: String);
  var
    s: String;
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

    if aMessage = '' then
      Abort(s + ' not expected at character %char, line %line')
    else
      Abort(s + ' not expected at character %char, line %line.  ' + aMessage);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.UnexpectedEOF;
  begin
    Abort('Unexpected end of file');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlParser.UnexpectedString(const aString, aMessage: String);
  begin
    if aMessage = '' then
      Abort('''' + aString + ''' not expected at character %char, line %line')
    else
      Abort('''' + aString + ''' not expected at character %char, line %line.  ' + aMessage);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadName: Utf8String;
  var
    c: Utf8Char;
    l: Integer;
    s: RawByteString;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadName'); try {$endif}

    result := '';

    c := NextChar;
    if NOT Is_VALIDNAMESTART[c] then
      if Is_NAMEEND[c] then
        Abort('A valid XML name is required at character %char on line %line')
      else
        Warning('XML specification 2.3 [4]: ''' + c + ''' is not allowed to start a Name');

    l := 1;
    SetLength(s, 256);

    s[l] := c;
    while NOT EOF do
    begin
      c := NextChar;
      if Is_NAMEEND[c] then
        BREAK;

      if NOT Is_VALIDNAMECHAR[c] then
        Warning('XML specification 2.3 [4a]: Character not allowed in a Name');

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    end;
    SetLength(s, l);
    SetUtf8(s);

    if NOT EOF then
    begin
      result := s;
      MoveBack;
    end
    else
      UnexpectedEOF

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadNameWithoutValidation: Utf8String;
  var
    c: Utf8Char;
    l: Integer;
    s: RawByteString;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadNameWithoutValidation'); try {$endif}

    c := NextChar;

    l := 1;
    SetLength(s, 256);

    s[l] := c;
    while NOT EOF do
    begin
      c := NextChar;
      if Is_NAMEEND[c] then
        BREAK;

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    end;
    SetLength(s, l);
    SetUtf8(s);

    if NOT EOF then
    begin
      result := s;
      MoveBack;
    end
    else
      UnexpectedEOF

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadWideName(const aValidate: Boolean): Utf8String;
  var
    c: WideChar;
    s: UnicodeString;
    l: Integer;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadWideName'); try {$endif}

    c := NextWideChar;
    if aValidate and NOT IsValidNameStartChar(c) then
      Warning('XML specification 2.3 [4]: ''' + c + ''' is not allowed to start a Name');

    SetLength(s, 256);

    l     := 1;
    s[l]  := c;

    while NOT EOF do
    begin
      c := NextWideChar;
      if Is_NAMEEND[ANSIChar(c)] then
      begin
        MoveBack;

        SetLength(s, l);
        result := Utf8.FromString(s);
        EXIT;
      end;

      if aValidate and NOT IsValidNameChar(c) then
        Warning('XML specification 2.3 [4a]: Character not allowed in a Name');

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    end;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadAttributeValue: Utf8String;
  var
    c: Utf8Char;
    l: Integer;
    s: RawByteString;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadAttributeValue'); try {$endif}

    c := NextChar;

    if (c in ['"', '''']) then
    begin
      result := ReadStringUntil(c);
      EXIT;
    end;

    l := 1;
    SetLength(s, 256);

    s[l] := c;

    while NOT EOF do
    begin
      c := NextChar;

      if Is_ATTRVALUEEND[ANSIChar(c)] then
      begin
        SetLength(s, l);
        SetUtf8(s);
        result := s;
        MoveBack;
        EXIT;
      end;

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    end;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadQuotedString: Utf8String;
  var
    qt: Utf8Char;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadQuotedString'); try {$endif}

    qt      := NextCharSkippingWhitespace;
    result  := ReadStringUntil(qt);

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadString: Utf8String;
  var
    c: Utf8Char;
    l: Integer;
    s: RawByteString;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadString'); try {$endif}

    l := 0;
    s := '';

    while NOT EOF do
    begin
      c := NextChar;

      if Is_WHITESPACE[ANSIChar(c)] then
        BREAK;

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    end;
    SetLength(s, l);
    SetUtf8(s);

    if EOF then
      UnexpectedEOF
    else
      result := s;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadStringUntil(const aTerminator: Utf8Char): Utf8String;
  var
    c: Utf8Char;
    l: Integer;
    s: RawByteString;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadString(' + aTerminator + ' : Utf8Char terminator)'); try {$endif}

    l := 0;
    s := '';

    while NOT EOF do
    begin
      c := NextChar;

      if (c = aTerminator) then
        BREAK;

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    end;

    if NOT EOF then
    begin
      SetLength(s, l);
      SetUtf8(s);
      result := s;
    end
    else
      UnexpectedEOF

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.ReadStringUntil(const aTerminator: Utf8String): Utf8String;
  var
    i: Integer;
    c: Utf8Char;
    l: Integer;
    s: RawByteString;
    endChar: Utf8Char;
    terminatorLength: Integer;
  begin
  {$ifdef profile_xmlParser} profiler.Start('ReadString(%s : String terminator)', [aTerminator]); try {$endif}

    l := 0;
    s := '';
    c := #0;

    terminatorLength  := Length(aTerminator);
    endChar           := aTerminator[terminatorLength];

    if terminatorLength > 256 then
      SetLength(s, terminatorLength)
    else
      SetLength(s, 256);

    // Until we have read at least the same number of characters as are present
    //  in the terminator it is impossible to match that terminator, so we have
    //  a much simpler initial read loop.

    while NOT EOF and (l < terminatorLength) do
    begin
      c := NextChar;

      Inc(l);
      s[l] := c;
    end;

    // Now that the value we are reading COULD match the terminator, we have an
    //  additional check to perform before reading each following character.

    repeat
      if (c = endChar) then
      begin
        // The char we just read matches the final char in the specified terminator.
        //  We check each preceding character - if it matches the terminator exactly
        //  then we are done.

        for i := terminatorLength downto 1 do
        begin
          if s[l - (terminatorLength - i)] <> aTerminator[i] then
            BREAK;

          if i = 1 then
          begin
            // The entire terminator was matched so we finish reading the string
            //  at this point and return what we have so far

            SetLength(s, l - terminatorLength);
            SetUtf8(s);
            result := s;
            EXIT;
          end;
        end;
      end;

      c := NextChar;

      Inc(l);
      if l > Length(s) then
        SetLength(s, Length(s) + 256);

      s[l] := c;
    until EOF;

    UnexpectedEOF;

  {$ifdef profile_xmlParser} finally profiler.Finish end; {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.IsNameEndChar(const aChar: WideChar): Boolean;
  begin
    result := (Word(aChar) < $0100) and Is_NAMEEND[ANSIChar(aChar)];
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.IsValidNameChar(const aChar: WideChar): Boolean;
  begin
    result := ((Word(aChar) < $0100) and (Is_VALIDNAMECHAR[ANSIChar(aChar)]
                                          or (Byte(aChar) = $b7)))
           or ((Word(aChar) >= $0300) and (Word(aChar) <= $036f))
           or ((Word(aChar) >= $203f) and (Word(aChar) <= $2040))
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlParser.IsValidNameStartChar(const aChar: WideChar): Boolean;
  begin
    result := ((Word(aChar) < $0100) and (   Is_VALIDNAMESTART[ANSIChar(aChar)]
                                          or (Byte(aChar) in [$c0..$d6, $d8..$f6])))
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



  procedure TXmlParser.MarkLocation;
  var
    loc: PCharLocation;
  begin
    GetMem(loc, sizeof(TCharLocation));
    CopyMemory(Location, loc, sizeof(TCharLocation));

    fMarkedLocations.Add(loc);
  end;


  procedure TXmlParser.UnmarkLocation;
  var
    loc: PCharLocation;
  begin
    loc := fMarkedLocations.Last;
    fMarkedLocations.Remove(loc);

    FreeMem(loc);
  end;




{$ifdef profile_xmlParser}
initialization
  profiler := TProfile.Create(1, 'parser', 'XML Parser', '', TRUE);
{$endif}

end.
