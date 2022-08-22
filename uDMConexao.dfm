object dmConexao: TdmConexao
  OldCreateOrder = False
  Height = 349
  Width = 430
  object conexao: TFDConnection
    Params.Strings = (
      'Database=datasnap_teste'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=127.0.0.1'
      'Port=3050'
      'DriverID=FB')
    Connected = True
    LoginPrompt = False
    Left = 144
    Top = 128
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Console'
    ScreenCursor = gcrNone
    Left = 144
    Top = 64
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 256
    Top = 64
  end
  object Transacao: TFDTransaction
    Connection = conexao
    Left = 256
    Top = 128
  end
end
