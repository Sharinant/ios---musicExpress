//
//  PlayBackPresenter.swift
//  MusicExpress
//
//  Created by Антон Шарин on 27.05.2021.
//
import AVFoundation
import Foundation
import UIKit


protocol PlayerDataSource : AnyObject {
    var songName : String { get }
    var subtitle : String { get }
    var imageURLstring : String { get }
    var currentTime : String { get }
    var durationString : String { get }
    var durationValue : Float { get }
    var currentTimeValue : Float { get }
   

}


final class PlayBackPresenter {
    
    static let shared = PlayBackPresenter()
    
    private var track : Track?
   
    var currentTrackDuration : String = ""
    var currentTrackCurrentTime : String = ""
    
    var slidersValueMax : Float = 0
    var currentSlidersValue : Float = 0
    
    var currentTrack : Track?

    private var title : String = ""
    private var imageUrl: String = ""
    private var artist : String = ""
        
    var player : AVPlayer?
    
    var playerVC : PlayerViewController?
 
    private var trackBySong : Song?
    private var tracksBySong = [Song]()

    private var currentItemIndex : Int?
    private var songs : [Song]?
    private var tracks : [Track]?

    private var currentItemSong : Song?
    private var currentItemTrack : Track?
    

    
    
    func playSongBySong(
        
        from viewController: UIViewController,
        songs : [Song],
        currentItemIndex : Int) {
        
        player?.pause()
        
        self.currentItemIndex = currentItemIndex
        self.songs = songs
        self.currentItemSong = songs[currentItemIndex]
        
        self.imageUrl = currentItemSong?.album_poster ?? ""
        self.title = currentItemSong?.title ?? ""
        self.artist = currentItemSong?.artist ?? ""
        
        self.currentItemTrack = nil
        self.tracks = []

        self.currentTrackCurrentTime = "0:00"
        self.currentTrackDuration = convertSecondsToTime(time: currentItemSong?.duration ?? 0)
        self.slidersValueMax = Float(currentItemSong?.duration ?? 0)
        
        guard let currentURL = URL(string: "https://musicexpress.sarafa2n.ru" + (currentItemSong?.audio ?? "")) else { return }
        player = AVPlayer(url: currentURL)
        player?.volume = 0.5
        
        let vc = PlayerViewController()
        self.playerVC = vc

        vc.title = currentItemSong?.name ?? currentItemSong?.title ?? ""
        vc.dataSource = self
        vc.delegate = self
        vc.modalTransitionStyle = .flipHorizontal
        viewController.present(vc, animated: true) { [weak self] in
            self?.player?.play()
            
            
            self?.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000),
                                                  queue: DispatchQueue.main)
            { [self] (time) in
                
                if time.seconds > Double(self?.currentItemSong?.duration ?? 0) {
                    print("End")
               //     self?.player?.pause()
                    
                    self?.didTapForward()
                    sleep(2)
                }
                self?.currentSlidersValue = Float(round(time.seconds))
                self?.currentTrackCurrentTime = self?.convertSecondsToTime(time: Int(self?.currentSlidersValue ?? 0)) ?? ""
                self?.playerVC?.refreshUI()


            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("playerOn") , object: nil)
        
        // Сохранение контроллера в память
        PlayerContext.context = vc
    }
    
  
    func playSongByTrack(
        from viewController: UIViewController,
        tracks : [Track],
        currentItemIndex : Int) {
        
        player?.pause()

        self.currentItemIndex = currentItemIndex
        self.tracks = tracks
        self.currentItemTrack = tracks[currentItemIndex]
        
        self.currentTrackCurrentTime = "0:00"
        self.currentTrackDuration = convertSecondsToTime(time: currentItemTrack?.duration ?? 0)
        self.slidersValueMax = Float(currentItemTrack?.duration ?? 0)
        
        self.imageUrl = currentItemTrack?.album_poster ?? ""
        self.title = currentItemTrack?.title ?? ""
        self.artist = currentItemTrack?.artist ?? ""
        
        self.currentItemSong = nil
        self.songs = []

        guard let currentURL = URL(string: "https://musicexpress.sarafa2n.ru" + (currentItemTrack?.audio ?? "")) else { return }
        player = AVPlayer(url: currentURL)
        player?.volume = 0.5
        
        let vc = PlayerViewController()
        self.playerVC = vc

        vc.title = currentItemTrack?.title ?? ""
        vc.dataSource = self
        vc.delegate = self
        vc.modalTransitionStyle = .flipHorizontal

        NotificationCenter.default.post(name: NSNotification.Name("playerOn") , object: nil)

        viewController.present(vc, animated: true) { [weak self] in
            self?.player?.play()
            self?.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000),
                                                  queue: DispatchQueue.main)
            { [self] (time) in
                
                self?.player?.actionAtItemEnd = .pause
                if time.seconds > Double(self?.currentItemTrack?.duration ?? 0) {
                    print("End")
                    
                    self?.didTapForward()
                    
                }
                
                self?.currentSlidersValue = Float(round(time.seconds))
                self?.currentTrackCurrentTime = self?.convertSecondsToTime(time: Int(self?.currentSlidersValue ?? 0)) ?? ""
                self?.playerVC?.refreshUI()

            }
        }
        
        PlayerContext.context = vc

    }
    // Конвертация секунд в минуты
        private func convertSecondsToTime(time: Int) -> String {
                let seconds = time % 60
                let minutes = time / 60
                
                var stringSeconds = "\(seconds)"
                let stringMinutes = "\(minutes)"
                
                if seconds < 10 {
                    stringSeconds = "0\(seconds)"
                }
                
               
                
                return "\(stringMinutes):\(stringSeconds)"
            }
}


extension PlayBackPresenter: PlayerViewControllerDelegate {
    func didSlideSliderVolume(value: Float) {
        player?.volume = value
    }
    
    func didSlideSliderSong(value: Float) {
        
        player?.seek(to: CMTime(seconds: Double(value), preferredTimescale: 5000))
        
        
    }
    
    
   
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
                NotificationCenter.default.post(name: NSNotification.Name("Pause"), object: nil)
                
            }
            else if player.timeControlStatus == .paused {
                player.play()
                NotificationCenter.default.post(name: NSNotification.Name("Play"), object: nil)

            }
        }
    }
    
    func didTapForward() {
        
        player?.pause()
        playerVC?.nullSlider()
        currentTrackCurrentTime = "0:00"
        currentSlidersValue = 0
        playerVC?.refreshUI()
        

        if currentItemTrack == nil && tracks?.isEmpty == true {
            
            if ((currentItemIndex ?? 0)) == ((songs?.count ?? 0) - 1) {
                currentItemIndex = 0
            } else {
            currentItemIndex = (currentItemIndex ?? 0) + 1
            }
            
            currentItemSong = songs?[currentItemIndex ?? 0]
            self.currentTrackDuration = convertSecondsToTime(time: currentItemSong?.duration ?? 0)
            self.slidersValueMax = Float(currentItemSong?.duration ?? 0)

            guard let currentUrl = URL(string: "https://musicexpress.sarafa2n.ru" + (currentItemSong?.audio ?? "")) else { return }
            
            self.title = currentItemSong?.title ?? ""
            self.artist = currentItemSong?.artist ?? ""
            self.imageUrl = currentItemSong?.album_poster ?? ""
           
            player = AVPlayer(url: currentUrl)
            player?.play()
            NotificationCenter.default.post(name: NSNotification.Name("Play"), object: nil)
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { [self] (time) in
                
                if time.seconds > Double(self.currentItemSong?.duration ?? 0) {
                    sleep(2)
                    print("End")
                    //self.player?.pause()

                    self.didTapForward()
                }
                
                self.currentSlidersValue = Float(round(time.seconds))
                self.currentTrackCurrentTime = self.convertSecondsToTime(time: Int(self.currentSlidersValue))
                self.playerVC?.refreshUI()
            }
            
        } else if currentItemSong == nil && songs?.isEmpty == true {
            
            if ((currentItemIndex ?? 0)) == ((tracks?.count ?? 0) - 1) {
                currentItemIndex = 0
            } else {
            currentItemIndex = (currentItemIndex ?? 0) + 1
            }
            
            currentItemTrack = tracks?[currentItemIndex ?? 0]
            self.currentTrackDuration = convertSecondsToTime(time: currentItemTrack?.duration ?? 0)
            self.slidersValueMax = Float(currentItemTrack?.duration ?? 0)

            guard let currentUrl = URL(string: "https://musicexpress.sarafa2n.ru" + (currentItemTrack?.audio ?? "")) else { return }
            
            self.title = currentItemTrack?.title ?? ""
            self.artist = currentItemTrack?.artist ?? ""
            self.imageUrl = currentItemTrack?.album_poster ?? ""
            
            player = AVPlayer(url: currentUrl)
            player?.play()
            NotificationCenter.default.post(name: NSNotification.Name("Play"), object: nil)
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { [self] (time) in
                
                if time.seconds > Double(self.currentItemTrack?.duration ?? 0) {
                    print("End")
                    self.player?.pause()
                    self.didTapForward()
                }
                
                self.currentSlidersValue = Float(round(time.seconds))
                self.currentTrackCurrentTime = self.convertSecondsToTime(time: Int(self.currentSlidersValue))
                self.playerVC?.refreshUI()

            }
        }
        
        playerVC?.title = self.title
        playerVC?.refreshUI()
        
    }
    
    func didTapBackward() {
        player?.pause()
        playerVC?.nullSlider()
        currentTrackCurrentTime = "0:00"
        currentSlidersValue = 0
        playerVC?.refreshUI()
        
        if currentItemTrack == nil && tracks?.isEmpty == true {
            
            if ((currentItemIndex ?? 0) == 0) {
                currentItemIndex = (songs?.count ?? 0) - 1
            } else {
            currentItemIndex = (currentItemIndex ?? 0) - 1
            }
            
            currentItemSong = songs?[currentItemIndex ?? 0]
            self.currentTrackDuration = convertSecondsToTime(time: currentItemSong?.duration ?? 0)
            self.slidersValueMax = Float(currentItemSong?.duration ?? 0)


            guard let currentUrl = URL(string: "https://musicexpress.sarafa2n.ru" + (currentItemSong?.audio ?? "")) else { return }
            
            self.title = currentItemSong?.title ?? ""
            self.artist = currentItemSong?.artist ?? ""
            self.imageUrl = currentItemSong?.album_poster ?? ""
            
            player = AVPlayer(url: currentUrl)
            player?.play()
            NotificationCenter.default.post(name: NSNotification.Name("Play"), object: nil)
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { [self] (time) in
                
                if time.seconds > Double(self.currentItemSong?.duration ?? 0) {
                    print("End")
                    self.player?.pause()
                    self.didTapForward()
                }
                
                self.currentSlidersValue = Float(round(time.seconds))
                self.currentTrackCurrentTime = self.convertSecondsToTime(time: Int(self.currentSlidersValue))
                self.playerVC?.refreshUI()

            }
        }
        else if currentItemSong == nil && songs?.isEmpty == true {
            
            if ((currentItemIndex ?? 0) == 0) {
                currentItemIndex = (tracks?.count ?? 0) - 1
            } else {
            currentItemIndex = (currentItemIndex ?? 0) - 1
            }

            currentItemTrack = tracks?[currentItemIndex ?? 0]
            self.slidersValueMax = Float(currentItemTrack?.duration ?? 0)
            self.currentTrackDuration = convertSecondsToTime(time: currentItemTrack?.duration ?? 0)


            guard let currentUrl = URL(string: "https://musicexpress.sarafa2n.ru" + (currentItemTrack?.audio ?? "")) else { return }
            
            self.title = currentItemTrack?.title ?? ""
            self.artist = currentItemTrack?.artist ?? ""
            self.imageUrl = currentItemTrack?.album_poster ?? ""
            
            player = AVPlayer(url: currentUrl)
            player?.play()
            NotificationCenter.default.post(name: NSNotification.Name("Play"), object: nil)
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { [self] (time) in
                
                if time.seconds > Double(self.currentItemTrack?.duration ?? 0) {
                    print("End")
                    self.player?.pause()
                    self.didTapForward()
                }
                
                self.currentSlidersValue = Float(round(time.seconds))
                self.currentTrackCurrentTime = self.convertSecondsToTime(time: Int(self.currentSlidersValue))
                self.playerVC?.refreshUI()
            }
        }
        playerVC?.title = self.title
        playerVC?.refreshUI()
    }
}

extension PlayBackPresenter: PlayerDataSource {
    var currentTimeValue: Float {
        return currentSlidersValue
    }
    
    
    var durationValue: Float {
        return slidersValueMax
    }
    
    var currentTime: String {
        return currentTrackCurrentTime
    }
    
    var durationString: String {
        return currentTrackDuration
    }
    
    var songName: String {
        return title
    }
    
    var subtitle: String {
        return artist

    }
    
    var imageURLstring: String {
        return imageUrl

    }
}


    
    

