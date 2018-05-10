# SwiftJavascriptDemo

### 1、Swift代码
##### ViewController.swift
```
import UIKit
import JavaScriptCore

/// 定义协议SwiftJavaScriptDelegate 该协议必须遵守JSExport协议
@objc protocol SwiftJavaScriptDelegate: JSExport
{
    func showTips(_ tips: String)
}

/// 定义一个模型 该模型实现SwiftJavaScriptDelegate协议
@objc class SwiftJavaScriptModel: NSObject, SwiftJavaScriptDelegate
{
    weak var jsContext: JSContext?
    
    func showTips(_ tips: String)
    {
        print(tips)
    }
}

class ViewController: UIViewController
{
    /// HTML网址，需要修改成你自己的
    let urlString = "http://192.168.1.109:8888/ActivityDetail.html"
    
    var webView: UIWebView!
    
    var jsContext: JSContext!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        addWebView()
    }

    func addWebView()
    {
        webView = UIWebView(frame: self.view.bounds)
        view.addSubview(webView)
        webView.delegate = self
        webView.scalesPageToFit = true
        
        // 加载线上 html 文件
//        let url = URL(string: urlString)
//        let request = URLRequest(url: url!)
        
        // 加载本地 html 文件
        let path = Bundle.main.path(forResource: "ActivityDetail", ofType: "html")
        let url = URL(string: path!)
        let request = URLRequest(url: url!)
        
        
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
   
}

extension ViewController: UIWebViewDelegate
{
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        self.jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        let model = SwiftJavaScriptModel()
        
        model.jsContext = self.jsContext
        
        // 这一步是将SwiftJavaScriptModel模型注入到JS中，在JS就可以通过WebViewJavascriptBridge调用我们暴露的方法了。
        self.jsContext.setObject(model, forKeyedSubscript: "WebViewJavascriptBridge" as NSCopying & NSObjectProtocol)
    }
}
```

### 2、HTML代码
##### ActivityDetail.html
```
<!DOCTYPE html>
<html>
<head>
	
	<title>测试HTML</title>
	
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">  
	<meta charset="UTF-8">
    <meta name="viewport"
        content="width=device-width,initial-scale=1,minimum-scale=1, maximum-scale=1, user-scalable=no">
	
	<style>
		.button {
			line-height: 45px;
    		margin: 10px auto;
    		color: #fff;
    		background: #8bc53f;
    		border-radius: 5px;
		    text-align: center;
		   	font-size: 20px;
		}
	</style>
	
</head>
	
<body>
	
	<div class="button" onclick="btn()">
        Javascript调用App的方法showTips()
    </div>

    <script type="text/javascript">
        
		function btn(){
			WebViewJavascriptBridge.showTips("hello,maizhichao");
		}
    
    </script>
	
</body>
	
</html>
```
>参考自：https://github.com/YanlongMa/SwiftJavaScriptCore
