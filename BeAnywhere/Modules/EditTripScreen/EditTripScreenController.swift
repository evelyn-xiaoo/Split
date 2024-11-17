//
//  EditTripScreenController.swift
//  BeAnywhere
//
//  Created by Jimin Kim on 11/3/24.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

class EditTripScreenController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let editTripView = EditTripScreenView()
    var groupMembers: [FirestoreUser] = []
    var currentTrip: FoodTrip? = nil
    let searchSheetController = UserSearchBottmSheetController()
    let childProgressView = ProgressSpinnerViewController()
        var searchSheetNavController: UINavigationController!
    let notificationCenter = NotificationCenter.default
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    var pickedTripImage: UIImage?
    
    override func loadView() {
        view = editTripView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentTrip {
            groupMembers.replaceSubrange(0..<currentTrip.members.count, with: currentTrip.members)
            
            editTripView.textFieldName.text = currentTrip.groupName
            editTripView.textFieldLocation.text = currentTrip.location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Group"
       
        //MARK: setting the delegate and data source...
        editTripView.memberTable.dataSource = self
        editTripView.memberTable.delegate = self
        //MARK: removing the separator line...
        editTripView.memberTable.separatorStyle = .none
        
        let confirmButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirmNewGroup))
        
        navigationItem.rightBarButtonItems = [confirmButton]
        editTripView.tripImage.menu = getMenuImagePicker()
        
        editTripView.addMemberButton.addTarget(self, action: #selector(onFindButtonTapped), for: .touchUpInside)
        
        // MARK: setup notification observer
        notificationCenter.addObserver(
                    self,
                    selector: #selector(notificationReceivedForMemberAdded(notification:)),
                    name: Notification.Name(NotificationConfigs.UserSelectedObserverName),
                    object: nil)
    }
    
    // MARK: adds the selected group member in the form and closes the sheet
    @objc func notificationReceivedForMemberAdded(notification: Notification){
        groupMembers.append(notification.object as! FirestoreUser)
        editTripView.memberTable.reloadData()
        dismiss(animated: true)
        }
    
    @objc func confirmNewGroup(){
        let newFoodTripName: String? = editTripView.textFieldName.text
        let newFoodTripLocation: String? = editTripView.textFieldLocation.text
        
        if let newFoodTripLocation, let newFoodTripName{
            do {
                let newTrip: FoodTrip = FoodTrip(id: "", groupName: newFoodTripName, location: newFoodTripLocation, members: groupMembers, photoURL: "", dateCreated: Date.now, dateEnded: nil, isTerminated: false)
                
                try saveFoodTrip(newTrip)
            } catch {
                showErrorAlert(message: "Failed to create new trip. Please try again.", controller: self)
            }
            
        }
    }
    
    func setupSearchBottomSheet(){
            //MARK: setting up bottom search sheet...
            searchSheetNavController = UINavigationController(rootViewController: searchSheetController)
            
            // MARK: setting up modal style...
            searchSheetNavController.modalPresentationStyle = .pageSheet
            
            if let bottomSearchSheet = searchSheetNavController.sheetPresentationController{
                bottomSearchSheet.detents = [.medium(), .large()]
                bottomSearchSheet.prefersGrabberVisible = true
            }
    }
    @objc func onFindButtonTapped(){
        setupSearchBottomSheet()
        present(searchSheetNavController, animated: true)
    }
    
    func getMenuImagePicker() -> UIMenu {
        let menuItems = [
                    UIAction(title: "Camera",handler: {(_) in
                        self.pickUsingCamera()
                    }),
                    UIAction(title: "Gallery",handler: {(_) in
                        self.pickPhotoFromGallery()
                    })
                ]
                
        return UIMenu(title: "Select source", children: menuItems)
    }
    
    func pickUsingCamera() {
        requestCameraAccess { [weak self] isAuthorized in
            guard let self = self else { return }
            
            if isAuthorized {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
            } else {
                showErrorAlert(message: "Camera access is required to capture a profile picture.", controller: self)
            }
        }
    }


    
    func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true) // Already authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false) // Access denied or restricted
        }
    }

    
    func pickPhotoFromGallery() {
        requestPhotoLibraryAccess { isAuthorized in
            if isAuthorized {
                var configuration = PHPickerConfiguration()
                configuration.filter = .images
                configuration.selectionLimit = 1
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true)
            } else {
                showErrorAlert(message: "Photo library access is required to select a profile picture.", controller: self)
            }
        }
    }

    
    func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            completion(true) // Already authorized
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }
        default:
            completion(false) // Access denied or restricted
        }
    }
}

extension EditTripScreenController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableConfigs.tableViewTripEditUsers, for: indexPath) as! UserBoxTableViewCell
        cell.userNameLabel.text = groupMembers[indexPath.row].name
        
        if let avatarImageUrl = URL(string: groupMembers[indexPath.row].avatarURL) {
            cell.avatarImage.loadRemoteImage(from: avatarImageUrl)
        }
        
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: on current trip box click -> navigate to trip details page
    }
}

extension EditTripScreenController: UIPickerViewDelegate, UIPickerViewDataSource, PHPickerViewControllerDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        print(results)
        
        let itemprovider = results.map(\.itemProvider)
        
        for item in itemprovider{
            if item.canLoadObject(ofClass: UIImage.self){
                item.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                    DispatchQueue.main.async{
                        if let uwImage = image as? UIImage{
                            self.editTripView.tripImage.setImage(
                                uwImage.withRenderingMode(.alwaysOriginal),
                                for: .normal
                            )
                            self.pickedTripImage = uwImage
                        }
                    }
                })
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage{
            self.editTripView.tripImage.setImage(
                image.withRenderingMode(.alwaysOriginal),
                for: .normal
            )
            self.pickedTripImage = image
        }else{
            showAlertText(text: "Failed to take photo", controller: self)
        }
    }
}

extension EditTripScreenController:ProgressSpinnerDelegate{
    func showActivityIndicator(){
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        childProgressView.willMove(toParent: nil)
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}