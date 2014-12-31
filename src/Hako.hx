package;

import sys.FileSystem;
import sys.io.File;
import abv.AM;
import abv.net.web.WebServer;
import abv.net.web.WT;
#if neko
import neko.vm.Thread;
#else
import cpp.vm.Thread;
#end

using StringTools;
using abv.CT;

class Hako extends AM{

	public function new()
	{
		AM.verbose = 0;
		AM.useArgs = false;
		super();
		updateTime = 1;
		var cfg = [
			"host" => "localhost",
			"port" => "5000",
			"root" => ".",
			"fs" => "/fs/",
			"index" => "index.html,index.htm",
			"threads" => "4"
			];
		var srv = new WebServer();
		srv.config(cfg);
		srv.app = app;
		Thread.create(srv.start);

		while(true){ 
			update(updateTime);
		}
	}// new()
	
	function app(ctx:Map<String,String>)
	{  
		if(ctx["query"] == "/exit"){
			exitTime = 1;
		}else {
			ctx["body"] = Date.now() + '<br><a href="/?d=${Std.random(10000)}">refresh</a><p><a href="/fs/">FS</a></p><p><a href="/exit">Exit</a></p>';
		}
		
//		return WT.response(ctx);
	}// app();

	override function update(delta:Null<Float> = null)
	{
		exitTime *= 2;
		if(exitTime > 2) exit();
		sleep(delta);
	}// update()
		
	override function exit()
	{
		CT.printLog();
		sleep(.5);
		Sys.exit(err);
	}// exit()

	public static function main() 
	{
		var s = new Hako();
		
	}

}// Hako

