class Zmq_send2plug
{
    __New() 
    {
		zmq_version(&a := 0, &b := 0, &c := 0)
		logger.info("zmq版本: ", a, b, c)
		this.ctx := ctx := g_zmq_ctx
		this.socket := socket := zmq_socket(ctx, ZMQ_PUB)
		rtn := zmq_bind(socket, "inproc://main")
    }
    __Delete() 
	{
		zmq_close(this.socket)
		zmq_ctx_shutdown(this.ctx)
	}
	pub(data := unset)
	{
		if(IsSet(data) && (InStr(data, '/') == 1 || InStr(data, '@stop')))
        	zmq_send_string(this.socket, data,,ZMQ_DONTWAIT)
	}
}