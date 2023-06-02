-- settings
local SOUND_FADE_DURATION = 10 * 1000

-- variables
local sound = false
local filePath = 'assets/sounds/blacknite.mp3'
local animation = nil

function playLoginMusic()
  if animation then return end
  if not sound and not isElement(sound) then
    if fileExists(filePath) then
      sound = playSound(filePath, true)

      setSoundSpeed(sound, 0.97)
      setSoundVolume(sound, 0)
      setSoundPosition(sound, 56)

      animation = createAnimation(0, 1, 'Linear', SOUND_FADE_DURATION,
        function(volume)
          setSoundVolume(sound, volume)
        end,
        function()
          deleteAnimation(animation)
          animation = nil
        end
      )
    end
  end
end

function stopLoginMusic()
  if animation then return end
  if sound and isElement(sound) then
    local currentVolume = getSoundVolume(sound)

    animation = createAnimation(currentVolume, 0, 'Linear', SOUND_FADE_DURATION,
      function(volume)
        setSoundVolume(sound, volume)
      end,
      function()
        deleteAnimation(animation)
        animation = nil

        stopSound(sound)
        sound = false
      end
    )
  end
end

function getLoginMusicElement()
  return sound or false
end