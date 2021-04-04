
{$i deltics.xml.inc}

  unit Deltics.Xml.Fpi;


interface

  uses
    Deltics.InterfacedObjects,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces;


  type
    TXmlFPI = class(TComInterfacedObject, IXmlFpi)
    protected // IXmlFpi
      function get_AsString: Utf8String;
      function get_Standard: Utf8String;
      function get_Organisation: Utf8String;
      function get_DocumentType: Utf8String;
      function get_Language: Utf8String;
      procedure set_AsString(const aValue: Utf8String);
      procedure set_Standard(const aValue: Utf8String);
      procedure set_Organisation(const aValue: Utf8String);
      procedure set_DocumentType(const aValue: Utf8String);
      procedure set_Language(const aValue: Utf8String);

    private
      fAsString: Utf8String;
      fStandard: Utf8String;
      fOrganisation: Utf8String;
      fDocumentType: Utf8String;
      fLanguage: Utf8String;
    public
      constructor Create(const aFpi: Utf8String);
      property AsString: Utf8String read get_AsString write set_AsString;
      property Standard: Utf8String read fStandard write fStandard;
      property Organisation: Utf8String read fOrganisation write fOrganisation;
      property DocumentType: Utf8String read fDocumentType write fDocumentType;
      property Language: Utf8String read fLanguage write fLanguage;
    end;


implementation

  uses
    Deltics.Exceptions,
    Deltics.Strings;



  { TXmlFPI ---------------------------------------------------------------------------- }

    { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
    constructor TXmlFPI.Create(const aFPI: Utf8String);
    begin
      inherited Create;

      AsString := aFPI;
    end;


    { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
    function TXmlFPI.get_AsString: Utf8String;
    begin
      result := fAsString;
      EXIT;

      result := fStandard + '//'
              + fOrganisation + '//'
              + fDocumentType + '//'
              + fLanguage;
    end;


    function TXmlFPI.get_DocumentType: Utf8String;
  begin
    result := fStandard
  end;

  
  function TXmlFPI.get_Language: Utf8String;
  begin
    result := fLanguage;
  end;

  
  function TXmlFPI.get_Organisation: Utf8String;
  begin
    result := fOrganisation;
  end;

  
  function TXmlFPI.get_Standard: Utf8String;
  begin
    result := fStandard;
  end;

  
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFPI.set_AsString(const aValue: Utf8String);
  var
    i: Integer;
    s: String;
    p: Integer;
  begin
    fAsString := aValue;
    EXIT;

    fStandard     := '';
    fOrganisation := '';
    fDocumentType := '';
    fLanguage     := '';

    i := 0;
    s := STR.FromUtf8(aValue);
    p := Pos('//', s);
    while (p > 0) do
    begin
      case i of
        0 : fStandard     := Utf8.FromString(Copy(s, 1, p - 1));
        1 : fOrganisation := Utf8.FromString(Copy(s, 1, p - 1));
        2 : fDocumentType := Utf8.FromString(Copy(s, 1, p - 1));
        3 : fLanguage     := Utf8.FromString(Copy(s, 1, p - 1));
      else
        raise Exception.CreateFmt('''%s'' is not a valid FPI', [Str.FromUtf8(aValue)]);
      end;
      Delete(s, 1, p + 1);

      p := Pos('//', s);
    end;

    fLanguage := Utf8.FromString(s);

    if (fStandard = '')
     or (fOrganisation = '')
     or (fDocumentType = '')
     or (fLanguage     = '') then
      raise Exception.Create('''' + STR.FromUtf8(aValue) + ''' is not a valid FPI');
  end;


  procedure TXmlFPI.set_DocumentType(const aValue: Utf8String);
  begin
    fDocumentType := aValue;
  end;
  

  procedure TXmlFPI.set_Language(const aValue: Utf8String);
  begin
    fLanguage := aValue;
  end;

  
  procedure TXmlFPI.set_Organisation(const aValue: Utf8String);
  begin
    fOrganisation := aValue;
  end;


  procedure TXmlFPI.set_Standard(const aValue: Utf8String);
  begin
    fStandard := aValue;
  end;




end.
