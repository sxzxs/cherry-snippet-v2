class Zmq_send2cherry
{
	__New() 
	{
		zmq_version(&a := 0, &b := 0, &c := 0)
		logger.info("zmq版本: ", a, b, c)
		this.ctx := ctx := zmq_ctx_new()
		this.socket := socket := zmq_socket(ctx, ZMQ_PUSH)
		rtn := zmq_connect(socket, "tcp://localhost:19935")
		this.cmd := child_process('cmd.exe', , , { cwd: A_Desktop, encoding: 'cp' DllCall('GetOEMCP', 'uint') })
		this.cmd.onData := (s, k, l) => (logger.info(l))
	}
	__Delete() 
	{
		zmq_close(this.socket)
		zmq_ctx_shutdown(this.ctx)
	}
	send_command(data := unset)
	{
		try
		{
			if(IsSet(data))
			{
				zmq_send_string(this.socket, data)
				this.cmd.stdin.Write('"' cfg['cherry_tree_path'] '" "'  cfg['db_path'] '"`n')
				this.cmd.stdin.Flush()
			}
			else
			{
				this.cmd.stdin.Write('"' cfg['cherry_tree_path'] '" "'  cfg['db_path'] '"`n')
				this.cmd.stdin.Flush()
			}
		}
	}
}