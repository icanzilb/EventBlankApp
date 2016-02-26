//
//  RxRealm.swift
//  RxRealm
//
//  Created by Carlos García on 03/12/15.
//  Copyright © 2015 Carlos García. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

// MARK: - Realm extension that adds a reactive interface to Realm
public extension Realm {
    
    /**
     Enum that represents a Realm within a thread (used for operations)
     
     - MainThread:             Operations executed in the Main Thread Realm. Completion called in Main Thread
     - BackgroundThread        Operations executed in a New Background Thread Realm. Completion called in the Main Thread
     - SameThread:             Operations executed in the given Background Thread Realm. Completion called in the same Thread
     */
    enum RealmThread {
        case MainThread
        case BackgroundThread
        case SameThread(Realm)
    }
    
    enum RealmError: ErrorType {
        case WrongThread
        case InvalidRealm
        case InvalidReadThread
    }
    
    // MARK: - Helpers
    
    /// Realm save closure
    typealias OperationClosure = (realm: Realm) -> ()
    
  /**
  Executes the given operation passing the read to the operation block. Once it's completed, the completion closure is called passing error in case something went wrong.

  - parameter thread:         Realm thread to operate on
  - parameter writeOperation: Boolean that will commit a write
  - parameter completion:     Completion closure that can contain an error
  - parameter operation:      Operation closure to save in a given realm
  */
    private static func realmOperationInThread(thread: RealmThread, writeOperation: Bool, completion: RealmError? -> Void, operation: OperationClosure) {
        switch thread {
        case .MainThread:
            if !NSThread.isMainThread() {
                completion(.WrongThread)
            }
            do {
                let realm = try Realm()
                if writeOperation { realm.beginWrite() }
                operation(realm: realm)
                if writeOperation { try! realm.commitWrite() }
                completion(nil)
            }
            catch {
                completion(.InvalidRealm)
            }
        case .BackgroundThread:
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                do {
                    let realm = try Realm()
                    if writeOperation { realm.beginWrite() }
                    operation(realm: realm)
                    if writeOperation { try! realm.commitWrite() }
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil)
                    }
                }
                catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(.InvalidRealm)
                    }
                }
            }
        case .SameThread(let realm):
            if writeOperation { realm.beginWrite() }
            operation(realm: realm)
            if writeOperation { try! realm.commitWrite() }
            completion(nil)
        }
    }
    
  /**
  Generates the Observable that executes the given write operation

  - parameter thread:         Realm thread to perform write on
  - parameter writeOperation: Boolean that determines wether the action is written
  - parameter operation:      Operation closure to save in a realm

  - returns: An Observable of Void type
  */
    private static func realmWriteOperationObservable(thread thread: RealmThread, writeOperation: Bool, operation: OperationClosure) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            Realm.realmOperationInThread(thread, writeOperation: writeOperation, completion: { error in
                if let error = error {
                    observer.onError(error)
                }
                observer.onCompleted()
                }, operation: operation)
            return NopDisposable.instance
        }
    }
    
    
    // MARK: - Creation
    
  /**
  Add objects to a Realm

  - parameter objects: Objects to be added
  - parameter update:  Boolean that determines whether an object should be forced updated
  - parameter thread:  Thread to execute Realm actions

  - returns: Observable that completes operation
  */
    static func rx_add<S: SequenceType where S.Generator.Element: Object>(objects: S, update: Bool = false, thread: RealmThread = .BackgroundThread) -> Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true) { realm in
            realm.add(objects, update: update)
        }
    }

    /**
     Creates an object in Realm
     
     - parameter type:   Object type
     - parameter value:  Value to create object on
     - parameter update: Force update?
     - parameter thread: Thread to execute Realm actions
     
     - returns: Observable that fires the operation
     */
    static func rx_create<T: Object>(type: T.Type, value: AnyObject = [:], update: Bool = false, thread: RealmThread = .BackgroundThread) -> Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true) { realm in
            realm.create(type, value: value, update: update)
        }
    }
    
    
    // MARK: - Deletion
    
  /**
  Deletes an Object from Realm

  - parameter object: Object to be deleted
  - parameter thread: Thread to execute Realm actions

  - returns: Observable that fires the operation
  */
    static func rx_delete(object: Object, thread: RealmThread) -> Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true) { realm in
            realm.delete(object)
        }
    }
    
   /**
   Deletes Objects from a realm

   - parameter objects: Objects to be deleted
   - parameter thread:  Thread to execute Realm actions

   - returns: Observable that fires the operation
   */
    static func rx_delete<S: SequenceType where S.Generator.Element: Object>(objects: S, thread: RealmThread) -> Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true) { realm in
            realm.delete(objects)
        }
    }

   /**
   Deletes Objects from a Realm

   - parameter objects: List of Objects to delete
   - parameter thread:  Thread to execute Realm actions

   - returns: Observable that fires the operation
   */
    static func rx_delete<T: Object>(objects: List<T>, thread: RealmThread) -> Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true)  { realm in
            realm.delete(objects)
        }
    }
    
   /**
   Deletes Objects from a Realm

   - parameter objects: List of Objects to delete
   - parameter thread:  Thread to execute Realm actions

   - returns: Observable that fires the operation
   */
    static func rx_delete<T: Object>(objects: Results<T>, thread: RealmThread) ->  Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true) { realm in
            realm.delete(objects)
        }
    }

   /**
   Deletes all objects from Realm

   - parameter thread: Thread to execute Realm actions

   - returns: Observable that fires the operation
   */
    static func rx_deleteAll(thread: RealmThread) -> Observable<Void> {
        return realmWriteOperationObservable(thread: thread, writeOperation: true) { realm in
            realm.deleteAll()
        }
    }
    
    
    // MARK: - Querying
    
  /**
  Returns objects of the given type

  **Note: This observable has to be subscribed on the Main Thread**

  - parameter type: Object type

  - returns: Observable containing Results for the Type
  */
    static func rx_objects<T: Object>(type: T.Type) -> Observable<RealmSwift.Results<T>> {
        return Observable.create { observer in
            if !NSThread.isMainThread() {
                observer.onError(RealmError.InvalidReadThread)
            }
            else {
                do {
                    let realm = try Realm()
                    observer.onNext(realm.objects(type))
                    observer.onCompleted()
                }
                catch  {
                    observer.onError(RealmError.InvalidRealm)
                }
            }
            return NopDisposable.instance
        }
    }
    
   /**
   Returns an Object with a given primary key

   - parameter type: Object type
   - parameter key:  Primary key

   - returns: Observable containing the object associated with `key`
   */
    static func rx_objectForPrimaryKey<T: Object>(type: T.Type, key: AnyObject) -> Observable<T?> {
        return Observable.create { observer in
            if !NSThread.isMainThread() {
                observer.onError(RealmError.InvalidReadThread)
            }
            else {
                do {
                    let realm = try Realm()
                    observer.onNext(realm.objectForPrimaryKey(type, key: key))
                    observer.onCompleted()
                }
                catch  {
                    observer.onError(RealmError.InvalidRealm)
                }
            }
            return NopDisposable.instance
        }
    }
}


// MARK: - Reactive Operators

/**
Filter Realm `Object` of a given type with a given predicate

- parameter predicate: Predicate to filter objects

- returns: Observable containing filtered results for `Object`
*/
public func filter<T: Object>(predicate: NSPredicate) -> Observable<Results<T>> -> Observable<Results<T>> {
    return { (observable: Observable<Results<T>>) -> Observable<Results<T>> in
        return observable
            .map { $0.filter(predicate) }
    }
}

 /**
 Filter Realm `Object` of a given type with a given predicate

 - parameter predicateString: Predicate to filter objects

 - returns: Observable containing filtered results for `Object`
 */
public func filter<T>(predicateString: String) -> Observable<Results<T>> -> Observable<Results<T>> {
    return { (observable: Observable<Results<T>>) -> Observable<Results<T>> in
        return observable
            .map { $0.filter(predicateString) }
    }
}

 /**
 Sorts `Results` for a given objects using by using a key in ascending/descending order

 - parameter key:       Key the results should be sorted by
 - parameter ascending: true iff the results sort order is ascending

 - returns: Observable of a sorted `Results` set
 */
public func sorted<T>(key: String, ascending: Bool = true) -> Observable<Results<T>> -> Observable<Results<T>> {
    return { (observable: Observable<Results<T>>) -> Observable<Results<T>> in
        return observable
            .map { $0.sorted(key, ascending: ascending) }
    }
}

