//
//  ViewController.swift
//  ShortsVideoDemo
//
//  Created by Lee Yen Lin on 2023/1/4.
//

import AVKit
import SnapKit

class ViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!

    let urlList = ["https://images-ext-1.discordapp.net/external/kh4a6UtNIb4S_1s2SNU8zz3_0646Ptq9PJJMtiascGk/https/media.tenor.com/ujb7n3KxxCwAAAPo/bocchi-bocchi-the-rock.mp4",
                   "https://cdn.discordapp.com/attachments/876137404153614347/1047795169736536134/1669862550264.mp4",
                   "https://cdn.discordapp.com/attachments/266876689894735872/1013465386315956315/934718294123.mp4",
                   "https://cdn.discordapp.com/attachments/461448991620726795/1008034681985433701/facebook-video4.mp4"]

    override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async { [self] in
            for i in stackView.arrangedSubviews {
                if let player = i as? PlayerView {
                    let h = scrollView.frame.height
                    player.snp.updateConstraints { make in
                        make.height.equalTo(h)
                    }
                    player.bounds = .init(x: 0, y: 0, width: stackView.bounds.width,
                                          height: h)
                    player.layoutIfNeeded()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for urlStr in urlList {
            let player = PlayerView()
            player.backgroundColor = .black
            player.snp.makeConstraints { make in
                make.height.equalTo(scrollView.frame.height)
            }
            player.bounds = .init(x: 0, y: 0, width: stackView.bounds.width,
                                  height: scrollView.frame.height)
            player.url = URL(string: urlStr)

            stackView.addArrangedSubview(player)
            player.create()
        }
        (stackView.arrangedSubviews.first as? PlayerView)?.player.play()

        scrollView.delegate = self
    }
}

extension UIScrollView {
    var page: Int {
        Int(round(contentOffset.y / frame.height))
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let view = stackView.arrangedSubviews[scrollView.page] as? PlayerView {
            view.player.pause()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let view = stackView.arrangedSubviews[scrollView.page] as? PlayerView {
            view.player.play()
        }
    }
}

class PlayerView: UIView {
    var url: URL?

    var player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var avlayer: AVPlayerLayer?

    override var bounds: CGRect {
        didSet {
            avlayer?.frame = bounds
        }
    }

    func create() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleView)))
        backgroundColor = .black
        if let url {
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: player, templateItem: item)

            avlayer = AVPlayerLayer(player: player)
            layer.addSublayer(avlayer!)
            avlayer?.frame = bounds
            avlayer?.videoGravity = .resizeAspect
        }
    }

    @objc func toggleView(_: UITapGestureRecognizer) {
        if player.rate != 0 {
            player.pause()
        } else {
            player.play()
        }
    }
}
