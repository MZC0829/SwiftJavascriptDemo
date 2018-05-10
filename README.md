# SwiftJavascriptDemo
## Swift 与 JS 交互

![demo.png](https://upload-images.jianshu.io/upload_images/4886396-b40e4f41d1bfb6a0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)

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
    
    var button: UIButton!
    
    var jsContext: JSContext!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        addWebView()
        
        addButton()
    }

    func addWebView()
    {
        webView = UIWebView(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: 300))
        view.addSubview(webView)
        webView.delegate = self
        webView.scalesPageToFit = true
        
//        // 加载线上 html 文件
//        let url = URL(string: urlString)
//        let request = URLRequest(url: url!)
        
        // 加载本地 html 文件
        let path = Bundle.main.path(forResource: "ActivityDetail", ofType: "html")
        let url = URL(string: path!)
        let request = URLRequest(url: url!)
       
        webView.loadRequest(request)
    }
    
    func addButton()
    {
        button = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 100, width: view.bounds.width - 40, height: 45))
        button.backgroundColor = UIColor.orange
        button.setTitle("原生Button调用JS方法", for: .normal)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func buttonTap()
    {
        self.webView.stringByEvaluatingJavaScript(from: "jsAction()")
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
                            p{
                                text-align: center;
                                font-size: 20px;
                                color: #000000;
                            }
                            </style>
                            
                            </head>
    
    <body>
        
        <p>窗前明月光，恭喜恭喜！
        </p>
        
        <div class="button" onclick="btn()">
            JS调用原生的方法 showTips()
        </div>
        
        <script type="text/javascript">
            
            function btn(){
                WebViewJavascriptBridge.showTips("hello,maizhichao");
            }
        
        function jsAction(){
            alert("我是JS里的方法");
        }
        
            </script>
        
    </body>
    
</html>
```
>参考自：https://github.com/YanlongMa/SwiftJavaScriptCore
