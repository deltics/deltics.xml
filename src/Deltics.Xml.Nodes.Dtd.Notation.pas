
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Dtd.Notation;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Nodes.Dtd;


  type
    TXmlDtdNotation = class(TXmlDtdDeclaration, IXmlDtdNotation)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDtdNotation
      // TBD

    private
      fName: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aName: Utf8String);
    end;



implementation

  uses
    Deltics.Xml.Types;


{ TXmlDtdEntity ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdNotation.Create(const aName: Utf8String);
  begin
    inherited Create(xmlDtdNotation);

    fName := aName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdNotation.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdNotation absolute aSource;
  begin
    inherited;

    fName := src.fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdNotation.get_Name: Utf8String;
  begin
    result := fName;
  end;



end.

