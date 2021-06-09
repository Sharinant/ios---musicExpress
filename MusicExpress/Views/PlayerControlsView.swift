//
//  PlayerControlsView.swift
//  MusicExpress
//
//  Created by Антон Шарин on 27.05.2021.
//

import Foundation
import UIKit


protocol PlayerControlsViewDelegate : AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapPForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidSlideSliderVolume(_ playerControlsView: PlayerControlsView, value : Float)
    func playerControlsViewDidSlideSliderSong(_ playerControlsView: PlayerControlsView, value : Float)


}


struct PlayerControlsViewViewModel {
    let title : String?
    let subtitle: String?
    let duration : String?
    let currentTimeString : String?
    let currentDuration : Float?
    let currentTimeValue : Float?
    
}

final class PlayerControlsView : UIView {
    
    private var isPlaying = true
    
    weak var delegate : PlayerControlsViewDelegate?
    
    private let volumeSlider : UISlider = {
        let slider = UISlider()
        
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.minimumTrackTintColor = .gray
        slider.tintColor = .gray
        slider.value = 0.5
        return slider
    }()
    
    private let currentTimeLabel : UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()
    
    private let currentDuration : UILabel = {
        let label = UILabel()
        label.text = "7:42"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()
    
    private let songSlider : UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemPink
        slider.minimumTrackTintColor = .systemPink
        slider.value = 1
        slider.minimumValue = 0
        slider.maximumValue = 250
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.text = "This is song name"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "This is song artist"

        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    //speaker.wave.3.fill
    
    private let speakerButtonEmpty: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "speaker",withConfiguration: UIImage.SymbolConfiguration(pointSize: 10))
        button.setImage(image, for: .normal)

        
        return button
    }()
    
    private let speakerButtonFull: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "speaker.wave.2",withConfiguration: UIImage.SymbolConfiguration(pointSize: 10))
        button.setImage(image, for: .normal)

        
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemPink
        button.alpha = 0.95

        let image = UIImage(systemName: "backward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34))
        button.setImage(image, for: .normal)

        
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemPink
        button.alpha = 0.95

        let image = UIImage(systemName: "forward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34))
        button.setImage(image, for: .normal)

        
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemPink
        button.alpha = 0.95
        let image = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34))
        button.setImage(image, for: .normal)
                                                                                                    
        
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        
        
        addSubview(volumeSlider)
        
        addSubview(songSlider)
        addSubview(currentTimeLabel)
        addSubview(currentDuration)
        
        addSubview(speakerButtonEmpty)
        addSubview(speakerButtonFull)
        
        addSubview(backButton)
        addSubview(forwardButton)
        addSubview(playPauseButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(configurePlayPauseButtonToPlay), name: NSNotification.Name("Play"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configurePlayPauseButtonToPause), name: NSNotification.Name("Pause"), object: nil)
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didSlideSliderVolume), for: .valueChanged)
        songSlider.addTarget(self, action: #selector(didSlideSliderSong), for: .valueChanged)

        
        clipsToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc  func didSlideSliderVolume(_ slider:UISlider) {
        let value = slider.value
        delegate?.playerControlsViewDidSlideSliderVolume(self, value: value)
    }
    
    @objc  func didSlideSliderSong(_ slider:UISlider) {
        let value = slider.value
        delegate?.playerControlsViewDidSlideSliderSong(self, value: value)
    }
    
    @objc private func didTapBack() {
        delegate?.playerControlsViewDidTapBackwardButton(self)
        
    }
    @objc private func didTapNext() {
        delegate?.playerControlsViewDidTapPForwardButton(self)
    }
    @objc private func didTapPlayPause() {
        
       

        self.isPlaying = !isPlaying
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
    
    }
    
    @objc private func configurePlayPauseButtonToPlay () {
        let pause = UIImage(systemName: "pause.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34))
        

        playPauseButton.setImage(pause, for: .normal)
    }
    
    @objc private func configurePlayPauseButtonToPause () {
        
        let play = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34))

        playPauseButton.setImage(play, for: .normal)
        
    }
    
    override func layoutSubviews() {
        speakerButtonEmpty.sizeToFit()
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 25)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom + 10, width: width, height: 25)
        nameLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        
        let buttonSize:CGFloat = 60
        
        songSlider.frame = CGRect(x: backButton.left - 20, y: subtitleLabel.bottom + 60, width: 150 + (3 * buttonSize), height: 30)
        currentTimeLabel.frame = CGRect(x: songSlider.left - 10 , y: songSlider.top - 15  , width: 35, height: 30)
        currentDuration.frame = CGRect(x: songSlider.right - 15, y: songSlider.top - 15  , width: 35, height: 30)


        playPauseButton.frame = CGRect(x: (width - buttonSize)/2, y: songSlider.bottom + 35, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left - 55 - buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        forwardButton.frame = CGRect(x: playPauseButton.right + 55, y: playPauseButton.top, width: buttonSize, height: buttonSize)

        volumeSlider.frame = CGRect(x: backButton.left, y: playPauseButton.bottom + 10 , width: 110 + (3 * buttonSize), height: 44)
        speakerButtonEmpty.frame = CGRect(x: volumeSlider.left - 38, y: volumeSlider.top + 7, width: 30, height: 30)
        speakerButtonFull.frame = CGRect(x: volumeSlider.right + 10 , y: speakerButtonEmpty.top, width: 30, height: 30)

        
    }
    
    func nullSlider () {
        songSlider.value = 0
    }
    
    
    func configure(with viewModel: PlayerControlsViewViewModel) {
        
        songSlider.value = viewModel.currentTimeValue ?? 0
        songSlider.maximumValue = viewModel.currentDuration ?? 0
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        currentTimeLabel.text = viewModel.currentTimeString
        currentDuration.text = viewModel.duration
        
        
    }
}
