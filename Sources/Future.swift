/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

 /* A simple implementation of Futures and Promises, largely influenced by Scala Futures */

import Foundation
import NSLinux
import Glibc

/* POSIX semaphores used for awaiting Futures */

let NSEC_PER_SEC = 1000000000

extension timespec { 
    mutating func addnsec(nsec: Int) { 
        let nnsec = tv_nsec + nsec 
        tv_nsec = nnsec %  NSEC_PER_SEC
        tv_sec += nnsec / NSEC_PER_SEC 
    } 
}

extension sem_t {
    mutating func getvalue() -> Int32 {
        var v: Int32 = 0
        sem_getvalue(&self, &v)
        return v
    }

    mutating func timedwait(inout deadline: timespec) -> Int32 {
        return sem_timedwait(&self, &deadline)
    }

    mutating func post() {
        sem_post(&self)
    }
}

/**
A Future is a container for a computation of some sort whose result may not yet be 
available. It can be instantiated with a value or a block of code, to execute asynchronously,
producing this value. 
 */

public class Future<T> {
    typealias Element = T
    public typealias SuccessCallback = T -> ()

    var state: T?
    var successCallbacks: [SuccessCallback] = []

    var valueSemaphore: sem_t = sem_t()

    /** initialise an unfulfilled Future */
    init() { 
        sem_init(&valueSemaphore, 0, 0)
    }

    /** initialise a Future with a block of code to run asynchronously, 
        computing a value.
     */
    init(future: ()->T) {
        sem_init(&valueSemaphore, 0, 0)
        dispatch_async ( dispatch_get_global_queue(0, 0), {
            self._complete(future())
        })
        
    }

    /** initialise a Future with an immediately available value; slightly
        more efficient than firing off a block. */
    public init(immediate: T) {
        sem_init(&valueSemaphore, 0, 0)
        self._complete(immediate)
    }

    deinit {
        sem_destroy(&valueSemaphore)
    }

    private func _complete(value: T) {
        self.state = value
        self.valueSemaphore.post()
        for cb in self.successCallbacks {
            cb(value)
        }
    }

    /** Adds a callback to be called on successful completion. */
    public func onSuccess(action: SuccessCallback) {
        successCallbacks.append(action)
        if let value = self.state {
            action(value)
        }
    }

    /** map: creates a Future of type U from a Promise of type T and a T->U */
    public func map<U>(transform: T->U) -> Future<U> {
        let r = Promise<U>()
        self.onSuccess {
            r.complete(transform($0))
        }
        return r.future()
    }

    /** flatMap: allows the chaining of futures */
    public func flatMap<U>(transform: T->Future<U>) -> Future<U> {
        let r = Promise<U>()
        self.onSuccess { (v1: T) -> () in
            let p2 = transform(v1)
            p2.onSuccess { 
                r.complete($0)
            }
        }
        return r.future()
    }

    /** wait for a maximum amount of time for the Future to be fulfilled. */
    public func await(time: NSTimeInterval) -> T? {
        let nsec = Int(time * 1000000000)
        var ts: timespec = timespec()
        clock_gettime(CLOCK_REALTIME, &ts)
        ts.addnsec(nsec)

        valueSemaphore.timedwait(&ts)
        valueSemaphore.post()        

        return self.state
    }
}

/**
A Promise is a container for a possibly not yet available value like a Future, only 
with the facility for whatever process holds it to complete it by supplying this value.
It can also return a linked copy of itself as a (read-only) Future.
*/

class Promise<T> : Future<T> {

    override init() { super.init() }

    /** called by whatever process computes the Promise's value to complete it.
     */
    func complete(value: T) {
        self._complete(value)
    }

    func future() -> Future<T> { 
        return self as Future<T>
    }
}
