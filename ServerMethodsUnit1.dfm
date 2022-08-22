object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  OnCreate = DSServerModuleCreate
  OnDestroy = DSServerModuleDestroy
  Height = 258
  Width = 471
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrNone
    Left = 48
    Top = 24
  end
  object FDStanStorageBinLink: TFDStanStorageBinLink
    Left = 168
    Top = 24
  end
  object FDStanStorageJSONLink: TFDStanStorageJSONLink
    Left = 287
    Top = 24
  end
  object qPessoas: TFDQuery
    Connection = dmConexao.conexao
    SQL.Strings = (
      'select * from pessoa')
    Left = 48
    Top = 78
  end
end
