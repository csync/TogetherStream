//
//  AddVideosViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class AddVideosViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        
    }
    
    
    
    func requestTrendingVideos() {
        guard let key = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key") else {
            return
        }
        let urlString = "https://www.googleapis.com/youtube/v3/videos?chart=mostPopular&part=snippet&maxResults=5&videoEmbeddable=true&videoSyndicated=true&key=" + key
        Utils.performGetRequest(targetURLString: urlString, completion: { data, responseCode, error in
            
            guard error == nil else {
                print("Error receiving videos: \(error!.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            //TODO: replace with model object creation
            //TODO: filter out restricted/premium videos from the popular video list
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        })
    }
    
    
    func searchForVideosWithString(videoString: String) {
        guard let key = Utils.getStringValueWithKeyFromPlist("keys", key: "youtube_api_key") else {
            return
        }
        
        //need to replace spaces with "+"
        let spaceFreeString = videoString.replacingOccurrences(of: " ", with: "+")
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=" + spaceFreeString + "&type=video&videoEmbeddable=true&videoSyndicated=true&key=" + key
        Utils.performGetRequest(targetURLString: urlString, completion: { data, responseCode, error in
            
            guard error == nil else {
                print("Error receiving videos: \(error!.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            //TODO: replace with model object creation
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        })
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trendingTapped(_ sender: Any) {
        requestTrendingVideos()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddVideosViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("Editing ended! Current text: \(searchBar.text)")
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Search cancelled!")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked!")
        guard let searchString = searchBar.text else {
            return
        }
        self.searchForVideosWithString(videoString: searchString)
        
    }
}
