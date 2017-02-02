//
//  WebViewController.swift
//  Stormtrooper
//
//  Created by Glenn R. Fisher on 2/1/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    @IBOutlet private weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: URL(string: "https://www.ibm.com/us-en/")!))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
