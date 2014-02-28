//
//  ViewController.m
//  BeatRun
//
//  Created by Shinya Hirai on 2/27/14.
//  Copyright (c) 2014 Shinya Hirai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    MPMusicPlayerController* _musicPlayer;
    
    // スライダー and タイマー
    EFCircularSlider* _circularSlider;
    float _duration;
    NSTimer* _seekSliderTimer;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    //ミュージックプレイヤー
    _musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    _musicPlayer.currentPlaybackRate = 1;
    _musicPlayer.shuffleMode = MPMusicShuffleModeOff;
    _musicPlayer.repeatMode = MPMusicRepeatModeNone;
    
    // 曲が変わった際の通知を取得
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter
     addObserver:self
     selector:@selector(nowPlayingItemDidChangeNotification:)
     name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:_musicPlayer];
    
    // 再生状態が変わった際の通知を取得
    [notificationCenter
     addObserver:self
     selector:@selector (playbackStateDidChangeNotification:)
     name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:_musicPlayer];
    
    // 曲が変わった際にプレイヤから通知を発行するよう設定
    [_musicPlayer beginGeneratingPlaybackNotifications];
    
    // Circle Sliderの設定
    _circularSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake(45, 45, 230, 230)];
    _circularSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
    _circularSlider.filledColor = [UIColor colorWithRed:155/255.0f green:211/255.0f blue:156/255.0f alpha:1.0f];
    _circularSlider.handleType = EFBigCircle;
    _circularSlider.handleColor = [UIColor colorWithRed:155/255.0f green:250/255.0f blue:180/255.0f alpha:1.0f];
    _circularSlider.lineWidth = 6;

    [self.view addSubview:_circularSlider];
    
    // タッチアップイベント取得によってタイマーとの共存
    // valueChangedでは両方が交互に反応し合ってしまうため応急処置
    [_circularSlider addTarget:self action:@selector(timeDidChange:) forControlEvents:UIControlEventTouchUpInside];
    
    // 各種初期設定
    _songPlayTimeLabel.text = @"0:00";
    
    // グラデーションビューの設定
    float width = _gradationView.frame.size.width, height = _gradationView.frame.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    size_t numOfComponent = 2;
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {
        1.0f/255.0f, 1.0f/255.0f, 1.0f/255.0f, 1.0f,
        255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 1.0f
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, numOfComponent);

    // 制作したグラデーション内容で画像を生成する
    CGContextDrawLinearGradient(bitmapContext, gradient, CGPointMake(0, 0), CGPointMake(0, height), 0);
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    
    // 生成したグラデーション画像を背景に指定する。
    [_gradationView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    _gradationView.alpha = 0.7;
        
    // 曲が流れていれば情報取得
    [self getCurrentMusicInfoAndView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getCurrentMusicInfoAndView {
    //現在再生されている曲の情報を取得
    MPMediaItem *playingItem = [_musicPlayer nowPlayingItem];
    
    if (playingItem) {
        
        //音楽が再生されているか確認するためにTypeを取得
        NSInteger mediaType = [[playingItem valueForProperty:MPMediaItemPropertyMediaType] integerValue];
        
        if (mediaType == MPMediaTypeMusic) {
            // 各種情報取得
            NSString *songTitleString = [playingItem valueForProperty:MPMediaItemPropertyTitle];
            NSString *artistString = [playingItem valueForProperty:MPMediaItemPropertyArtist];
            NSString *bpmString = [[playingItem valueForProperty:MPMediaItemPropertyBeatsPerMinute] stringValue];
            MPMediaItemArtwork *artwork = [playingItem valueForProperty:MPMediaItemPropertyArtwork];
            
            // 各種表示設定
            _bpmLabel.text = [NSString stringWithFormat:@"BPM:%@",bpmString];
            _songTitleLabel.text = songTitleString;
            _artistLabel.text = artistString;
            // TODO: プレイリスト TextView
            
            // アートワーク設定
            UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(320, 320)];
            _artworkImage.image = artworkImage;
            _artworkImage.alpha = 0.5;
            
            // ミニアートワークの設定
            UIImage *miniArtworkImage = [artwork imageWithSize:CGSizeMake(200, 200)];
            _miniArtworkImage.image = miniArtworkImage;
            _miniArtworkImage.layer.cornerRadius = 100;
            _miniArtworkImage.clipsToBounds = YES;
            
            // 現在流れている曲の長さを取得
            _duration = [[playingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue];
            
            // スライダーの設定
            int i = 0;
            _circularSlider.minimumValue = i;
            _circularSlider.maximumValue = _duration;
            
            _seekSliderTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f)
                                                     target:self selector:@selector(updateSeekSliderDisplay:)
                                                   userInfo:nil repeats:YES];
        } else {
            _songTitleLabel.text = @"曲が選択されていません";
        }
    }
}

#pragma mark - Notification
- (void)nowPlayingItemDidChangeNotification:(id)notification {
    NSString* notificationName = [notification name];
    if ([notificationName isEqualToString:MPMusicPlayerControllerNowPlayingItemDidChangeNotification]) {
        [self getCurrentMusicInfoAndView];
    }
}

- (void)playbackStateDidChangeNotification:(NSNotification *)notification
{
	MPMusicPlaybackState state = _musicPlayer.playbackState;
	if (state == MPMusicPlaybackStatePlaying) {
		[_playAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
	} else {
		[_playAndPauseButton setTitle:@"Play" forState:UIControlStateNormal];
	}
}

#pragma mark - Button action
- (IBAction)playAndPause:(id)sender {
    MPMusicPlaybackState state = _musicPlayer.playbackState;
    if (state == MPMusicPlaybackStatePaused) {
        [_musicPlayer play];
    } else if (state == MPMusicPlaybackStatePlaying) {
        [_musicPlayer pause];
    }
}

- (IBAction)skipToPrevious:(id)sender {
    _circularSlider.currentValue = 0.0f;
    if (_musicPlayer.currentPlaybackTime < 3.0f) {
        [_musicPlayer skipToPreviousItem];
    } else {
        [_musicPlayer skipToBeginning];
    }
}

- (IBAction)skipToNext:(id)sender {
    _circularSlider.currentValue = 0.0f;
    [_musicPlayer skipToNextItem];
}

#pragma mark - Slider
-(void)updateSeekSliderDisplay:(NSTimer*)timer {
    // TODO: 曲再生用のスライダーと時間
    int current = _musicPlayer.currentPlaybackTime; //int型に変換して計算
    int minute = current / 60; //現在時間÷６０で「分」の部分。
    int sec = current % 60; //現在時間÷６０の剰余算で「秒」の部分。
    _songPlayTimeLabel.text=[NSString stringWithFormat:@"%d:%02d",minute,sec]; //02で二桁で表示

//    int lastMinute = (current - _duration) / 60; //式を逆にしてマイナスを表示
//    int lastSec = abs((current - _duration) % 60);
//    _songLastTimeLabel.text=[NSString stringWithFormat:@"%d:%02d",lastMinute,lastSec];

    _circularSlider.currentValue = _musicPlayer.currentPlaybackTime;
}

-(void)timeDidChange:(EFCircularSlider *)slider {
    _musicPlayer.currentPlaybackTime = _circularSlider.currentValue;
}

@end
