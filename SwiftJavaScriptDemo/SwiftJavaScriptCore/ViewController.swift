
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

