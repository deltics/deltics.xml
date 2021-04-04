
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Dtd;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes,
    Deltics.Xml.Types;


  type
    TXmlDtdDeclaration = class(TXmlNode, IXmlDtdDeclaration)
    protected // IXmlDtdDeclaration

    protected
      procedure Assign(const aSource: TXmlNode); override;
    end;




implementation


{ TxmlDtdDeclaration ----------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdDeclaration.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdDeclaration absolute aSource;
  begin
    inherited;

  end;




end.

