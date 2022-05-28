import UIKit
import AVFoundation

///
/// Displays a looping video. Used by the loading  and score screens to display an animated background.
///
final class VideoView: UIView {
    
    /// URL of the video to play. Setting the URL variable causes the vudeo to start playing automatically. Currently only local video files are supported.
    var url: URL? {
        didSet {
            invalidateContents()
        }
    }
    
    /// Rate at which the video should be played. A value of zero stops the video. A positive value plays the video forward in time. A negative value plays the
    /// video in reverse. A value of 1 (or -1) plays the video at its normal frame rate, with values smaller or greater playing the video slower or faster respectively.
    var rate: Float = 1.0 {
        didSet {
            playerLayer.player?.rate = rate
        }
    }
    
    /// Specifies how video content should be resized when the video content aspect ratio does not match that of the visible display area. 
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
