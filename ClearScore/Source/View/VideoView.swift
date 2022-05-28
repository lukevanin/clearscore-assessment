import UIKit
import AVFoundation

final class VideoView: UIView {
    
    var url: URL? {
        didSet {
            invalidateContents()
        }
    }
    
    var rate: Float = 1.0 {
        didSet {
            playerLayer.player?.rate = rate
        }
    }
    
    var videoGravity: AVLayerVideoGravity {
        get {
            playerLayer.videoGravity
        }
        set {
            playerLayer.videoGravity = newValue
        }
    }
    
    private var playerLooper: AVPlayerLooper?
    
    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    private func invalidateContents() {
        if let url = url {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVQueuePlayer()
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            player.playImmediately(atRate: rate)
            playerLayer.player = player
        }
        else {
            playerLayer.player = nil
            playerLooper = nil
        }
    }
    
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
}
