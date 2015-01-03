package;

///import sys.FileSystem;
//import sys.io.File;
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
		var srv = new WebServer();
		cfg = [
			"host" => "localhost",
			"port" => "5000",
			"root" => ".",
// rewrite 'fs' to docs 'root'
			"fs" => "/fs/", // fs=%2Ffs%2F&login=%2Flogin%2F
// Base64('$user:$password')
			"auth" => "Basic dG9uZHk6aGFrbw==",
			"login" => "/login/",
			"index" => "index.html, index.htm, index.hxs",
			"threads" => "2"
		];
 
		srv.config(cfg);
		srv.app = app;
		Thread.create(srv.start);

		while(true){ 
			update(updateTime);
		}
	}// new()
	
	function app(ctx:Map<String,String>,form:Map<String,Array<String>>=null)
	{  
		ctx["mime"] = "";
		var host = cfg["host"]+":"+cfg["port"];
		var body = '<h2>${ctx["request"]}</h2>${Date.now()}<br><a href="/?d=${Std.random(10000)}">Refresh</a><p><a href="/fs/">FS</a></p><p><a href="/exit">Exit</a></p>';

		if(ctx["request"] == "/exit"){
			ctx["body"] = '<center><h2>Stop Hako?</h2>[ <a href="/login/exit">Yes</a> ] ... [ <a href="/">No</a> ]<p>user: tondy<br>pass: hako</p></center>';
		}else if(ctx["request"] == "/login/exit"){
			trace(ctx["Referer"]);
			if(ctx.exists("Referer") && ctx["Referer"] == 'http://$host/exit')exitTime = 1;
			else{
				ctx["status"] = "303";
				ctx["path"] = "/";
			}
		}else if(ctx["request"] == "/upload"){
			if(form != null){
				
			}else ctx["body"] = body;
		}else {
			ctx["body"] = body;
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

