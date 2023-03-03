class huma
{
    __New(huma_path := 'huma.json')
    {
        if(!FileExist(huma_path))
        {
            MsgBox(' huma.json not exist!')
            return
        }
        try
        {
            json_str := FileRead(huma_path, 'UTF-8')
            this.map_hum := JSON.parse(json_str)
        }
        catch as e
        {
            MsgBox('parse hum.json error :', e.Message)
            return
        }
    }
    code(str)
    {
        rtn_code := ''
        word_array := StrSplit(str)
        for k,v in word_array
        {
            if(this.map_hum.Has(v))
                rtn_code .= this.map_hum[v]
            else
                rtn_code .= v
        }
        return rtn_code
    }
}