//
//  FontAwesome.swift
//  Swift-Font-Awesome
//  from http://fontawesome.io/  and version 4.3.0
//
//  Created by longhao on 15/7/7.
//  Copyright (c) 2015年 longhao. All rights reserved.
//
//

import UIKit

let kFontAwesome = "fontawesome"

internal var align: FaTextAlignment?

protocol FaProtocol {
    var faTextAlignment: FaTextAlignment? { get set }
}

public class FontAwesome {
    class var sharedManager : FontAwesome {
        struct Static {
            static let sharedInstance : FontAwesome = FontAwesome()
        }
        
        return Static.sharedInstance
    }
    
    var token: dispatch_once_t = 0
    
    func registerFont() {
        dispatch_once(&token) {
            let fontURL = NSBundle.mainBundle().URLForResource(kFontAwesome, withExtension: "ttf")!
            let inData: NSData = NSData(contentsOfURL: fontURL)!
            let provider: CGDataProviderRef = CGDataProviderCreateWithCFData(inData)
            let font: CGFontRef = CGFontCreateWithDataProvider(provider)
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                println("Failed to register font, error: \(error)")
            }
        }
    }
    
}


public enum FaType: Int{
    var font: UIFont {
        return fontByType(self)
    }
    private func fontByType(type: FaType) -> UIFont {
        switch type {
        case .LG:
            return UIFont(name: kFontAwesome, size: 21.0)!
        case .X1:
            return UIFont(name: kFontAwesome, size: 16.0)!
        case .X2:
            return UIFont(name: kFontAwesome, size: 32.0)!
        case .X3:
            return UIFont(name: kFontAwesome, size: 48.0)!
        case .X4:
            return UIFont(name: kFontAwesome, size: 64.0)!
        case .X5:
            return UIFont(name: kFontAwesome, size: 80.0)!
        default:
            return UIFont(name: kFontAwesome, size: 16.0)!
        }
    }
    case LG, X1, X2, X3, X4, X5
}


public enum FaTextAlignment: Int{
    case Left = 0
    case Right = 1
}

public enum Fa: Int {
    //rawValue is add from xcode 6.1 http://stackoverflow.com/questions/26444107/enums-rawvalue-property-not-recognized
    var text: String? {
        println("rawValue = \(rawValue)")
        return FontContentArray[rawValue]
    }
    case Glass, Music, Search, EnvelopeO, Heart, Star, StarO, User, Film, ThLarge, Th, ThList, Check, Remove, Close, Times, SearchPlus, SearchMinus, PowerOff, Signal, Gear, Cog, TrashO, Home, FileO, ClockO, Road, Download, ArrowCircleODown, ArrowCircleOUp, Inbox, PlayCircleO, RotateRight, Repeat, Refresh, ListAlt, Lock, Flag, Headphones, VolumeOff, VolumeDown, VolumeUp, Qrcode, Barcode, Tag, Tags, Book, Bookmark, Print, Camera, Font, Bold, Italic, TextHeight, TextWidth, AlignLeft, AlignCenter, AlignRight, AlignJustify, List, Dedent, Outdent, Indent, VideoCamera, Photo, Image, PictureO, Pencil, MapMarker, Adjust, Tint, Edit, PencilSquareO, ShareSquareO, CheckSquareO, Arrows, StepBackward, FastBackward, Backward, Play, Pause, Stop, Forward, FastForward, StepForward, Eject, ChevronLeft, ChevronRight, PlusCircle, MinusCircle, TimesCircle, CheckCircle, QuestionCircle, InfoCircle, Crosshairs, TimesCircleO, CheckCircleO, Ban, ArrowLeft, ArrowRight, ArrowUp, ArrowDown, MailForward, Share, Expand, Compress, Plus, Minus, Asterisk, ExclamationCircle, Gift, Leaf, Fire, Eye, EyeSlash, Warning, ExclamationTriangle, Plane, Calendar, Random, Comment, Magnet, ChevronUp, ChevronDown, Retweet, ShoppingCart, Folder, FolderOpen, ArrowsV, ArrowsH, BarChartO, BarChart, TwitterSquare, FacebookSquare, CameraRetro, Key, Gears, Cogs, Comments, ThumbsOUp, ThumbsODown, StarHalf, HeartO, SignOut, LinkedinSquare, ThumbTack, ExternalLink, SignIn, Trophy, GithubSquare, Upload, LemonO, Phone, SquareO, BookmarkO, PhoneSquare, Twitter, FacebookF, Facebook, Github, Unlock, CreditCard, Rss, HddO, Bullhorn, Bell, Certificate, HandORight, HandOLeft, HandOUp, HandODown, ArrowCircleLeft, ArrowCircleRight, ArrowCircleUp, ArrowCircleDown, Globe, Wrench, Tasks, Filter, Briefcase, ArrowsAlt, Group, Users, Chain, Link, Cloud, Flask, Cut, Scissors, Copy, FilesO, Paperclip, Save, FloppyO, Square, Navicon, Reorder, Bars, ListUl, ListOl, Strikethrough, Underline, Table, Magic, Truck, Pinterest, PinterestSquare, GooglePlusSquare, GooglePlus, Money, CaretDown, CaretUp, CaretLeft, CaretRight, Columns, Unsorted, Sort, SortDown, SortDesc, SortUp, SortAsc, Envelope, Linkedin, RotateLeft, Undo, Legal, Gavel, Dashboard, Tachometer, CommentO, CommentsO, Flash, Bolt, Sitemap, Umbrella, Paste, Clipboard, LightbulbO, Exchange, CloudDownload, CloudUpload, UserMd, Stethoscope, Suitcase, BellO, Coffee, Cutlery, FileTextO, BuildingO, HospitalO, Ambulance, Medkit, FighterJet, Beer, HSquare, PlusSquare, AngleDoubleLeft, AngleDoubleRight, AngleDoubleUp, AngleDoubleDown, AngleLeft, AngleRight, AngleUp, AngleDown, Desktop, Laptop, Tablet, MobilePhone, Mobile, CircleO, QuoteLeft, QuoteRight, Spinner, Circle, MailReply, Reply, GithubAlt, FolderO, FolderOpenO, SmileO, FrownO, MehO, Gamepad, KeyboardO, FlagO, FlagCheckered, Terminal, Code, MailReplyAll, ReplyAll, StarHalfEmpty, StarHalfFull, StarHalfO, LocationArrow, Crop, CodeFork, Unlink, ChainBroken, Question, Info, Exclamation, Superscript, Subscript, Eraser, PuzzlePiece, Microphone, MicrophoneSlash, Shield, CalendarO, FireExtinguisher, Rocket, Maxcdn, ChevronCircleLeft, ChevronCircleRight, ChevronCircleUp, ChevronCircleDown, Html5, Css3, Anchor, UnlockAlt, Bullseye, EllipsisH, EllipsisV, RssSquare, PlayCircle, Ticket, MinusSquare, MinusSquareO, LevelUp, LevelDown, CheckSquare, PencilSquare, ExternalLinkSquare, ShareSquare, Compass, ToggleDown, CaretSquareODown, ToggleUp, CaretSquareOUp, ToggleRight, CaretSquareORight, Euro, Eur, Gbp, Dollar, Usd, Rupee, Inr, Cny, Rmb, Yen, Jpy, Ruble, Rouble, Rub, Won, Krw, Bitcoin, Btc, File, FileText, SortAlphaAsc, SortAlphaDesc, SortAmountAsc, SortAmountDesc, SortNumericAsc, SortNumericDesc, ThumbsUp, ThumbsDown, YoutubeSquare, Youtube, Xing, XingSquare, YoutubePlay, Dropbox, StackOverflow, Instagram, Flickr, Adn, Bitbucket, BitbucketSquare, Tumblr, TumblrSquare, LongArrowDown, LongArrowUp, LongArrowLeft, LongArrowRight, Apple, Windows, Android, Linux, Dribbble, Skype, Foursquare, Trello, Female, Male, Gittip, Gratipay, SunO, MoonO, Archive, Bug, Vk, Weibo, Renren, Pagelines, StackExchange, ArrowCircleORight, ArrowCircleOLeft, ToggleLeft, CaretSquareOLeft, DotCircleO, Wheelchair, VimeoSquare, TurkishLira, Try, PlusSquareO, SpaceShuttle, Slack, EnvelopeSquare, Wordpress, Openid, Institution, Bank, University, MortarBoard, GraduationCap, Yahoo, Google, Reddit, RedditSquare, StumbleuponCircle, Stumbleupon, Delicious, Digg, PiedPiper, PiedPiperAlt, Drupal, Joomla, Language, Fax, Building, Child, Paw, Spoon, Cube, Cubes, Behance, BehanceSquare, Steam, SteamSquare, Recycle, Automobile, Car, Cab, Taxi, Tree, Spotify, Deviantart, Soundcloud, Database, FilePdfO, FileWordO, FileExcelO, FilePowerpointO, FilePhotoO, FilePictureO, FileImageO, FileZipO, FileArchiveO, FileSoundO, FileAudioO, FileMovieO, FileVideoO, FileCodeO, Vine, Codepen, Jsfiddle, LifeBouy, LifeBuoy, LifeSaver, Support, LifeRing, CircleONotch, Ra, Rebel, Ge, Empire, GitSquare, Git, HackerNews, TencentWeibo, Qq, Wechat, Weixin, Send, PaperPlane, SendO, PaperPlaneO, History, Genderless, CircleThin, Header, Paragraph, Sliders, ShareAlt, ShareAltSquare, Bomb, SoccerBallO, FutbolO, Tty, Binoculars, Plug, Slideshare, Twitch, Yelp, NewspaperO, Wifi, Calculator, Paypal, GoogleWallet, CcVisa, CcMastercard, CcDiscover, CcAmex, CcPaypal, CcStripe, BellSlash, BellSlashO, Trash, Copyright, At, Eyedropper, PaintBrush, BirthdayCake, AreaChart, PieChart, LineChart, Lastfm, LastfmSquare, ToggleOff, ToggleOn, Bicycle, Bus, Ioxhost, Angellist, Cc, Shekel, Sheqel, Ils, Meanpath, Buysellads, Connectdevelop, Dashcube, Forumbee, Leanpub, Sellsy, Shirtsinbulk, Simplybuilt, Skyatlas, CartPlus, CartArrowDown, Diamond, Ship, UserSecret, Motorcycle, StreetView, Heartbeat, Venus, Mars, Mercury, Transgender, TransgenderAlt, VenusDouble, MarsDouble, VenusMars, MarsStroke, MarsStrokeV, MarsStrokeH, Neuter, FacebookOfficial, PinterestP, Whatsapp, Server, UserPlus, UserTimes, Hotel, Bed, Viacoin, Train, Subway, Medium
}

public let FontContentArray = ["\u{f000}", "\u{f001}", "\u{f002}", "\u{f003}", "\u{f004}", "\u{f005}", "\u{f006}", "\u{f007}", "\u{f008}", "\u{f009}", "\u{f00a}", "\u{f00b}", "\u{f00c}", "\u{f00d}", "\u{f00d}", "\u{f00d}", "\u{f00e}", "\u{f010}", "\u{f011}", "\u{f012}", "\u{f013}", "\u{f013}", "\u{f014}", "\u{f015}", "\u{f016}", "\u{f017}", "\u{f018}", "\u{f019}", "\u{f01a}", "\u{f01b}", "\u{f01c}", "\u{f01d}", "\u{f01e}", "\u{f01e}", "\u{f021}", "\u{f022}", "\u{f023}", "\u{f024}", "\u{f025}", "\u{f026}", "\u{f027}", "\u{f028}", "\u{f029}", "\u{f02a}", "\u{f02b}", "\u{f02c}", "\u{f02d}", "\u{f02e}", "\u{f02f}", "\u{f030}", "\u{f031}", "\u{f032}", "\u{f033}", "\u{f034}", "\u{f035}", "\u{f036}", "\u{f037}", "\u{f038}", "\u{f039}", "\u{f03a}", "\u{f03b}", "\u{f03b}", "\u{f03c}", "\u{f03d}", "\u{f03e}", "\u{f03e}", "\u{f03e}", "\u{f040}", "\u{f041}", "\u{f042}", "\u{f043}", "\u{f044}", "\u{f044}", "\u{f045}", "\u{f046}", "\u{f047}", "\u{f048}", "\u{f049}", "\u{f04a}", "\u{f04b}", "\u{f04c}", "\u{f04d}", "\u{f04e}", "\u{f050}", "\u{f051}", "\u{f052}", "\u{f053}", "\u{f054}", "\u{f055}", "\u{f056}", "\u{f057}", "\u{f058}", "\u{f059}", "\u{f05a}", "\u{f05b}", "\u{f05c}", "\u{f05d}", "\u{f05e}", "\u{f060}", "\u{f061}", "\u{f062}", "\u{f063}", "\u{f064}", "\u{f064}", "\u{f065}", "\u{f066}", "\u{f067}", "\u{f068}", "\u{f069}", "\u{f06a}", "\u{f06b}", "\u{f06c}", "\u{f06d}", "\u{f06e}", "\u{f070}", "\u{f071}", "\u{f071}", "\u{f072}", "\u{f073}", "\u{f074}", "\u{f075}", "\u{f076}", "\u{f077}", "\u{f078}", "\u{f079}", "\u{f07a}", "\u{f07b}", "\u{f07c}", "\u{f07d}", "\u{f07e}", "\u{f080}", "\u{f080}", "\u{f081}", "\u{f082}", "\u{f083}", "\u{f084}", "\u{f085}", "\u{f085}", "\u{f086}", "\u{f087}", "\u{f088}", "\u{f089}", "\u{f08a}", "\u{f08b}", "\u{f08c}", "\u{f08d}", "\u{f08e}", "\u{f090}", "\u{f091}", "\u{f092}", "\u{f093}", "\u{f094}", "\u{f095}", "\u{f096}", "\u{f097}", "\u{f098}", "\u{f099}", "\u{f09a}", "\u{f09a}", "\u{f09b}", "\u{f09c}", "\u{f09d}", "\u{f09e}", "\u{f0a0}", "\u{f0a1}", "\u{f0f3}", "\u{f0a3}", "\u{f0a4}", "\u{f0a5}", "\u{f0a6}", "\u{f0a7}", "\u{f0a8}", "\u{f0a9}", "\u{f0aa}", "\u{f0ab}", "\u{f0ac}", "\u{f0ad}", "\u{f0ae}", "\u{f0b0}", "\u{f0b1}", "\u{f0b2}", "\u{f0c0}", "\u{f0c0}", "\u{f0c1}", "\u{f0c1}", "\u{f0c2}", "\u{f0c3}", "\u{f0c4}", "\u{f0c4}", "\u{f0c5}", "\u{f0c5}", "\u{f0c6}", "\u{f0c7}", "\u{f0c7}", "\u{f0c8}", "\u{f0c9}", "\u{f0c9}", "\u{f0c9}", "\u{f0ca}", "\u{f0cb}", "\u{f0cc}", "\u{f0cd}", "\u{f0ce}", "\u{f0d0}", "\u{f0d1}", "\u{f0d2}", "\u{f0d3}", "\u{f0d4}", "\u{f0d5}", "\u{f0d6}", "\u{f0d7}", "\u{f0d8}", "\u{f0d9}", "\u{f0da}", "\u{f0db}", "\u{f0dc}", "\u{f0dc}", "\u{f0dd}", "\u{f0dd}", "\u{f0de}", "\u{f0de}", "\u{f0e0}", "\u{f0e1}", "\u{f0e2}", "\u{f0e2}", "\u{f0e3}", "\u{f0e3}", "\u{f0e4}", "\u{f0e4}", "\u{f0e5}", "\u{f0e6}", "\u{f0e7}", "\u{f0e7}", "\u{f0e8}", "\u{f0e9}", "\u{f0ea}", "\u{f0ea}", "\u{f0eb}", "\u{f0ec}", "\u{f0ed}", "\u{f0ee}", "\u{f0f0}", "\u{f0f1}", "\u{f0f2}", "\u{f0a2}", "\u{f0f4}", "\u{f0f5}", "\u{f0f6}", "\u{f0f7}", "\u{f0f8}", "\u{f0f9}", "\u{f0fa}", "\u{f0fb}", "\u{f0fc}", "\u{f0fd}", "\u{f0fe}", "\u{f100}", "\u{f101}", "\u{f102}", "\u{f103}", "\u{f104}", "\u{f105}", "\u{f106}", "\u{f107}", "\u{f108}", "\u{f109}", "\u{f10a}", "\u{f10b}", "\u{f10b}", "\u{f10c}", "\u{f10d}", "\u{f10e}", "\u{f110}", "\u{f111}", "\u{f112}", "\u{f112}", "\u{f113}", "\u{f114}", "\u{f115}", "\u{f118}", "\u{f119}", "\u{f11a}", "\u{f11b}", "\u{f11c}", "\u{f11d}", "\u{f11e}", "\u{f120}", "\u{f121}", "\u{f122}", "\u{f122}", "\u{f123}", "\u{f123}", "\u{f123}", "\u{f124}", "\u{f125}", "\u{f126}", "\u{f127}", "\u{f127}", "\u{f128}", "\u{f129}", "\u{f12a}", "\u{f12b}", "\u{f12c}", "\u{f12d}", "\u{f12e}", "\u{f130}", "\u{f131}", "\u{f132}", "\u{f133}", "\u{f134}", "\u{f135}", "\u{f136}", "\u{f137}", "\u{f138}", "\u{f139}", "\u{f13a}", "\u{f13b}", "\u{f13c}", "\u{f13d}", "\u{f13e}", "\u{f140}", "\u{f141}", "\u{f142}", "\u{f143}", "\u{f144}", "\u{f145}", "\u{f146}", "\u{f147}", "\u{f148}", "\u{f149}", "\u{f14a}", "\u{f14b}", "\u{f14c}", "\u{f14d}", "\u{f14e}", "\u{f150}", "\u{f150}", "\u{f151}", "\u{f151}", "\u{f152}", "\u{f152}", "\u{f153}", "\u{f153}", "\u{f154}", "\u{f155}", "\u{f155}", "\u{f156}", "\u{f156}", "\u{f157}", "\u{f157}", "\u{f157}", "\u{f157}", "\u{f158}", "\u{f158}", "\u{f158}", "\u{f159}", "\u{f159}", "\u{f15a}", "\u{f15a}", "\u{f15b}", "\u{f15c}", "\u{f15d}", "\u{f15e}", "\u{f160}", "\u{f161}", "\u{f162}", "\u{f163}", "\u{f164}", "\u{f165}", "\u{f166}", "\u{f167}", "\u{f168}", "\u{f169}", "\u{f16a}", "\u{f16b}", "\u{f16c}", "\u{f16d}", "\u{f16e}", "\u{f170}", "\u{f171}", "\u{f172}", "\u{f173}", "\u{f174}", "\u{f175}", "\u{f176}", "\u{f177}", "\u{f178}", "\u{f179}", "\u{f17a}", "\u{f17b}", "\u{f17c}", "\u{f17d}", "\u{f17e}", "\u{f180}", "\u{f181}", "\u{f182}", "\u{f183}", "\u{f184}", "\u{f184}", "\u{f185}", "\u{f186}", "\u{f187}", "\u{f188}", "\u{f189}", "\u{f18a}", "\u{f18b}", "\u{f18c}", "\u{f18d}", "\u{f18e}", "\u{f190}", "\u{f191}", "\u{f191}", "\u{f192}", "\u{f193}", "\u{f194}", "\u{f195}", "\u{f195}", "\u{f196}", "\u{f197}", "\u{f198}", "\u{f199}", "\u{f19a}", "\u{f19b}", "\u{f19c}", "\u{f19c}", "\u{f19c}", "\u{f19d}", "\u{f19d}", "\u{f19e}", "\u{f1a0}", "\u{f1a1}", "\u{f1a2}", "\u{f1a3}", "\u{f1a4}", "\u{f1a5}", "\u{f1a6}", "\u{f1a7}", "\u{f1a8}", "\u{f1a9}", "\u{f1aa}", "\u{f1ab}", "\u{f1ac}", "\u{f1ad}", "\u{f1ae}", "\u{f1b0}", "\u{f1b1}", "\u{f1b2}", "\u{f1b3}", "\u{f1b4}", "\u{f1b5}", "\u{f1b6}", "\u{f1b7}", "\u{f1b8}", "\u{f1b9}", "\u{f1b9}", "\u{f1ba}", "\u{f1ba}", "\u{f1bb}", "\u{f1bc}", "\u{f1bd}", "\u{f1be}", "\u{f1c0}", "\u{f1c1}", "\u{f1c2}", "\u{f1c3}", "\u{f1c4}", "\u{f1c5}", "\u{f1c5}", "\u{f1c5}", "\u{f1c6}", "\u{f1c6}", "\u{f1c7}", "\u{f1c7}", "\u{f1c8}", "\u{f1c8}", "\u{f1c9}", "\u{f1ca}", "\u{f1cb}", "\u{f1cc}", "\u{f1cd}", "\u{f1cd}", "\u{f1cd}", "\u{f1cd}", "\u{f1cd}", "\u{f1ce}", "\u{f1d0}", "\u{f1d0}", "\u{f1d1}", "\u{f1d1}", "\u{f1d2}", "\u{f1d3}", "\u{f1d4}", "\u{f1d5}", "\u{f1d6}", "\u{f1d7}", "\u{f1d7}", "\u{f1d8}", "\u{f1d8}", "\u{f1d9}", "\u{f1d9}", "\u{f1da}", "\u{f1db}", "\u{f1db}", "\u{f1dc}", "\u{f1dd}", "\u{f1de}", "\u{f1e0}", "\u{f1e1}", "\u{f1e2}", "\u{f1e3}", "\u{f1e3}", "\u{f1e4}", "\u{f1e5}", "\u{f1e6}", "\u{f1e7}", "\u{f1e8}", "\u{f1e9}", "\u{f1ea}", "\u{f1eb}", "\u{f1ec}", "\u{f1ed}", "\u{f1ee}", "\u{f1f0}", "\u{f1f1}", "\u{f1f2}", "\u{f1f3}", "\u{f1f4}", "\u{f1f5}", "\u{f1f6}", "\u{f1f7}", "\u{f1f8}", "\u{f1f9}", "\u{f1fa}", "\u{f1fb}", "\u{f1fc}", "\u{f1fd}", "\u{f1fe}", "\u{f200}", "\u{f201}", "\u{f202}", "\u{f203}", "\u{f204}", "\u{f205}", "\u{f206}", "\u{f207}", "\u{f208}", "\u{f209}", "\u{f20a}", "\u{f20b}", "\u{f20b}", "\u{f20b}", "\u{f20c}", "\u{f20d}", "\u{f20e}", "\u{f210}", "\u{f211}", "\u{f212}", "\u{f213}", "\u{f214}", "\u{f215}", "\u{f216}", "\u{f217}", "\u{f218}", "\u{f219}", "\u{f21a}", "\u{f21b}", "\u{f21c}", "\u{f21d}", "\u{f21e}", "\u{f221}", "\u{f222}", "\u{f223}", "\u{f224}", "\u{f225}", "\u{f226}", "\u{f227}", "\u{f228}", "\u{f229}", "\u{f22a}", "\u{f22b}", "\u{f22c}", "\u{f230}", "\u{f231}", "\u{f232}", "\u{f233}", "\u{f234}", "\u{f235}", "\u{f236}", "\u{f236}", "\u{f237}", "\u{f238}", "\u{f239}", "\u{f23a}"]
