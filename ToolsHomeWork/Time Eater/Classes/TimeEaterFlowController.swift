//
//  TimeEaterFlowController.swift
//  MealTime
//
//  Created by Igor Kupreev on 9/16/18.
//  Copyright © 2018 Igor Kupreev. All rights reserved.
//

import UIKit
import ImageIO

class TimeEaterFlowController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    private var files = [String]()
    private var isNeedToReload: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initFilesWithValues()
    }
    
    private func initFilesWithValues() {
        DispatchQueue.global(qos: .background).sync {
            let fm = FileManager.default
            if let path = Bundle.main.resourcePath,
               let items = try? fm.contentsOfDirectory(atPath: path){
                for item in items where item.hasPrefix("img"){
                    self.files.append(item)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isNeedToReload ?? false {
            isNeedToReload = nil
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapCloseButton(sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension TimeEaterFlowController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ImageCell")
        cell.imageView?.image = fetchImageFromCache(index: indexPath.row)
        
        if let image = fetchImageFromCache(index: indexPath.row) {
            cell.imageView?.image = image
        } else {
            fetchImage(index: indexPath.row) { image in
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        if let iv = cell.imageView {
            iv.contentMode = .scaleAspectFill
            iv.layer.shadowColor = UIColor.darkGray.cgColor
            iv.layer.shadowOpacity = 0.8
            iv.layer.shadowRadius = 12
        }
        
        return cell
    }
    
    private func fetchImageFromCache(index: Int) -> UIImage? {
        let file = files[index]
        if let imageURL = Bundle.main.url(forResource: file, withExtension: "") {
            print("Cached at: ", file)
            return MemoryCache.shared.image(forKey: imageURL.absoluteString)
        }
        return nil
    }
    
    private func fetchImage(index: Int, completion: @escaping (UIImage?) -> Void) {
        let file = files[index]
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
                if let imageURL = Bundle.main.url(forResource: file, withExtension: "") {
                    if let img = self.resizedImage(at: imageURL, for: CGSize(width: 200, height: 80)) {
                        print("fetched at: ", file)
                        MemoryCache.shared.set(img, forKey: imageURL.absoluteString)
                        completion(img)
                    }
                
            }
            completion(nil)
        }
    }
    
    private func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ]
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }
        return UIImage(cgImage: image)
    }
}

extension TimeEaterFlowController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = TimeEaterChildViewController()
        
        details.file = files[indexPath.row]
        details.owner = self
        
        navigationController?.pushViewController(details, animated: true)
    }
}
