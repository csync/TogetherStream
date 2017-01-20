//
//  AddVideosViewController.swift
//  Stormtrooper
//
//  Created by Nathan Hekman on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class AddVideosViewController: UIViewController {
	
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var queueCountLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
	
    var streamName: String?
    
    var isCreatingStream = false
	
    private let searchSpacerFrame = CGRect(x: 0, y: 0, width: 39, height: 5)
    private let searchClearFrame = CGRect(x: 0, y: 0, width: 31, height: 15)
	fileprivate let viewModel = AddVideosViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
        checkIfCreatingStream()
        
        viewModel.fetchTrendingVideos() {[weak self] error, videos in
            DispatchQueue.main.async {
                self?.searchTableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func checkIfCreatingStream() {
        guard let _ = self.navigationController else {
            //if inviting from stream, not in nav controller, so will dismiss when done is tapped rather than moving forward in stream creation process
            isCreatingStream = false
            return
        }
        //if navigation controller exists, user is creating stream, so push forward in flow
        isCreatingStream = true
    }
    
    private func setupSearchBar() {
        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIView(frame: searchSpacerFrame)
        searchTextField.rightViewMode = .never
        let clearButton = UIButton(frame: searchClearFrame)
        clearButton.setImage(#imageLiteral(resourceName: "xSearch"), for: .normal)
        clearButton.contentMode = .left
        searchTextField.rightView = clearButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldChanged), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        clearButton.addTarget(self, action: #selector(pressedSearchClear), for: .touchUpInside)
    }
    
    private func setupTableView() {
        searchTableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "resultCell")
        searchTableView.separatorColor = UIColor.stormtrooperSeperatorGray
    }
	
    @IBAction func doneTapped(_ sender: Any) {
        if isCreatingStream { //move to next screen in flow
            guard let inviteVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "InviteStream") as? InviteStreamViewController else {
                return
            }
            inviteVC.streamName = streamName
            inviteVC.navigationItem.title = "Invite to Stream"
            self.navigationController?.pushViewController(inviteVC, animated: true)
        }
        else { //dismiss
            self.dismiss(animated: true, completion: nil)
        }
    }
	
    @objc private func textFieldChanged(_ notification: Notification) {
        if searchTextField.text?.characters.count ?? 0 > 0 {
            searchTextField.rightViewMode = .whileEditing
        }
        else {
            searchTextField.rightViewMode = .never
        }
    }
    
    @objc private func pressedSearchClear() {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
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

extension AddVideosViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Editing ended! Current text: \(textField.text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count ?? 0 > 0 || string.characters.count > 0 {
            textField.rightViewMode = .whileEditing
        }
        else {
            textField.rightViewMode = .never
        }
        
        return true
    }
}

extension AddVideosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        let video = viewModel.videos[indexPath.row]
        cell.titleLabel.text = video.title
        cell.channelTitleLabel.text = video.channelTitle
        
        viewModel.getThumbnailForVideo(with: video.standardThumbnailURL) {error, thumbnail in
            if let thumbnail = thumbnail {
                DispatchQueue.main.async {
                    cell.thumbnailImageView.image = thumbnail
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
