local sound = false
local animations = {}

function playLoginMusic()
  if not sound and not isElement(sound) then
    if fileExists('assets/sounds/isometric.mp3') then
      sound = playSound('assets/sounds/isometric.mp3', true)

      setSoundSpeed(sound, 0.95)
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