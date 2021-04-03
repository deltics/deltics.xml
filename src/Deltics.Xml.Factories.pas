
{$i deltics.xml.inc}

  unit Deltics.Xml.Factories;


interface

  uses
    Classes,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces;


  type
    XmlDocument = class
    public
      class function FromString(const aString: String): IXmlDocument;
      class function LoadFromFile(const aFilename: String): IXmlDocument;
      class function LoadFromStream(const aStream: TStream): IXmlDocument;
      class function New: IXmlDocument;
    end;


    XmlElement = class
    public
      class function Create(const aName: Utf8String): IXmlElement;
    end;


implementation

  uses
    SysUtils,
    Deltics.StringLists,
    Deltics.Xml.Nodes.Document,
    Deltics.Xml.Nodes.Elements,
    Deltics.Xml.Reader;


{ XmlDocument ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocument.New: IXmlDocument;
  begin
    result := TXmlDocument.Create;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocument.FromString(const aString: String): IXmlDocument;
  var
    strm: TStringStream;
  begin
    strm := TStringStream.Create(aString);
    try
      result := LoadFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocument.LoadFromFile(const aFilename: String): IXmlDocument;
  var
    strm: TFileStream;
  begin
    strm := TFileStream.Create(aFilename, fmOpenRead or fmShareDenyWrite);
    try
      result := LoadFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function XmlDocument.LoadFromStream(const aStream: TStream): IXmlDocument;
  var
    reader: TXmlReader;
  begin
    result := TXmlDocument.Create;
    reader := TXmlReader.Create;
    try
      result := reader.LoadDocument(aStream, TStringList.CreateManaged, TStringList.CreateManaged);

    finally
      reader.Free;
    end;
  end;




{ XmlElement }

  class function XmlElement.Create(const aName: Utf8String): IXmlElement;
  begin
    result := TXmlElement.Create(aName);
  end;



end.
