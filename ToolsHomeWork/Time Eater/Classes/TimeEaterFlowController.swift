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

    @IBOutlet private var table: UITableView!
    var files = [String]()
    var isNeedToReload: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initFilesWithValues()
    }
    
    private func initFilesWithValues() {
        DispatchQueue.global(qos: .background).async {
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
            table.reloadData()
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
        
        let file = files[indexPath.row]

        fetchImage(file: file, completion: { image in
            print(indexPath.row, "Onee")
            DispatchQueue.main.sync {
                cell.imageView?.image = image
            }
        })

        if let iv = cell.imageView {
            iv.contentMode = .scaleAspectFill
            iv.layer.shadowColor = UIColor.darkGray.cgColor
            iv.layer.shadowOpacity = 0.8
            iv.layer.shadowRadius = 12
        }
        
        return cell
    }
    
    private func fetchImage(file: String, completion: @escaping(UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if let imageURL = Bundle.main.url(forResource: file, withExtension: "") {
                if let img = self.resizedImage(at: imageURL, for: CGSize(width: 80, height: 80)) {
                    MemoryCache.shared.set(img, forKey: imageURL.absoluteString)
                    completion(img)
                }
            }
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
