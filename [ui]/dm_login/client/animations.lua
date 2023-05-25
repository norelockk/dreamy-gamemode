local rendering = false
local animations = {}
local animations_index = 0

local function renderAnimations()
  local now = getTickCount()

  for index, animation in ipairs(animations) do
    animation.onChange(interpolateBetween(animation.from, 0, 0, animation.to, 0, 0, (now - animation.start) / animation.duration, animation.easing))

    if now >= animation.start + animation.duration then
      table.remove(animations, index)

      if type(animation.onEnd) == 'function' then
        animation.onEnd()
      end
    end
  end

  if #animations == 0 then
    rendering = false
    removeEventHandler('onClientRender', root, renderAnimations)
  end
end

function createAnimation(from, to, easing, duration, onChange, onEnd)
  if #animations == 0 and not rendering then 
		addEventHandler('onClientRender', root, renderAnimations)
		rendering = true
	end

  animations_index = animations_index + 1

  table.insert(animations, {
    id = animations_index,
    to = to,
    from = from,
    start = getTickCount(),
    onEnd = onEnd,
    easing = easing,
    duration = duration,
    onChange = onChange
  })

  return animations_index
end

function finishAnimation(anim) 
  for _, animation in ipairs(animations) do
    if animation.id == anim then
      animation.onChange(animation.to)

      if animation.onEnd and type(animation.onEnd) == 'function' then
        animation.onEnd()
      end

      animation.start = 0

      return true
    end
  end
end

function deleteAnimation(anim)
  for index, animation in ipairs(animations) do
    if animation.id == animation then
      table.remove(animations, index)
      break
    end
  end
end