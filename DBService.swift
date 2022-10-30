//
//  DBService.swift
//  MoneyManageMobile
//
//  Created by 宜志富紹太 on 2022/08/13.
//

import Foundation
import SQLite3

final class DBService {
    static let shared = DBService()
    
    let dbFile = "Kakeibo.sqlite"
    var Kakeibo: OpaquePointer?
    
    init() {
        Kakeibo = openDatabase()
        if !createTable() {
            print("Failed to create table")
        }
    }
    
    func openDatabase() ->OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbFile)
        
        var Kakeibo: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &Kakeibo) != SQLITE_OK {
            print("Failed to open database")
            return nil
        }
        else {
//            let documentDirPath = NSSearchPathForDirectoriesInDomains(
//                            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//                        print("Simulator location \(documentDirPath)")
//                                    print("Db has been created with path = \(fileURL)")
            print("Success to open database")
            return Kakeibo
        }
    }
    
    func createTable() -> Bool {
        let createSql = """
        CREATE TABLE IF NOT EXISTS kakeibos (
            id INTEGER NOT NULL PRIMARY KEY autoincrement,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            amount INTEGER NOT NULL,
            amount_kbn INTEGER NOT NULL,
            description TEXT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
        );
        """
        
        var createStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(Kakeibo, (createSql as NSString).utf8String, -1, &createStmt, nil) != SQLITE_OK {
            print("db error: \(getDBErrorMessage(Kakeibo))")
            return false
        }
        
        if sqlite3_step(createStmt) != SQLITE_DONE {
            print("db error: \(getDBErrorMessage(Kakeibo))")
            sqlite3_finalize(createStmt)
            return false
        }
        
        sqlite3_finalize(createStmt)
        return true
    }
    
    func getDBErrorMessage(_ db: OpaquePointer?) -> String {
        if let err = sqlite3_errmsg(db) {
            return String(cString: err)
        } else {
            return ""
        }
    }
    
    func insert(queryString: String) {
        var stmt: OpaquePointer?
        
        // クエリを準備する
        if sqlite3_prepare(Kakeibo, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // クエリを実行する
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        print("data is registed")
    }
    
    //INSERT分生成
    func insertQueryBuilder(type: String, date: String, amount: Int, amount_kbn: Int, description: String) -> String {
        var insertQuery: [String] = []
        insertQuery.append("INSERT INTO kakeibos(type, date, amount, amount_kbn, description, created_at, updated_at) VALUES(")
        insertQuery.append("'\(type)', '\(date)', \(amount), \(amount_kbn), '\(description)',")
        insertQuery.append(" 'datetime(now)', 'datetime(now)')")
        
        let insertQueryBuilder = insertQuery.joined(separator: "")
        return insertQueryBuilder
    }
    
    func update(queryString: String) {
        var stmt: OpaquePointer?
        
        // クエリを準備する
        if sqlite3_prepare(Kakeibo, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // クエリを実行する
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        print("data is updated")
    }
    
    //UPDATE文生成
    func updateQueryBuilder(id : Int, type: String, date: String, amount: Int, description: String) -> String {
        var updateQuery: [String] = []
        updateQuery.append("UPDATE kakeibos SET")
        updateQuery.append(" type = '\(type)',")
        updateQuery.append(" date = '\(date)',")
        updateQuery.append(" amount = \(amount),")
        updateQuery.append(" description = '\(description)',")
        updateQuery.append(" updated_at = 'datetime(now)'")
        updateQuery.append(" WHERE id = \(id)")
        
        let updateQueryBuilder = updateQuery.joined(separator: "")
        return updateQueryBuilder
    }
    
    func delete(queryString: String) {
        var stmt: OpaquePointer?
        
        // クエリを準備する
        if sqlite3_prepare(Kakeibo, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // クエリを実行する
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        print("data is deleted")
    }
    
    //DELETE文生成
    func deleteQueryBUilder(id: Int) -> String {
        var deleteQuery: [String] = []
        deleteQuery.append("DELETE FROM kakeibos")
        deleteQuery.append(" WHERE id = \(id)")
        
        let deleteQueryBuilder: String = deleteQuery.joined(separator: "")
        return deleteQueryBuilder
    }
    
    func select(queryString: String) -> Dictionary<String, [String]>{
        var stmt:OpaquePointer?
        
        //1レコード分を格納するための辞書
        var kakeiboDic: Dictionary<String, [String]> = ["id":[], "type":[], "date":[], "amount":[], "amount_kbn":[], "description":[], "created_at":[], "updated_at":[]]
        
        // クエリを準備する
        if sqlite3_prepare(Kakeibo, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("error preparing insert: \(errmsg)")
            return kakeiboDic
        }
        
        // クエリを実行し、取得したレコードをループする
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            let id = String(sqlite3_column_int(stmt, 0))
            let type = String(cString: sqlite3_column_text(stmt, 1))
            let date = String(cString: sqlite3_column_text(stmt, 2))
            let amount = String(sqlite3_column_int(stmt, 3))
            let amount_kbn = String(sqlite3_column_int(stmt, 4))
            let description = String(cString: sqlite3_column_text(stmt, 5))
            let created_at = String(cString: sqlite3_column_text(stmt, 6))
            let updated_at = String(cString: sqlite3_column_text(stmt, 7))
            
            //連想配列に追加
            kakeiboDic["id"]?.append(id)
            kakeiboDic["type"]?.append(type)
            kakeiboDic["date"]?.append(date)
            kakeiboDic["amount"]?.append(amount)
            kakeiboDic["amount_kbn"]?.append(amount_kbn)
            kakeiboDic["description"]?.append(description)
            kakeiboDic["created_at"]?.append(created_at)
            kakeiboDic["updated_at"]?.append(updated_at)
            
        }
        return kakeiboDic
    }
    
    //SELECT文生成
    func selectQueryBuilder(_ amountKbn: Int, _ startDate: String, _ lastDate: String) -> String {
        var selectQuery: [String] = []
        selectQuery.append("SELECT * FROM kakeibos")
        if(amountKbn != nil) {
            selectQuery.append(" WHERE amount_kbn = \(amountKbn)")
        } else {
            selectQuery.append(" WHERE amount_kbn in(1, 2)")
        }
        if(startDate != "") {
            selectQuery.append(" AND date >= date('\(startDate)')")
            //selectQuery.append(" AND date >= date('2022-08-20')") //日付検索はこれでうまくいきました
        }
        if(lastDate != "") {
            selectQuery.append(" AND date <= date('\(lastDate)')")
        }
        selectQuery.append(" ORDER BY date ASC")
        
        let selectQueryBuilder: String = selectQuery.joined(separator: "")
        return selectQueryBuilder
    }
    
    //全てのデータを取得するSELECT文生成
    func selectAllQueryBuilder() -> String {
        var selectQuery: [String] = []
        selectQuery.append("SELECT * FROM kakeibos")
        selectQuery.append(" ORDER BY date ASC")
        
        let selectQueryBuilder: String = selectQuery.joined(separator: "")
        return selectQueryBuilder
    }
    
    //カテゴリごとの合計値を算出
    func selectCalc(amountKbn: Int, startDate: String, lastDate: String) -> Dictionary<String, [String]> {
        var stmt:OpaquePointer?
        
        var selectCalcQuery: [String] = []
        selectCalcQuery.append("SELECT type, sum(amount) FROM kakeibos")
        selectCalcQuery.append(" WHERE amount_kbn = \(amountKbn)")
        selectCalcQuery.append(" AND date >= date('\(startDate)')")
        selectCalcQuery.append(" AND date <= date('\(lastDate)')")
        selectCalcQuery.append(" GROUP BY type")
        selectCalcQuery.append(" HAVING sum(amount) > 0")
        let selectCalcQueryBuilder: String = selectCalcQuery.joined(separator: "")
        
        //1レコード分を格納するための辞書
        var kakeiboDic: Dictionary<String, [String]> = ["type":[], "amount":[]]
        
        // クエリを準備する
        if sqlite3_prepare(Kakeibo, selectCalcQueryBuilder, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("error preparing select: \(errmsg)")
            return kakeiboDic
        }
        
        // クエリを実行し、取得したレコードをループする
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let type = String(cString: sqlite3_column_text(stmt, 0))
            let amount = String(sqlite3_column_int(stmt, 1))
            
            //連想配列に追加
            kakeiboDic["type"]?.append(type)
            kakeiboDic["amount"]?.append(amount)
            
        }
        return kakeiboDic
    }
    
    //月毎の合計支出額
    func selectTotalAmount(amountKbn: Int, startDate: String, lastDate: String) -> String {
        var stmt:OpaquePointer?
        
        var selectTotalQuery: [String] = []
        selectTotalQuery.append("SELECT sum(amount) FROM kakeibos")
        selectTotalQuery.append(" WHERE amount_kbn = \(amountKbn)")
        selectTotalQuery.append(" AND date >= date('\(startDate)')")
        selectTotalQuery.append(" AND date <= date('\(lastDate)')")
        
        let selectTotalQueryBuilder: String = selectTotalQuery.joined(separator: "")
        
        var totalAmount: String = ""
        
        // クエリを準備する
        if sqlite3_prepare(Kakeibo, selectTotalQueryBuilder, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Kakeibo)!)
            print("error preparing select: \(errmsg)")
            return totalAmount
        }
        
        //クエリを実行
        sqlite3_step(stmt)
        
        let amount = String(sqlite3_column_int(stmt, 0))
        
        totalAmount = amount
        
        return totalAmount
    }
    
}
