package;

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

typedef FS = sys.FileSystem;
typedef FL = sys.io.File;

class Hako extends AM{

	public function new()
	{
		AM.verbose = 1;
		AM.useArgs = false;
		super();
		updateTime = 1;
		var cfg = [
			"host" => "localhost",
			"port" => "5000",
			"root" => ".",
			"index" => "index.n",
			"threads" => "4"
			];
		var srv = new WebServer();
		srv.config(cfg);
		srv.app = app;
		var worker = Thread.create(srv.start);

		while(true){ 
			update(updateTime);
		}
	}// new()
	
	function app(ctx:Map<String,String>):String
	{  
		var ext = ctx["query"].extname();
		if(ctx["query"] == "/favicon.ico")ctx["query"] = "/img/favicon.ico";
		if(ctx["query"].startsWith("/?dir=")){ 
			var p = ctx["query"].substr(6); 
			if(!p.good())p = ".";
			var ref = "#";
			if(ctx.exists("Referer"))ref = ctx["Referer"];
			ctx["body"] = '<p><a href="/">Home</a></p>'+WT.getDir(p);
		}else if(ext.good() && FS.exists("."+ctx["query"])){
			ctx["type"] = WT.mimeType[ext];
			ctx["body"] = FL.getContent("."+ctx["query"]);
		}else if(ctx["query"] == "/exit"){
			exitTime = 1;
		}else {
			ctx["body"] = Date.now() + '<br><a href="/?d=${Std.random(10000)}">refresh</a><p><a href="/?dir=">FS</a></p><p><a href="/exit">Exit</a></p>';
		}
		
		return WT.response(ctx);
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

