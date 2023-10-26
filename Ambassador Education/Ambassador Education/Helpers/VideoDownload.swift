//
//  VideoDownload.swift
//  AVPlayerViewController-Subtitles
//
//  Created by Drishya on 28/02/18.
//  Copyright © 2018 Marc Hervera. All rights reserved.
//

import Foundation

protocol VideoDownloadDelegate {
    func loadingStarted()
    func loadingEnded()
    func filesDownloadComplete(filePath:String,fileToDelT:String)
}


class VideoDownload {
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    //  let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    var srtArray = [String]()
    var srtUrls:[NSURL?]!
    var delegate : VideoDownloadDelegate?
    var originalSubtitleURLStr = NSURL()
    var spaceRemovedURL = NSURL()
    
    // create a function to start the srt data download
    func getSrtDataFromUrl(srtUrl:NSURL, completion: @escaping ((_ data: NSData?) -> Void)) {
        print("download url = \(srtUrl)")
        URLSession.shared.dataTask(with:srtUrl as URL) { (data, response, error) in
            if data != nil {
                completion(data as NSData?)
            }
            }.resume()
    }
    
    // create  function to save the srt data
    func saveSrtData(srt:NSData, destination:NSURL,fileName:String) -> Bool {
        if srt.write(to: destination as URL, atomically: true) {
            print("The file \"\(destination.deletingPathExtension?.lastPathComponent ?? "default")\" was successfully saved.")
            checkAndStopDownload(fileUrl:destination,fileName: fileName)
            print(Date())
            return true
        }
        return false
    }
    
    // just convert your links to Urls
    func linksToUrls(){
        srtUrls = srtArray
            .map() { NSURL(string: $0) }
            .filter() { $0 != nil }
    }
    
    func createSpceremovedURL(urlStr : String) {
        let spaceRem = urlStr.replacingOccurrences(of: "%20", with:"")//) .trimmingCharacters(in: CharacterSet.whitespaces)
        spaceRemovedURL = NSURL(string:spaceRem)!
    }
    
    // create a loop to start downloading your urls
    func startDownloadingUrls(urlToDowload:[String],type: String,fileName:String){
        srtArray = urlToDowload
     //   delegate?.loadingStarted()
        linksToUrls()
        
        for url in srtUrls  {
            //documentsUrl
            originalSubtitleURLStr = url!
            let folderName = getFolderName(path:(url?.deletingPathExtension?.lastPathComponent)!)
            var urlLastComponenet = ""
            if(fileName=="")
            {
                urlLastComponenet = (url?.lastPathComponent)!.replacingOccurrences(of: "%20", with:"")
            }
            else
            {
               urlLastComponenet = fileName.replacingOccurrences(of: "%20", with:"")
            }
            let destinationUrl = createDirectory(folderName: folderName).appendingPathComponent(urlLastComponenet)
            print("Destination url = \(destinationUrl.path)")
           /* if FileManager().fileExists(atPath: destinationUrl.path) {
                print("The file \"\(destinationUrl.deletingPathExtension().lastPathComponent )\" already exists at path.")
                checkAndStopDownload(fileUrl:url!,fileName:urlLastComponenet)
            } else {*/
                print(Date())
                print("Started downloading \"\(originalSubtitleURLStr.deletingPathExtension?.lastPathComponent ?? "default")\".")
                getSrtDataFromUrl(srtUrl: originalSubtitleURLStr) { data in
                    DispatchQueue.main.async {
                        print("Finished downloading \"\(String(describing: self.originalSubtitleURLStr.deletingPathExtension?.lastPathComponent))\".")
                        print("Started saving \"\(String(describing: self.originalSubtitleURLStr.deletingPathExtension?.lastPathComponent))\".")
                        if self.saveSrtData(srt: data!, destination:destinationUrl as NSURL,fileName:  urlLastComponenet as String) {
                            //  self.checkAndStopDownload(fileUrl:self.spaceRemovedURL)
                            // do what ever if writeToURL was successful
                        } else {
                            print("The File \"\(self.originalSubtitleURLStr.deletingPathExtension?.lastPathComponent ?? "default")\" was not saved.")
                            self.checkAndStopDownload(fileUrl:self.spaceRemovedURL,fileName:urlLastComponenet)
                        }
                    }
                //}
            }
        }
    }
    
    func getFolderName(path:String) -> String {
        let seperateFromFolder = path.components(separatedBy: "_")
        if path.contains("COMMN"){
               return seperateFromFolder[3]
        }else{
        if seperateFromFolder.count > 2 {
            return seperateFromFolder[2]
        }
        }
        return ""
    }
    
    func createDirectory(folderName:String) -> URL{
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = urls[urls.count - 1] as URL
        //        let dbDirectoryURL = documentDirectoryURL.appendingPathComponent(folderName)
        //
        //        if FileManager.default.fileExists(atPath: dbDirectoryURL.path) == false{
        //            do{
        //                try FileManager.default.createDirectory(at: dbDirectoryURL, withIntermediateDirectories: false, attributes: nil)
        //            }catch{
        //            }
        //        }
        return documentDirectoryURL
    }
    
    func checkAndStopDownload(fileUrl:NSURL,fileName:String) {
        
        var folderName = getFolderName(path:(fileUrl.deletingPathExtension?.lastPathComponent)!)
        var urlLastComponenet = ""
        if(fileName=="")
        {
            urlLastComponenet = fileUrl.lastPathComponent ?? ""
        }
        else
        {
            urlLastComponenet = fileName
        }
        
        var str = ""
        if folderName.contains(" "){
         str = folderName.replacingOccurrences(of: " ", with: "%20")
        }
        else{
            str = folderName
        }
        
        let destinationUrl = createDirectory(folderName: str)
        
        //  let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: destinationUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            let fileNames = directoryContents.map{ $0.lastPathComponent }
            let names = fileNames.filter{$0.contains(urlLastComponenet)}
            if names.count > 0 {
                
                for each in names{
                    if each == urlLastComponenet{
               // delegate?.loadingEnded()
                //let name = names[0].replacingOccurrences(of: " ", with: "%20")
                        let name = names[0]//.removingPercentEncoding
                        delegate?.filesDownloadComplete(filePath: destinationUrl.absoluteString + name,fileToDelT:name)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //Depedency -- createfileArray
    func removeOldFileIfExist(fileName:String) {
      //  delegate?.loadingStarted()
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if paths.count > 0 {
            let dirPath = paths[0]
            // for fileToDelete in createfileArray(fileName: fileName){
            let filePath = NSString(format:"%@/%@", dirPath, fileName) as String
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                    print("old image has been removed")
                } catch {
                    print("an error during a removing")
                }
            }
            //  }
        }
     //   delegate?.loadingEnded()
    }
}

extension String {
    func fileName() -> String {
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    func fileExtension() -> String {
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
}

