item := 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\00000000'
key_value := [{key : 'Layout Display Name', value : '@%SystemRoot%\system32\input.dll,-5072', type : 'REG_SZ'},
				{key : 'Layout File', value : 'KBDUS.DLL', type : 'REG_SZ'},
				{key : 'Layout Id', value : '00AE ', type : 'REG_EXPAND_SZ'},
				{key : 'Layout Text', value : 'Chinese (Simplified) - US Keyboard', type : 'REG_SZ'}]

for k,v in key_value
{
	for i,j in v
	{
		RegWrite v.Value, v.Type, item, v.key
	}
}