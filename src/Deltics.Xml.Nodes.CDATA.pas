
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.CDATA;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlCDATA = class(TXmlNode, IXmlCDATA)
    protected // IXmlNode
      function get_Name: Utf8String; override;
      function get_Text: UTF8String; override;

    protected // IXmlCDATA
      procedure set_Text(const aValue: UTF8String);

    private
      fText: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aText: Utf8String);
    end;


implementation

  uses
    Deltics.Xml.Types;


{ TXmlCDATA -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlCDATA.Create(const aText: Utf8String);
  begin
    inherited Create(xmlCDATA);

    fText := aText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlCDATA.get_Name: Utf8String;
  begin
    result := '#cdata-section';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlCDATA.get_Text: Utf8String;
  begin
    result := fText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlCDATA.set_Text(const aValue: UTF8String);
  begin
    fText := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlCDATA.Assign(const aSource: TXmlNode);
  var
    src: TXmlCData absolute aSource;
  begin
    inherited;

    fText := src.fText;
  end;


end.
