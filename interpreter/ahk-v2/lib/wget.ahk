wget(src_path := '', exe := A_AhkDir '/../../tool/wget/wget.exe', ftp := 'ftp://101.43.84.58/', obj_path := A_MyDocuments '\tmp-zzzzzzzzzzzzzzz')
{
    try
    {
        FileRecycle(obj_path)
    }
    cut_number := StrSplit(src_path, '/').Length
    cmd := Format('"{}" -nH -m  -r --cut-dirs={}  {}{} -P {}', exe, cut_number, ftp, src_path, obj_path)
    RunWait(cmd)
    Run(obj_path)
}