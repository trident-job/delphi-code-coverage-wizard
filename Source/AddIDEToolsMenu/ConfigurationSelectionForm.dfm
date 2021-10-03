object ConfigSelectionForm: TConfigSelectionForm
  Left = 0
  Top = 0
  Caption = 'Which IDEs shall contain this in Tools menu?'
  ClientHeight = 241
  ClientWidth = 516
  Color = clBtnFace
  Constraints.MinHeight = 220
  Constraints.MinWidth = 532
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  DesignSize = (
    516
    241)
  TextHeight = 15
  object LabelDescription: TLabel
    Left = 8
    Top = 8
    Width = 500
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Select the IDEs/configurations in which %0:s shall be available ' +
      'in "Tools" menu'
    WordWrap = True
  end
  object ListViewConfigurations: TListView
    Left = 8
    Top = 55
    Width = 502
    Height = 138
    Anchors = [akLeft, akTop, akRight, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = 'Rad Studio version'
        Width = 200
      end
      item
        Caption = 'Configuration name'
        Width = 150
      end>
    ColumnClick = False
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ButtonOK: TButton
    Left = 8
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Ok'
    ModalResult = 1
    TabOrder = 1
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TButton
    Left = 135
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object ButtonSelectAll: TButton
    Left = 262
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Select &all'
    TabOrder = 3
    OnClick = ButtonSelectAllClick
  end
  object ButtonDeselectAll: TButton
    Left = 389
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Deselect all'
    TabOrder = 4
    OnClick = ButtonDeselectAllClick
  end
end
