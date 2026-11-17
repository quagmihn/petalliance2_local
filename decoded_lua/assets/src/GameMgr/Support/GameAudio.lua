local GameAudio = {}

GameAudio.DEFAULT_MUSIC_VOLUME = 35
GameAudio.DEFAULT_SOUND_VOLUME = 100
GameAudio.IOS_USE_SOUND = false

GameAudio.DEFAULT_BUTTON_SOUND = ""
GameAudio.DEFAULT_BATTLE_MUSIC = ""

local musicIsOpen = true
local soundIsOpen = true

local exStr = ""
local curMusic = ""
local curMusicHandle = nil

local SoundEffectInfoConfig = nil --音效配置表初始化
local UISoundeEffect = {} --ui音效列表
local BattleSoundEffect = {} -- 战斗音效列表
local GameMusic = {} --游戏音乐列表
local SoundTypeEnum = {
    UI = "UI",
    BATTLE = "战斗"
}

function GameAudio.Init()
	print("GameAudio初始化")
	
    musicIsOpen = true--UserSettings.get("Music", 4)
    if musicIsOpen==nil then
        musicIsOpen = true
    end
    soundIsOpen = true--UserSettings.get("Sound", 4)
    if soundIsOpen==nil then
        soundIsOpen = true
    end
	
    local musicVol = UserSettings.get("musicVol", 4) or GameAudio.DEFAULT_MUSIC_VOLUME
    GameAudio.setMusicVolume(musicVol)
    local soundVol = UserSettings.get("soundVol", 4) or GameAudio.DEFAULT_SOUND_VOLUME
    GameAudio.setSoundsVolume(soundVol)
	
    curMusic = ""
    
    exStr = ".m4a"
    if device.platform=="windows" then
        exStr = ".mp3"
    end
    
    if SoundEffectInfoConfig==nil then
        SoundEffectInfoConfig = require("src.DatReader.SoundEffectInfoConfig")
        SoundEffectInfoConfig.init()
        
        for var=1, SoundEffectInfoConfig.getEntryCount() do
            local id = SoundEffectInfoConfig.getEntryID(var)
            local data = SoundEffectInfoConfig.readEntryByID(id)
            if data.soundType == "sound" then
                if data.loadBefore == SoundTypeEnum.UI then
                    UISoundeEffect[data.type] = data.path..exStr
                    if device.platform == "windows" or device.platform == "mac" then
                        --audio.preloadSound(UISoundeEffect[data.type])
                    end
                else
                    --print("data.type......."..data.type,data.path)
                    BattleSoundEffect[data.type] = data.path..exStr
                end
                
            else
                GameMusic[data.type] = data.path..exStr           
            end
        end
    end
    
    GameAudio.DEFAULT_BUTTON_SOUND = "Music/sound/ui_select"..exStr
    GameAudio.DEFAULT_BATTLE_MUSIC = "Music/bgm/bg_battle4"..exStr
end

function GameAudio.getFileTypeString()
    return exStr
end

function GameAudio.setMusicOpen(boolOpen)
    if musicIsOpen==boolOpen then
    	return
    end
	musicIsOpen = boolOpen
    if not boolOpen then
        if device.platform=="ios" and GameAudio.IOS_USE_SOUND then
            audio.stopAllSounds()
        else
            audio.stopMusic(true)
        end
    else
        if curMusic~="" then
            if device.platform=="ios" and GameAudio.IOS_USE_SOUND then
                curMusicHandle = audio.playSound(curMusic, true)
            else
                audio.preloadMusic(curMusic)
                audio.playMusic(curMusic, true)
            end
        end
    end
end

function GameAudio.getMusicOpen()
    return musicIsOpen
end

function GameAudio.setSoundOpen(boolOpen)
    soundIsOpen = boolOpen
end

function GameAudio.getSoundOpen()
    return soundIsOpen
end

function GameAudio.playMusic(filename)
    if curMusic==filename then
    	return
    end
    if musicIsOpen then
        if device.platform=="ios" and GameAudio.IOS_USE_SOUND then
            if curMusicHandle then
                audio.stopSound(curMusicHandle)
            end
            curMusicHandle = audio.playSound(filename, true)
        else
            audio.preloadMusic(filename)
            audio.playMusic(filename, true)
            print("audio.playMusic(filename, true)"..filename) 
        end
	end
	curMusic = filename
end

function GameAudio.pauseMusic()
    audio.pauseMusic()
end

function GameAudio.resumeMusic()
    audio.resumeMusic()
end

function GameAudio.playMusic2(musicKey)
    print("GameAudio.playMusic2:"..musicKey)
    local filename = GameMusic[musicKey]
    if filename == nil then 
        return
    end
    
    if curMusic==filename then
        return
    end
    
    if musicIsOpen then
        if device.platform=="ios" and GameAudio.IOS_USE_SOUND then
            if curMusicHandle then
                audio.stopSound(curMusicHandle)
            end
            curMusicHandle = audio.playSound(filename, true)
        else
            audio.preloadMusic(filename)
            audio.playMusic(filename, true)
            print("audio.playMusic(filename, true)"..filename) 
        end
    end
    curMusic = filename
end

function GameAudio.stopMusic()
    audio.stopMusic(true)
end

function GameAudio.playSound(filename)
    if soundIsOpen then
        return audio.playSound(filename, false)
    end
end

function GameAudio.setMusicVolume(val)
    audio.setMusicVolume(val/100)
    if val<=0 then
        GameAudio.setMusicOpen(false)
    else
        GameAudio.setMusicOpen(true)
    end
end

function GameAudio.setSoundsVolume(val)
    audio.setSoundsVolume(val/100)
    if val<=0 then
        GameAudio.setSoundOpen(false)
    else
        GameAudio.setSoundOpen(true)
    end
end

function GameAudio.playUISound(soundKey,isLoop)
    if soundIsOpen then
        if soundKey~="" then
            isLoop = isLoop or false
            return audio.playSound(UISoundeEffect[soundKey], isLoop)
        end
    end
end

function GameAudio.playSoundById(id,isLoop)
    local data = SoundEffectInfoConfig.readEntryByID(id) 
    if data~=nil then   
        isLoop = isLoop or false 
        audio.playSound(data.path..exStr,isLoop)
    end
end

function GameAudio.playMusicById(id)
    local data = SoundEffectInfoConfig.readEntryByID(id)
    if data~=nil then
        GameAudio.playMusic(data.path..exStr)
    end
end

function GameAudio.preLoadBattleSound()
    for k,v in pairs(BattleSoundEffect) do
        audio.preloadSound(v)
    end
end

function GameAudio.unLoadBattleSound()
    for k,v in pairs(BattleSoundEffect) do
        audio.unloadSound(v.path)
    end    
end

function GameAudio.playBattleSound(soundKey)
    if soundIsOpen then
        audio.playSound(BattleSoundEffect[soundKey], false)
    end    
end

return GameAudio