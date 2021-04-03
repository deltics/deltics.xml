
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Dtd.Entities;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Nodes.Dtd;


  type
    TXmlDtdEntity = class(TXmlDtdDeclaration, IXmlDtdEntity)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDtdEntity
      function get_Content: Utf8String;

    private
      fName: Utf8String;
      fContent: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aName: Utf8String; const aContent: Utf8String);
      property Name: Utf8String read fName;
      property Content: Utf8String read fContent;
    end;



implementation

  uses
    Deltics.Xml.Types;


{ TXmlDtdEntity ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdEntity.Create(const aName: Utf8String;
                                              const aContent: Utf8String);
  begin
    inherited Create(xmlDtdEntity);

    fName     := aName;
    fContent  := aContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdEntity.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdEntity absolute aSource;
  begin
    inherited;

    fName     := src.fName;
    fContent  := src.fContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdEntity.get_Content: Utf8String;
  begin
    result := fContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdEntity.get_Name: Utf8String;
  begin
    result := fName;
  end;



end.

