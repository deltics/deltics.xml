

  unit Samples;


interface

  function Sample(const aSampleName: String): String;


implementation

  uses
    Deltics.IO.Path;


  function Sample(const aSampleName: String): String;
  begin
  {$ifdef _CICD}
    result := Path.RelativeToAbsolute('.\samples\' + aSampleName + '.xml');
  {$else}
    result := 'X:\dev\src\delphi\libs\congress\deltics.xml\tests\samples\' + aSampleName + '.xml';
  {$endif}
  end;



end.
