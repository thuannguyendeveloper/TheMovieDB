//
//  RxReachability+Rx.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import Foundation
import RxSwift

extension Reactive where Base: NotificationCenter {
    public func notification(_ name: Notification.Name?, object: AnyObject? = nil) -> Observable<Notification> {
        return Observable.create { [weak object] observer in
            let nsObserver = self.base.addObserver(forName: name, object: object, queue: nil) { notification in
                observer.on(.next(notification))
            }
            
            return Disposables.create {
                self.base.removeObserver(nsObserver)
            }
        }
    }
}
extension Reachability: ReactiveCompatible { }
public extension Reactive where Base: Reachability {
    
    static var reachabilityChanged: Observable<Reachability> {
        return NotificationCenter.default.rx.notification(Notification.Name.reachabilityChanged)
            .flatMap { notification -> Observable<Reachability> in
                guard let reachability = notification.object as? Reachability else {
                    return .empty()
                }
                return .just(reachability)
        }
    }
    
    static var status: Observable<Reachability.Connection> {
        return reachabilityChanged
            .map { $0.connection }
    }
    
    static var isReachable: Observable<Bool> {
        return reachabilityChanged
            .map { $0.connection != .none }
    }
    
    static var isConnected: Observable<Void> {
        return isReachable
            .filter { $0 }
            .map { _ in Void() }
    }
    
    static var isDisconnected: Observable<Void> {
        return isReachable
            .filter { !$0 }
            .map { _ in Void() }
    }
}
