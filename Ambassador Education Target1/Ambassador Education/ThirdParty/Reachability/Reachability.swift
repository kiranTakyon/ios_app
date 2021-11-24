//
//  Reachability.swift
//  Naisg
//
//  Created by Drishya on 06/10/16.
//  Copyright © 2016 //. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToInternet() -> Bool{
        if Reachability.isConnectedToNetworkiPv4() == true {
            return true
        }
        else{
            if Reachability.isConnectedToNetworkForIPV6() == true {
                return true
            }
            else{
                return false
            }
        }
    }
    
    class func isConnectedToNetworkiPv4() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return isReachable && !needsConnection
    }
    
    class func isConnectedToNetworkForIPV6() -> Bool{
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin6_family = sa_family_t(AF_INET6)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return isReachable && !needsConnection
    }

    
}
