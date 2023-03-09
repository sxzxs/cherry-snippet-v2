class Zmq_send2plug
{
    __New() 
    {
		zmq_version(&a := 0, &b := 0, &c := 0)
		logger.info("zmq版本: ", a, b, c)
		this.ctx := ctx := g_zmq_ctx
		this.socket := socket := zmq_socket(ctx, ZMQ_PUB)
		rtn := zmq_bind(socket, "inproc://main")

		this.socket2tool := socket2tool := zmq_socket(ctx, ZMQ_PUB)
		rtn := zmq_bind(socket2tool, "tcp://*:29935") ;tcp://localhost:19936
    }
    __Delete() 
	{
		zmq_close(this.socket)
		zmq_close(this.socket2tool)
		zmq_ctx_shutdown(this.ctx)
	}
	pub(data := unset)
	{
		if(IsSet(data) && (InStr(data, '/') == 1 || InStr(data, '@stop') || InStr(data, '@exit')))
		{
        	zmq_send_string(this.socket, data,,ZMQ_DONTWAIT)
        	zmq_send_string(this.socket2tool, data,,ZMQ_DONTWAIT)
			if(InStr(data, '/ai'))
				Main_gui.Hide('')
		}
	}
}