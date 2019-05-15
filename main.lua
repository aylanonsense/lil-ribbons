-- Game constants
local GAME_WIDTH = 192
local GAME_HEIGHT = 192

-- Game variables
local scissorSpawnTimer
local firstRibbon
local ribbons
local scissors

-- Assets
local scissorsImage

-- Initializes the game
function love.load()
  -- Set filters
  love.graphics.setLineStyle('rough')
  love.graphics.setDefaultFilter('nearest', 'nearest')
  -- Load assets
  scissorsImage = love.graphics.newImage('img/scissors.png')
  -- Reset the game
  resetGame()
end

-- Updates the game state
function love.update(dt)
  local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()

  -- Spawn scissors periodically
  if firstRibbon.next then
    scissorSpawnTimer = scissorSpawnTimer - dt
    if scissorSpawnTimer <= 0.00 then
      scissorSpawnTimer = math.max(0.5, 3.00 - #scissors / 10)
      createScissors()
    end
  end

  -- Update the scissors
  for _, scissor in ipairs(scissors) do
    -- Move the scissors
    scissor.x = scissor.x + scissor.speed * math.cos(scissor.rotation) * dt
    scissor.y = scissor.y + scissor.speed * math.sin(scissor.rotation) * dt
    scissor.animationTimer = (scissor.animationTimer + dt) % 0.50
    -- Wrap the scissors around the edge of the screen
    if scissor.x < -10 then
      scissor.x = GAME_WIDTH + 10
    elseif scissor.x > GAME_WIDTH + 10 then
      scissor.x = -10
    end
    if scissor.y < -10 then
      scissor.y = GAME_HEIGHT + 10
    elseif scissor.y > GAME_HEIGHT + 10 then
      scissor.y = -10
    end
  end

  -- Update the ribbons
  for _, ribbon in ipairs(ribbons) do
    -- Move towards the cursor
    if ribbon.followsCursor and mouseX > 0 and mouseX < GAME_WIDTH and mouseY > 0 and mouseY < GAME_HEIGHT then
      moveTowardsPoint(ribbon, mouseX, mouseY, dt)
    end
    -- Move towards the previus ribbon point
    if ribbon.prev then
      moveTowardsPoint(ribbon, ribbon.prev.x, ribbon.prev.y, dt)
    end
    -- Apply the ribbon's velocity
    ribbon.vx = ribbon.vx * 0.6
    ribbon.vy = ribbon.vy * 0.6
    ribbon.x = ribbon.x + ribbon.vx
    ribbon.y = ribbon.y + ribbon.vy
    -- Keep each ribbon point on screen
    ribbon.x = math.min(math.max(2, ribbon.x), GAME_WIDTH - 2)
    ribbon.y = math.min(math.max(2, ribbon.y), GAME_HEIGHT - 2)
    -- Check for cuts
    if ribbon.next then
      for _, scissor in ipairs(scissors) do
        local dx = scissor.x - ribbon.x
        local dy = scissor.y - ribbon.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < 3 then
          ribbon.next.prev = nil
          ribbon.next = nil
          break
        end
      end
    end
  end
end

-- Renders the game
function love.draw()
  -- Clear the screen
  love.graphics.clear(253 / 255, 217 / 255, 37 / 255)

  -- Draw ribbons
  love.graphics.setColor(12 / 255, 132 / 255, 208 / 255)
  for _, ribbon in ipairs(ribbons) do
    if ribbon.next then
      love.graphics.line(ribbon.x, ribbon.y, ribbon.next.x, ribbon.next.y)
    end
  end

  -- Draw scissors
  love.graphics.setColor(1, 1, 1)
  for _, scissor in ipairs(scissors) do
    local sprite
    if scissor.animationTimer < 0.25 then
      sprite = 1
    elseif scissor.animationTimer < 0.35 then
      sprite = 2
    else
      sprite = 3
    end
    drawSprite(scissorsImage, 16, 11, sprite, scissor.x - 9, scissor.y - 6, false, false, scissor.rotation)
  end
end

-- CLick to reset the game ocne it's over
function love.mousepressed()
  if not firstRibbon.next then
    resetGame()
  end
end

-- Draws a sprite from a sprite sheet, spriteNum=1 is the upper-leftmost sprite
function drawSprite(spriteSheetImage, spriteWidth, spriteHeight, sprite, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  local numColumns = math.floor(width / spriteWidth)
  local col, row = (sprite - 1) % numColumns, math.floor((sprite - 1) / numColumns)
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, width, height),
    x + spriteWidth / 2, y + spriteHeight / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    spriteWidth / 2, spriteHeight / 2)
end

-- Ribbons are made of multiple points, this function creates one point of a ribbon
function createRibbon(x, y, followsCursor)
  local ribbon = {
    x = x,
    y = y,
    vx = 0,
    vy = 0,
    followsCursor = followsCursor
  }
  table.insert(ribbons, ribbon)
  return ribbon
end

-- Creates a pair of scissors
function createScissors()
  local x = -10
  local y = -10
  if math.random() < 0.5 then
    x = math.random(0, GAME_WIDTH)
  else
    y = math.random(0, GAME_HEIGHT)
  end
  local scissor = {
    x = x,
    y = y,
    rotation = math.random(2 * math.pi),
    speed = math.random(10, 60),
    animationTimer = 0.00
  }
  table.insert(scissors, scissor)
  return scissor
end

-- Move a ribbon towards a point in space
function moveTowardsPoint(ribbon, x, y, dt)
  local dx = x - ribbon.x
  local dy = y - ribbon.y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist > 4 then
    local movement = math.min(10, dist - 4)
    ribbon.x = ribbon.x + movement * (dx / dist)
    ribbon.y = ribbon.y + movement * (dy / dist)
    ribbon.vx = ribbon.vx + movement * (dx / dist) * dt
    ribbon.vy = ribbon.vy + movement * (dy / dist) * dt
  end
end

-- Resets the game
function resetGame()
  scissorSpawnTimer = 2.00

  -- Create ribbons
  ribbons = {}
  local prevRibbon = nil
  for i = 1, 40 do
    local ribbon = createRibbon(GAME_WIDTH / 2, GAME_HEIGHT / 2, i == 1)
    if prevRibbon then
      ribbon.prev = prevRibbon
      prevRibbon.next = ribbon
    end
    prevRibbon = ribbon
  end
  firstRibbon = ribbons[1]

  -- Create an empty array to hold the scissors
  scissors = {}
end
