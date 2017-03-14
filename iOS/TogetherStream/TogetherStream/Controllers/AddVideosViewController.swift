//
//  © Copyright IBM Corporation 2017
//  LICENSE: MIT http://ibm.biz/license-ios
//

import UIKit

/// View controller for the "Add Videos" screen.
class AddVideosViewController: UIViewController {
    
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var queueCountLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchTableViewBottomConstraint: NSLayoutConstraint!
    
    /// The stream to add videos to.
    var stream: Stream?
    /// Change view based on whether a stream is currently being created.
    var isCreatingStream = false
    /// Delegate to send updates to.
    var delegate: AddVideosDelegate?
    
    /// The number of videos that has been previously added.
    var numberOfPreviouslyAddedVideos: Int {
        get {
            return viewModel.numberOfPreviouslyAddedVideos
        }
        set {
            viewModel.numberOfPreviouslyAddedVideos = newValue
        }
    }
    
    /// The size of the space in front of the search bar.
    private let searchSpacerFrame = CGRect(x: 0, y: 0, width: 39, height: 5)
    /// The size of the clear button for the search bar.
    private let searchClearFrame = CGRect(x: 0, y: 0, width: 54.5, height: 15)
    /// The height of the header in the search table.
    fileprivate let searchTableHeaderViewHeight: CGFloat = 43
    
    /// The model for the objects in this view.
    fileprivate let viewModel = AddVideosViewModel()
    
    /// Loading indicator for fetching videos.
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        
        setupSearchBar()
        setupTableView()
        setupNavigationItems()
        setupActivityIndicator()
        setupQueueHeader()
        
        fetchTrendingVideos()

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
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            Utils.sendGoogleAnalyticsEvent(withCategory: "AddVideos", action: "SelectedBackButton")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Shows the given error to indicate an error with loading videos.
    ///
    /// - Parameter error: The error message to show.
    fileprivate func showVideoAlert(with error: Error) {
        guard navigationController?.visibleViewController == self else {
            return
        }
        let alert = UIAlertController(title: "Error Loading Videos", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /// Fetches the current trending videos and updates the view, displaying an error if necessary.
    fileprivate func fetchTrendingVideos() {
        // Clear table
        viewModel.listedVideos = []
        searchTableView.reloadData()
        // Display loading indicator
        activityIndicator.startAnimating()
        viewModel.fetchTrendingVideos() {[weak self] error, videos in
            DispatchQueue.main.async {
                // Hide loading indicator
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.showVideoAlert(with: error)
                }
                self?.searchTableView.reloadData()
            }
        }
    }
    
    /// Sets up the search bar.
    private func setupSearchBar() {
        // Adds space for the magnify glass
        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIView(frame: searchSpacerFrame)
        searchTextField.rightViewMode = .never
        
        // Adds and configures clear button
        let clearButton = UIButton(frame: searchClearFrame)
        clearButton.setImage(#imageLiteral(resourceName: "xSearch"), for: .normal)
        clearButton.contentMode = .left
        searchTextField.rightView = clearButton
        clearButton.addTarget(self, action: #selector(pressedSearchClear), for: .touchUpInside)
        
        // Add observer for search textfield changing
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldChanged), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    /// Sets up the table view.
    private func setupTableView() {
        searchTableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "resultCell")
        searchTableView.separatorColor = UIColor.togetherStreamSeperatorGray
    }
    
    /// Set the navigation items for this view controller.
    private func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "youTube"))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Sets up the top area of the screen.
    private func setupQueueHeader() {
        streamNameLabel.text = "\"\(stream?.name ?? "")\" Queue".localizedUppercase
        queueCountLabel.text = viewModel.queueCount
    }
    
    /// Sets up the activity indicator.
    private func setupActivityIndicator() {
        activityIndicator.frame = view.frame
        view.addSubview(activityIndicator)
    }
    
    /// When the done button is tapped, sends added videos to the appropriate receivers
    /// and moves to the next screen.
    ///
    /// - Parameter sender: The button that sent the "done" signal.
    @IBAction func doneTapped(_ sender: Any) {
        Utils.sendGoogleAnalyticsEvent(withCategory: "AddVideos", action: "AddedVideos", value: viewModel.selectedVideos.count as NSNumber?)
        if isCreatingStream {
            // Move to next screen in flow
            delegate?.didAddVideos(selectedVideos: viewModel.selectedVideos)
            guard let inviteVC = Utils.instantiateViewController(withIdentifier: "inviteStream", fromStoryboardNamed: "InviteStream") as? InviteStreamViewController else {
                return
            }
            inviteVC.stream = stream
            inviteVC.videoQueue = viewModel.selectedVideos
            inviteVC.navigationItem.title = "Invite to Stream"
            inviteVC.isCreatingStream = true
            self.navigationController?.pushViewController(inviteVC, animated: true)

        }
        else {
            // Dismiss
            delegate?.didAddVideos(selectedVideos: viewModel.selectedVideos)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// When a text field changes, updates the right view of the search text field
    /// based on the number of characters in the field.
    ///
    /// - Parameter notification: The notification sent.
    @objc private func textFieldChanged(_ notification: Notification) {
        if searchTextField.text?.characters.count ?? 0 > 0 {
            searchTextField.rightViewMode = .whileEditing
        }
        else {
            searchTextField.rightViewMode = .never
        }
    }
    
    /// Clears the serch results and fetches the trending videos.
    @objc private func pressedSearchClear() {
        Utils.sendGoogleAnalyticsEvent(withCategory: "AddVideos", action: "PressedSearchClear")
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        fetchTrendingVideos()
    }
}

extension AddVideosViewController: UITextFieldDelegate {
    /// When a text field returns, search for the text of the field or
    /// fetch the trending videos if empty. Afterwards, update the view.
    ///
    /// - Parameter textField: The text field that returned.
    /// - Returns: Whether to perform the return, is always true.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text ?? ""
        if query.characters.count > 0 {
            Utils.sendGoogleAnalyticsEvent(withCategory: "AddVideos", action: "PerformedSearch")
            // Clear table
            viewModel.listedVideos = []
            searchTableView.reloadData()
            // Display loading indicator
            activityIndicator.startAnimating()
            viewModel.searchForVideos(withQuery: query) {[weak self] error, videos in
                DispatchQueue.main.async {
                    // Hide loading indiciator
                    self?.activityIndicator.stopAnimating()
                    if let error = error {
                        self?.showVideoAlert(with: error)
                    }
                    self?.searchTableView.reloadData()
                    self?.searchTableView.setContentOffset(CGPoint.zero, animated: true)
                }
            }
        }
        else {
            fetchTrendingVideos()
        }
        textField.resignFirstResponder()
        return true
    }
}

extension AddVideosViewController: UITableViewDataSource, UITableViewDelegate {
    /// Returns the number of rows for the section.
    ///
    /// - Parameters:
    ///   - tableView: The tableview requesting the number.
    ///   - section: The section the request is for.
    /// - Returns: The number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listedVideos.count
    }
    
    /// Dequeues and configures the cell for the given path.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the cell.
    ///   - indexPath: The path of the cell.
    /// - Returns: The cell to display.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        let video = viewModel.listedVideos[indexPath.row]
        
        if viewModel.videoIsSelected(at: indexPath) {
            cell.addImageView.image = #imageLiteral(resourceName: "addedVideos")
        }
        else {
            cell.addImageView.image = #imageLiteral(resourceName: "addVideos")
        }
        
        // Only set view if video has changed
        if cell.videoID != video.id {
            cell.videoID = video.id
            cell.thumbnailImageView.image = nil
            cell.titleLabel.text = video.title
            cell.channelTitleLabel.text = video.channelTitle
            
            video.getMediumThumbnail {error, thumbnail in
                if let thumbnail = thumbnail {
                    DispatchQueue.main.async {
                        cell.thumbnailImageView.image = thumbnail
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row the request is for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// Sets the height to be automatic based on constraints.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the height.
    ///   - indexPath: The index path of the row being requested for.
    /// - Returns: The height of the cell.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /// Toggles the selection of the selected video. Changes display of
    /// "next" button if needed.
    ///
    /// - Parameters:
    ///   - tableView: The table that was selected.
    ///   - indexPath: The path of the cell that was selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleSelectionOfVideo(at: indexPath)
        // Updates selected video count view
        queueCountLabel.text = viewModel.queueCount
        // Updates selected image
        if let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell {
            if viewModel.videoIsSelected(at: indexPath) {
                cell.addImageView.image = #imageLiteral(resourceName: "addedVideos")
            }
            else {
                cell.addImageView.image = #imageLiteral(resourceName: "addVideos")
            }
        }
        // Show next button if at least one video is selected
        if viewModel.selectedVideos.count == 0 {
            nextButton.isHidden = true
            searchTableViewBottomConstraint.constant = 0
        }
        else {
            nextButton.isHidden = false
            searchTableViewBottomConstraint.constant = nextButton.frame.height * -1
        }
        
        // Hide keyboard if present
        view.endEditing(true)
    }
    
    /// Instantiates and configures the table header.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the header.
    ///   - section: The section the header is for.
    /// - Returns: The header view.
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
    
    /// Sets the height of the header.
    ///
    /// - Parameters:
    ///   - tableView: The table requesting the header height.
    ///   - section: The section the request is for.
    /// - Returns: The height of the header.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchTableHeaderViewHeight
    }
    
    /// When the table view scrolls, hide the keyboard if present
    ///
    /// - Parameter scrollView: The scroll view that scrolled.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

/// Delegate to receive notifications when videos are added.
protocol AddVideosDelegate {
    /// Notification triggered when videos are added.
    ///
    /// - Parameter selectedVideos: The videos added.
    func didAddVideos(selectedVideos: [Video])
}
