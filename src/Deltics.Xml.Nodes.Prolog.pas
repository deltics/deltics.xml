
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Prolog;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlProlog = class(TXmlNode, IXmlProlog)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDeclaration
      function get_Version: Utf8String;
      function get_Encoding: Utf8String;
      function get_Standalone: Utf8String;
      procedure set_Version(const aValue: Utf8String);
      procedure set_Standalone(const aValue: Utf8String);

    private
      fVersion: Utf8String;
      fEncoding: Utf8String;
      fStandalone: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aVersion, aEncoding, aStandalone: Utf8String);
      property Version: Utf8String read fVersion write fVersion;
      property Encoding: Utf8String read fEncoding;
      property Standalone: Utf8String read fStandalone write fStandalone;
    end;




implementation

  uses
    Deltics.Strings,
    Deltics.Xml.Types;


{ TXmlDeclaration -------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlProlog.Create(const aVersion, aEncoding, aStandalone: Utf8String);
  begin
    inherited Create(xmlProlog);

    fVersion    := aVersion;
    fEncoding   := aEncoding;
    fStandalone := aStandalone;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProlog.get_Encoding: Utf8String;
  begin
    result := fEncoding;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProlog.get_Name: Utf8String;
  begin
    result := '#prolog';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProlog.get_Standalone: Utf8String;
  begin
    result := fStandalone;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProlog.get_Version: Utf8String;
  begin
    result := fVersion;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlProlog.set_Standalone(const aValue: Utf8String);
  begin
    fStandalone := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlProlog.set_Version(const aValue: Utf8String);
  begin
    fVersion := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlProlog.Assign(const aSource: TXmlNode);
  var
    src: TXmlProlog absolute aSource;
  begin
    inherited;

    fVersion    := src.Version;
    fEncoding   := src.Encoding;
    fStandalone := src.Standalone;
  end;




end.
