/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Kitura
import Foundation

public class ResponseTime: RouterMiddleware {
    
    let precision: Int
    let headerName: String
    let includeSuffix: Bool
    
    public init(precision: Int = 3, headerName: String = "X-Response-Time", includeSuffix: Bool = true) {
        self.precision = precision
        self.headerName = headerName
        self.includeSuffix = includeSuffix
    }

    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        let startTime = NSDate()
        var previousOnEndInvoked = {}
        previousOnEndInvoked = response.setOnEndInvoked() { [unowned self, unowned response] in
            let timeElapsed = startTime.timeIntervalSinceNow
#if os(Linux)
            let formatter = NSNumberFormatter()
#else
            let formatter = NumberFormatter()
#endif
            formatter.maximumFractionDigits = self.precision
#if os(Linux)
            let milisecondOutput = formatter.stringFromNumber(NSNumber(value: abs(timeElapsed) * 1000))
#else
            let milisecondOutput = formatter.string(from: NSNumber(value: abs(timeElapsed) * 1000))
#endif
            if let milisecondOutput = milisecondOutput {
                let value = self.includeSuffix ? milisecondOutput + "ms" : milisecondOutput
                response.headers[self.headerName] = value
            }
            previousOnEndInvoked()
        }
        next()
    }
}
