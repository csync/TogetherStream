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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchTableViewBottomConstraint: NSLayoutConstraint!
	
    var stream: Stream?
    var isCreatingStream = false
    var delegate: AddVideosDelegate?
	
    private let searchSpacerFrame = CGRect(x: 0, y: 0, width: 39, height: 5)
    private let searchClearFrame = CGRect(x: 0, y: 0, width: 54.5, height: 15)
	fileprivate let viewModel = AddVideosViewModel()
    
    fileprivate let searchTableHeaderViewHeight: CGFloat = 43
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
        setupNavigationBar()
        
        streamNameLabel.text = "\"\(stream?.name ?? "")\" Queue".localizedUppercase
        
        viewModel.fetchTrendingVideos() {[weak self] error, videos in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showVideoAlert(with: error)
                }
                self?.searchTableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCreatingStream {
            nextButton.setTitle("NEXT", for: .normal)
        }
        else {
            nextButton.setTitle("DONE", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showVideoAlert(with error: Error) {
        let alert = UIAlertController(title: "Error Loading Videos", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    
    private func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "youTube"))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
	
    @IBAction func doneTapped(_ sender: Any) {
        if isCreatingStream { //move to next screen in flow
            delegate?.didAddVideos(selectedVideos: viewModel.selectedVideos)
            guard let inviteVC = Utils.vcWithNameFromStoryboardWithName("inviteStream", storyboardName: "InviteStream") as? InviteStreamViewController else {
                return
            }
            inviteVC.stream = stream
            inviteVC.videoQueue = viewModel.selectedVideos
            inviteVC.navigationItem.title = "Invite to Stream"
            inviteVC.isCreatingStream = true
            self.navigationController?.pushViewController(inviteVC, animated: true)

        }
        else { //dismiss
            delegate?.didAddVideos(selectedVideos: viewModel.selectedVideos)
            let _ = self.navigationController?.popViewController(animated: true)
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
        viewModel.fetchTrendingVideos() {[weak self] error, videos in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showVideoAlert(with: error)
                }
                self?.searchTableView.reloadData()
            }
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text ?? ""
        if query.characters.count > 0 {
            viewModel.searchForVideos(withQuery: query) {[weak self] error, videos in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showVideoAlert(with: error)
                    }
                    self?.searchTableView.reloadData()
                    self?.searchTableView.setContentOffset(CGPoint.zero, animated: true)
                }
            }
        }
        else {
            viewModel.fetchTrendingVideos {[weak self] error, videos in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showVideoAlert(with: error)
                    }
                    self?.searchTableView.reloadData()
                }
            }
        }
        textField.resignFirstResponder()
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
        
        if viewModel.videoIsSelected(at: indexPath) {
            cell.addImageView.image = #imageLiteral(resourceName: "addedVideos")
        }
        else {
            cell.addImageView.image = #imageLiteral(resourceName: "addVideos")
        }
        
        viewModel.getThumbnailForVideo(with: video.mediumThumbnailURL) {error, thumbnail in
            if let thumbnail = thumbnail {
                DispatchQueue.main.async {
                    cell.thumbnailImageView.image = thumbnail
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleSelectionOfVideo(at: indexPath)
        queueCountLabel.text = String(viewModel.selectedVideos.count)
        if let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell {
            if viewModel.videoIsSelected(at: indexPath) {
                cell.addImageView.image = #imageLiteral(resourceName: "addedVideos")
            }
            else {
                cell.addImageView.image = #imageLiteral(resourceName: "addVideos")
            }
        }
        // show next button if at least one video is selected
        if viewModel.selectedVideos.count == 0 {
            nextButton.isHidden = true
            searchTableViewBottomConstraint.constant = 0
        }
        else {
            nextButton.isHidden = false
            searchTableViewBottomConstraint.constant = nextButton.frame.height * -1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SearchResultHeaderView.instanceFromNib()
        if searchTextField.text?.characters.count ?? 0 > 0 {
            headerView.titleLabel.text = "VIDEOS"
        }
        else {
            headerView.titleLabel.text = "TRENDING NOW"
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchTableHeaderViewHeight
    }
}

protocol AddVideosDelegate {
    func didAddVideos(selectedVideos: [Video])
}
