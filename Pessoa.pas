unit Pessoa;

interface

uses
 uAtributos,
 uConstantes,
 uModel,
 System.Classes;
type
  [TEntity]
  [TTable('PESSOA')]
  TPessoa = class(TModel)
  private
    FNOME: String;
    FID: Integer;
    FSOBRE_NOME: String;

  public
    [TId('ID')]
    [TGeneratedValue(sAuto)]
    [TFormatter(ftZerosAEsquerda, taCenter)]
    property ID: Integer  read FID write FID;
    [TColumn('NOME','NOME',255,[ldGrid, ldLookup], False)]
    property NOME: String  read FNOME write FNOME;
    [TColumn('SOBRE_NOME','SOBRE_NOME',255,[ldGrid, ldLookup], False)]
    property SOBRE_NOME: String  read FSOBRE_NOME write FSOBRE_NOME;

  end;

implementation



end.

