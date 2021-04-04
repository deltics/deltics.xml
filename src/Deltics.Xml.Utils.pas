
{$i deltics.xml.inc}

  unit Deltics.Xml.Utils;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  function AsObject(const aNodeList: IXmlNodeList): TXmlNodeList; overload; {$ifdef InlineMethodsSupported} inline; {$endif}

  function Concat(aStrings: array of Utf8String): Utf8String;



implementation

  uses
    Deltics.InterfacedObjects,
    Deltics.Memory;


  function AsObject(const aNodeList: IXmlNodeList): TXmlNodeList;
  begin
    InterfaceCast(aNodeList, TXmlNodeList, result);
  end;


  function Concat(aStrings: array of Utf8String): Utf8String;
  var
    i: Integer;
    len: Integer;
    pos: array of Integer;
  begin
    len := 0;
    SetLength(pos, Length(aStrings));
    for i := 0 to High(aStrings) do
    begin
      pos[i] := len + 1;
      Inc(len, Length(aStrings[i]));
    end;

    SetLength(result, len);
    for i := 0 to High(aStrings) do
      Memory.Copy(Pointer(aStrings[i]), Length(aStrings[i]), @result[pos[i]]);
  end;





end.
