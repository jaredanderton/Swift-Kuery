/**
 Copyright IBM Corporation 2016
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest

@testable import SwiftKuery

class TestJoin: XCTestCase {
    
    static var allTests: [(String, (TestJoin) -> () throws -> Void)] {
        return [
            ("testJoin", testJoin),
        ]
    }
    
    class MyTable1 : Table {
        let a = Column("a")
        let b = Column("b")
        
        let name = "table1Join"
    }
    
    class MyTable2 : Table {
        let c = Column("c")
        let b = Column("b")
        
        let name = "table2Join"
    }
    
    func testJoin() {
        let myTable1 = MyTable1()
        let myTable2 = MyTable2()
        let connection = createConnection()
        
        var s = Select(from: myTable1)
            .join(myTable2)
            .on(myTable1.b == myTable2.b)
        var kuery = connection.descriptionOf(query: s)
        var query = "SELECT * FROM table1Join JOIN table2Join ON table1Join.b = table2Join.b"
        XCTAssertEqual(kuery, query, "Error in query construction: \(kuery) \ninstead of \(query)")
        
        let t1 = myTable1.as("t1")
        let t2 = myTable2.as("t2")
        s = Select(from: t1)
            .join(t2)
            .on(t1.b == t2.b)
        kuery = connection.descriptionOf(query: s)
        query = "SELECT * FROM table1Join AS t1 JOIN table2Join AS t2 ON t1.b = t2.b"
        XCTAssertEqual(kuery, query, "Error in query construction: \(kuery) \ninstead of \(query)")

        s = Select(from: myTable1)
            .leftJoin(myTable2)
            .on(myTable1.a == myTable2.c)
        kuery = connection.descriptionOf(query: s)
        query = "SELECT * FROM table1Join LEFT JOIN table2Join ON table1Join.a = table2Join.c"
        XCTAssertEqual(kuery, query, "Error in query construction: \(kuery) \ninstead of \(query)")
        
        s = Select(from: t1)
            .fullJoin(t2)
            .using(t1.b)
        kuery = connection.descriptionOf(query: s)
        query = "SELECT * FROM table1Join AS t1 FULL JOIN table2Join AS t2 USING (b)"
        XCTAssertEqual(kuery, query, "Error in query construction: \(kuery) \ninstead of \(query)")
    }
}