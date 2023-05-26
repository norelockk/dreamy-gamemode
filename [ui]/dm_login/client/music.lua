local sound = false
local filePath = 'assets/sounds/isometric.mp3'
local animations = {}

function playLoginMusic()
  if not sound and not isElement(sound) then
    if fileExists(filePath) then
      sound = playSound(filePath, true)

      setSoundSpeed(sound, 0.90)
    end
  end
end

function stopLoginMusic()
  if animations.sVolume then return end

  if sound and isElement(sound) then
    local currentVolume = getSoundVolume(sound)

    animations.sVolume = createAnimation(currentVolume, 0, 'Linear', 2000,
      function(volume)
        setSoundVolume(sound, volume)
      end,
      function()
        deleteAnimation(animations.sVolume)
        animations.sVolume = false

        stopSound(sound)
        sound = false
      end
    )
  end
end