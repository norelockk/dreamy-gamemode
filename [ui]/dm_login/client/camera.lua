local DEFAULT_CAMERA_TIME = 40 * 1000

local cameras = {
  {
    time = DEFAULT_CAMERA_TIME,
    start = {
      position = Vector3(2003.5523681641, -1449.8708496094, 179.3498992919),
      rotation = Vector3(0, 0, 70.91839599609)
    },
    finish = {
      position = Vector3(1223.9947509766, -1863.9333496094, 157.92959594727),
      rotation = Vector3(-10, 0, 340.86511230469)
    }
  },
  {
    time = DEFAULT_CAMERA_TIME,
    start = {
      position = Vector3(-271.17001342773, 231.1381072998, 53.978298187256),
      rotation = Vector3(351.9677734375, 0, 214.92309570313)
    },
    finish = {
      position = Vector3(396.51119995117, -450.8623046875, 106.87419891357),
      rotation = Vector3(347.03881835938, 0, 37.859130859375)
    }
  },
  {
    time = DEFAULT_CAMERA_TIME,
    start = {
      position = Vector3(2021.6086425781, 1865.3211669922, 97.476699829102),
      rotation = Vector3(348.50634765625, 0, 213.48217773438)
    },
    finish = {
      position = Vector3(2480.784912109, 917.9423828125, 110.85289764404),
      rotation = Vector3(348.88549804688, 0, 46.849670410156)
    }
  }
}

local selected = 1
local changing = false
local startTick = 0
local fadeAlpha = 0

local screen = Vector2(guiGetScreenSize())

local function renderCameraMovement()
  local now = getTickCount()

  dxDrawRectangle(0, 0, screen.x, screen.y, tocolor(12, 12, 12, fadeAlpha))

  local camera = getCamera()
  local cameraData = cameras[selected]
  local progress = math.min(1, (now - startTick) / cameraData.time)

  local cx, cy, cz = getElementPosition(camera)
  local crx, cry, crz = getElementRotation(camera)

  local x, y, z = interpolateBetween(cameraData.start.position.x, cameraData.start.position.y, cameraData.start.position.z, cameraData.finish.position.x, cameraData.finish.position.y, cameraData.finish.position.z, progress, 'Linear')
  local rx, ry, rz = interpolateBetween(cameraData.start.rotation.x, cameraData.start.rotation.y, cameraData.start.rotation.z, cameraData.finish.rotation.x, cameraData.finish.rotation.y, cameraData.finish.rotation.z, progress, 'Linear')
  
  setElementPosition(camera, x, y, z)
  setElementRotation(camera, rx, ry, rz)

  if progress > 0.85 then
    changeCamera()
  end
end

function startCameraMovement()
  startTick = getTickCount()
  selected = math.random(1, #cameras)
  fadeAlpha = 0

  addEventHandler('onClientPreRender', root, renderCameraMovement)
  setFarClipDistance(2000)
end

function endCameraMovement()
  removeEventHandler('onClientPreRender', root, renderCameraMovement)
  resetFarClipDistance()
end

function changeCamera()
  if changing then return end 
  changing = true 
	
  createAnimation(0, 255, 'InOutQuad', 3000, function(progress)
    fadeAlpha = progress
  end)
	
  setTimer(function()
    if getFarClipDistance() ~= 2000 then return end 
    changing = false 
		
    startTick = getTickCount()
    selected = selected+1 
    if selected > #cameras then 
      selected = 1 
    end
		
    createAnimation(255, 0, 'InOutQuad', 3000, function(progress)
      fadeAlpha = progress
    end)
  end, 3000, 1)
end