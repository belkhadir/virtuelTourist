//
//  DisplayPhotoViewController.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 23/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import UIKit
import MapKit
import CoreData





class DisplayPhotoViewController: UIViewController, UICollectionViewDataSource,
     UICollectionViewDelegate, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var annotation: MKPointAnnotation!
    var pin: Pin!
    
    //Sotre the index of image that the user select
    private var selectedIndexes = [NSIndexPath]()
    
    private var insertedIndexPaths : [NSIndexPath]!
    private var deletedIndexPaths   : [NSIndexPath]!
    private var updatedIndexPaths : [NSIndexPath]!
    
    var width: CGFloat!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        //Setting the map
        let span = MKCoordinateSpanMake(1, 1)
        let location = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let mkCoordinateSpan = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(mkCoordinateSpan, animated: true)
        mapView.addAnnotation(annotation)
        
        //The function Download Image from flickr if the pin is empty
        
        
        do {
            try fetchedResultController.performFetch()
        }catch _{}
        fetchedResultController.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        storeImageFromFlickr()
        
    }
    
    
    lazy var fetchedResultController: NSFetchedResultsController = {
       let fetchedRequest = NSFetchRequest(entityName: "Photo")
       
        fetchedRequest.sortDescriptors = []
       let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
        
    }()
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    func saveContext(){
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    func storeImageFromFlickr(){
        
        if pin.pictures.isEmpty {

            VTClient.sharedVTClient().searchingImageByLONLAT(annotation.coordinate.latitude , Longtitude: annotation.coordinate.longitude ){
                (data, success) in
                if success {
                    if let data = data  {
                    
                        let _ = data.map(){ (dictionary: [String: AnyObject]) -> Photo in
                            let imagePath = VTClient.sharedVTClient().creatImageIdentifier(dictionary)
                            let url = dictionary[VTClient.JsonKeys.URL_M] as! String
                            let photo = Photo(imagePath: imagePath,url: url,context: self.sharedContext)
                            photo.pin = self.pin
                            self.saveContext()
                            return photo
                        }
                        }
                    print("Done")
                    }
                }
            }
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = self.fetchedResultController.objectAtIndexPath(indexPath) as! Photo
        
        let resuseCell = "cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(resuseCell, forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        }else{
            selectedIndexes.append(indexPath)
        }
        
        configureCellAtIndex(cell, ItemAtindexPath: indexPath)
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSizeMake(width , width ))
        image.drawInRect(CGRectMake(0, 0, width, width ))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func configureCellAtIndex(cell: CollectionViewCell, ItemAtindexPath indexPath: NSIndexPath){
        
        if let _ = selectedIndexes.indexOf(indexPath){
            cell.alpha = 0.5
        }else{
            cell.alpha = 1.0
        }
        
    }
    
    
    func configureCell(cell: CollectionViewCell, photo:Photo){
        
        if photo.imagePath == nil || photo.imagePath == ""{
            cell.image.image = nil
            print("Faild to get Path")
        }else if photo.image != nil {
            print("Image is sotored")
            cell.image.image = photo.image
        }else{
            print("Will Start Downloading Image")
            cell.activutyIndicator.startAnimating()
            let _ = VTClient.sharedVTClient().getSingleImageFromFlickr(WithURL: photo.url!){ (data, success) in
                if success {
                    
                        let image = UIImage(data: data!)
                        let resizedImage = self.resizeImage(image!)
                        photo.image = resizedImage
                    
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.activutyIndicator.startAnimating()
                            cell.activutyIndicator.hidden = true
                            cell.image.image = resizedImage
                            print("success to download image")
                    }
                }else{
                    print("Faild to DownLoad image")
                    cell.image.image = nil
                }
                
            }
            
        }
        
        
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
            case .Insert:
                insertedIndexPaths.append(newIndexPath!)
                break
            case .Delete:
                deletedIndexPaths.append(indexPath!)
                break
            case .Update:
                updatedIndexPaths.append(indexPath!)
                break
            case .Move:
                break
        }

    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({ ()-> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    
    
    
    @IBAction func deleteSelectedPhotos(sender: UIBarButtonItem) {
        
        var photoToDelete = [Photo]()
        
        for index in selectedIndexes {
            photoToDelete.append(fetchedResultController.objectAtIndexPath(index) as! Photo)
        }
        
        for photo in photoToDelete {
            //TODO: remove from the directory is nessary
            sharedContext.deleteObject(photo)
        }
        selectedIndexes = [NSIndexPath]()
    }
    
    
    @IBAction func goToTheMainView(sender: UIBarButtonItem) {
        let VTCV = storyboard!.instantiateViewControllerWithIdentifier("virtuelTourist") as! VirtuelTrouristViewController
        presentViewController(VTCV, animated: true, completion: nil)
    }
    func deleteAllPhoto(){
        
        for index in selectedIndexes {
            //TODO: remove also from directory
            sharedContext.deleteObject(fetchedResultController.objectAtIndexPath(index) as! Photo)
        }
    }
    
    func updateBarButtonItem(){
        //changing the name
    }
    
    @IBAction func newCollection(sender: AnyObject) {
        //Delete the old image and recall to storeImageFromFlickr
        
        //deleteAllPhoto()
        //storeImageFromFlickr()
        
        
    }

}















