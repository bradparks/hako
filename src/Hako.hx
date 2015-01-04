package;

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

	var srv:WebServer;

	public function new()
	{ 
		AM.verbose = 0;
		AM.useArgs = false;
		super();
		updateTime = 1;
		cfg = [
			"host" => "localhost",
			"port" => "5000",
			"root" => ".",
// url rewrite 
			"urls" => "fs=/fs/ & login=/login/",
// haxe.crypto.Base64.encode(haxe.io.Bytes.ofString('user:pass'))
			"auth" => "Basic dXNlcjpwYXNz",
			"index" => "index.html, index.htm, index.hxs",
			"threads" => "2"
		];
 
 		srv = new WebServer();
		srv.config(cfg);
		srv.app = app;
		Thread.create(srv.start);

		while(true){ 
			update(updateTime);
		}
	}// new()
	
	function app(ctx:Map<String,String>,form:Map<String,String>=null)
	{  
		ctx["mime"] = "";
		var host = cfg["host"]+":"+cfg["port"];
		var body = '<h2>${ctx["request"]}</h2>${Date.now()}<br><a href="/?d=${Std.random(10000)}">Refresh</a><p><a href="/fs/">FS</a></p><p><a href="/exit">Exit</a></p>';
		var s = "",t = "";
		var tmp = "www/tmp/";
		
		if(ctx["request"] == "/exit"){
			ctx["body"] = WT.mkPage('<center><h2>Stop Hako?</h2>[ <a href="/login/exit">Yes</a> ] ... [ <a href="/">No</a> ]<p>user: user<br>pass: pass</p></center>',"Exit");
		}else if(ctx["request"] == "/login/exit"){
			trace(ctx["Referer"]);
			if(ctx.exists("Referer") && ctx["Referer"] == 'http://$host/exit')exitTime = 1;
			else{
				ctx["status"] = "303";
				ctx["path"] = "/";
			}
		}else if(ctx["request"] == "/upload"){
			if(form != null){
				s += "<p>";
				for(k in form.keys()){
					if(form[k].startsWith("file:")){
						t = form[k].substr(5);
						var a = t.split("|||");
						s += '$k: ${a[0]}<br>';
						try File.saveContent(tmp+a[0],a[2])
						catch(m:Dynamic){trace(m);}
					}else s += '$k: ${form[k]}<br>';
				}
				s += "</p><p><strong>"+tmp+"</strong><br>" + WT.dirIndex(tmp,srv.urls["fs"],true) + "</p>";
				ctx["body"] = WT.mkPage(s+body,"upload"); 
			}else ctx["body"] = WT.mkPage(body,"upload");
		}else {
			ctx["body"] = WT.mkPage(body);
		}
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

