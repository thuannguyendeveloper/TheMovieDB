//
//  MovieListViewController.swift
//  TheMovieDB
//
//  Created by ThuanNguyen on 31/07/22.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftMessages
import SVProgressHUD

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var reachability: Reachability?
    let messages = SwiftMessages()
    var totalPages = 0
    var movies: [Movie] = [Movie]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var currentPage = 0 {
        didSet {
            self.view.isUserInteractionEnabled = false
            SVProgressHUD.show()
            guard currentPage <= totalPages || currentPage == 1 else {
                self.view.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                return
            }
            viewModel.loadData(page: currentPage)
            viewModel.dataObservable.asDriver(onErrorJustReturn: nil)
                .drive(onNext: { [weak self] info in
                    guard let self = self else {
                        return
                    }
                    self.view.isUserInteractionEnabled = true
                    SVProgressHUD.dismiss()
                    
                    guard let data = info?.results,
                          data.count > 0,
                          let totalPages = info?.totalPages
                    else {
                        SVProgressHUD.showSuccess(withStatus: "No results!")
                        return
                    }
                    if self.currentPage == 1 {
                        self.movies = data
                    } else {
                        self.movies.append(contentsOf: data)
                    }
                    self.totalPages = totalPages
                })
                .disposed(by: bag)
        }
    }
    private let bag = DisposeBag()
    
    var viewModel = MovieListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
        self.totalPages = 1000
        self.currentPage = 998
    }
    
    private func config() {
        self.configUI()
        self.configReachability()
    }
    
    private func configReachability() {
        reachability = Reachability()
        try? reachability?.startNotifier()
    }
    
    private func configUI() {
        self.title = "Movie List"
        self.setupCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Reachability.rx.isDisconnected
            .subscribe(onNext:{
                let error = MessageView.viewFromNib(layout: .tabView)
                error.configureTheme(.error)
                error.configureContent(title: "Error", body: "Not connected to the network!")
                error.button?.setTitle("Stop", for: .normal)
                SwiftMessages.show(view: error)
            })
            .disposed(by:bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "MovieCell", bundle: nil), forCellWithReuseIdentifier: MovieCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let rows = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let spacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(rows - 1))
        
        let size = Int((collectionView.bounds.width - spacing) / CGFloat(rows))
        let height = Int((collectionView.bounds.width - spacing) / CGFloat(rows)) * 448 / 300
        return CGSize(width: size, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell {
            cell.configData(movie: movies[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard indexPath.row == movies.count - 1 else {
            return
        }
        self.currentPage += 1
    }
}
