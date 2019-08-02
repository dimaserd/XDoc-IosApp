//
//  ResultViewController.swift
//  SESmartIDSample
//
//  Created by Антон Никандров on 10/07/2019.
//  Copyright © 2019 biz.smartengines. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    private enum cellTypes: String {
        case surname
        case name
        case patronymic
        case birthdate
        case birthplace
        case series
        case number
        case issueDate = "issue_date"
        case issueAuthority = "authority"
        
        func description() -> String {
            switch self {
            case .name:
                return "Имя"
            case .surname:
                return "Фамилия"
            case .patronymic:
                return "Отчество"
            case .birthdate:
                return "Дата рождения"
            case .birthplace:
                return "Место рождения"
            case .series:
                return "Серия"
            case .number:
                return "Номер"
            case .issueDate:
                return "Дата выдачи"
            case .issueAuthority:
                return "Выдан"
            }
        }
    }
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    private struct Constants {
        static let cellId = "TheCell"
    }
    private var cells: [cellTypes] = []
    private var resultDictionary: [String: SmartIDStringField] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func configure(with result: SmartIDRecognitionResult) {
        resultDictionary = result.getStringFields()
        cells = resultDictionary.compactMap { (key, value) -> cellTypes? in
            return cellTypes(rawValue: key)
        }
        tableView.reloadData()
    }
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId) {
            cell.textLabel?.text = resultDictionary[cells[indexPath.section].rawValue]?.getValue()
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: Constants.cellId)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cells[section].description()
    }
}
