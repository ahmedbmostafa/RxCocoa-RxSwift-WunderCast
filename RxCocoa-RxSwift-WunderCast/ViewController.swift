//
//  ViewController.swift
//  RxCocoa-RxSwift-WunderCast
//
//  Created by ahmed mostafa on 1/7/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var searchCityName: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    
    let bag = DisposeBag()

    override func viewDidLoad() {
      super.viewDidLoad()
        let search = searchCityName.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchCityName.text ?? "" }
       // let search = searchCityName.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .flatMapLatest { text in
                return APIController.shared.currentWeather(city: text)
                    .catchErrorJustReturn(APIController.Weather.empty)
                
            }
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
        
        search.map { "\($0.temperature)° C" }
            .bind(to: tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map {"\($0.humidity)%"}
            .bind(to: humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map {$0.icon}
            .bind(to: iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map {$0.cityName}
            .bind(to: cityNameLabel.rx.text)
            .disposed(by: bag)

        style()
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      Appearance.applyBottomLine(to: searchCityName)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }


    private func style() {
      view.backgroundColor = UIColor.aztec
      searchCityName.textColor = UIColor.ufoGreen
      tempLabel.textColor = UIColor.cream
      humidityLabel.textColor = UIColor.cream
      iconLabel.textColor = UIColor.cream
      cityNameLabel.textColor = UIColor.cream
    }
  }


