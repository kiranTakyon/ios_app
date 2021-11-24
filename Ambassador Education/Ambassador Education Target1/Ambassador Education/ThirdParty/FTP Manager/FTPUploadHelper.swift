//
//  FTPUpload.swift
//  FTP Uploader
//
//  Created by Vozye SMC on 24/07/2018.
//  Copyright © 2018 Vozye SMC. All rights reserved.
//

import Foundation
import CFNetwork

public class FTPUploadHelper {
    fileprivate let ftpBaseUrl: String
    fileprivate let directoryPath: String
    fileprivate let username: String
    fileprivate let password: String
    var previousValue = ""
    
    public init(baseUrl: String, userName: String, password: String, directoryPath: String) {
        self.ftpBaseUrl = baseUrl
        self.username = userName
        self.password = password
        self.directoryPath = directoryPath
    }
}


// MARK: - Steam Setup
extension FTPUploadHelper {
    private func setFtpUserName(for ftpWriteStream: CFWriteStream, userName: CFString) {
        let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName)
        CFWriteStreamSetProperty(ftpWriteStream, propertyKey, userName)
    }
    
    private func setFtpPassword(for ftpWriteStream: CFWriteStream, password: CFString) {
        let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword)
        CFWriteStreamSetProperty(ftpWriteStream, propertyKey, password)
    }
    
    fileprivate func ftpWriteStream(forFileName fileName: String) -> CFWriteStream? {
        let fullyQualifiedPath = "ftp://\(ftpBaseUrl)/\(directoryPath)/\(fileName)"
        
        guard let ftpUrl = CFURLCreateWithString(kCFAllocatorDefault, fullyQualifiedPath as CFString, nil) else { return nil }
        let ftpStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, ftpUrl)
        let ftpWriteStream = ftpStream.takeRetainedValue()
        setFtpUserName(for: ftpWriteStream, userName: username as CFString)
        setFtpPassword(for: ftpWriteStream, password: password as CFString)
        return ftpWriteStream
    }
}


// MARK: - FTP Write
extension FTPUploadHelper {
    public func send(data: Data, with fileName: String, success: @escaping ((Bool)->Void)) {
            
          if fileName != previousValue{
        
        previousValue = fileName
        guard let ftpWriteStream = ftpWriteStream(forFileName: fileName) else {
            success(false)
            return
        }
        
        if CFWriteStreamOpen(ftpWriteStream) == false {
            print("Could not open stream")
            success(false)
            return
        }
        
        let fileSize = data.count
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: fileSize)
        data.copyBytes(to: buffer, count: fileSize)
        
        defer {
            CFWriteStreamClose(ftpWriteStream)
            buffer.deallocate(capacity: fileSize)
        }
        
        var offset: Int = 0
        var dataToSendSize: Int = fileSize
       // var isStreamOpen =  CFWriteStreamOpen(ftpWriteStream)
        var remaining = 0
        repeat {
            let bytesWritten = CFWriteStreamWrite(ftpWriteStream, &buffer[offset], dataToSendSize)
            if bytesWritten > 0 {
                offset += bytesWritten.littleEndian
                dataToSendSize -= bytesWritten
                remaining = bytesWritten
                success(true)
              break
                //continue
            } else if bytesWritten < 0 {
                print("FTPUpload - ERROR")
                success(false)
                break
            } else if bytesWritten == 0 {
                print("FTPUpload - Completed!!")
                success(true)
                break
            }
        } while remaining > 0
        
    }
}
}

