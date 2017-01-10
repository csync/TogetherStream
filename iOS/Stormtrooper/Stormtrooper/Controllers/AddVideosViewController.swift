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
	
	var streamName: String?
	
	fileprivate let viewModel = AddVideosViewModel()
    
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
	
    @IBAction func doneTapped(_ sender: Any) {
		guard let inviteVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "Main") as? InviteStreamViewController else {
			return
		}
		inviteVC.streamName = streamName
		inviteVC.navigationItem.title = "Invite to Stream"
		self.navigationController?.pushViewController(inviteVC, animated: true)
    }
	
    @IBAction func trendingTapped(_ sender: Any) {
		viewModel.fetchTrendingVideos() {_, _ in }
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
		viewModel.searchForVideos(withQuery: searchString) {_, _ in }
			
    }
}
