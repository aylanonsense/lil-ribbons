-- Constants
local GAME_WIDTH = 200
local GAME_HEIGHT = 200
local RENDER_SCALE = 3

-- Game objects
local ribbons

-- Images
local scissorsImage

-- Initializes the game
function love.load()
  -- Load images
  carImage = loadImage('img/scissors.png')

  -- Create ribbons
  ribbons = {}
  local prevRibbon = nil
  for i = 1, 10 do
    local ribbon = createRibbon(50, 50 + 10 * i, i == 1)
    if prevRibbon then
      ribbon.prev = prevRibbon
      prevRibbon.next = ribbon
    end
    prevRibbon = ribbon
  end
end

-- Updates the game state
function love.update(dt)
  local mouseX = love.mouse.getX() / RENDER_SCALE
  local mouseY = love.mouse.getY() / RENDER_SCALE

  -- Update the ribbons
  for _, ribbon in ipairs(ribbons) do
    -- Move towards the cursor
    if ribbon.followsCursor then
      local dx = mouseX - ribbon.x
      local dy = mouseY - ribbon.y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist > 0 then
        ribbon.x = ribbon.x + math.min(15, dist) * (dx / dist)
        ribbon.y = ribbon.y + math.min(15, dist) * (dy / dist)
      end
    end
    -- Move towards the next point
    if ribbon.prev then
      local dx = ribbon.prev.x - ribbon.x
      local dy = ribbon.prev.y - ribbon.y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist > 10 then
        -- ribbon.vx = ribbon.vx + 2 * (dist - 2) * (dx / dist) * dt
        -- ribbon.vy = ribbon.vy + 2 * (dist - 2) * (dy / dist) * dt
        -- ribbon.prev.vx = ribbon.prev.vx - 2 * (dist - 2) * (dx / dist) * dt
        -- ribbon.prev.vy = ribbon.prev.vy - 2 * (dist - 2) * (dy / dist) * dt
        ribbon.x = ribbon.x + (dist - 10) * (dx / dist)
        ribbon.y = ribbon.y + (dist - 10) * (dy / dist)
        ribbon.vx = ribbon.vx + (dist - 10) * (dx / dist)
        ribbon.vy = ribbon.vy + (dist - 10) * (dy / dist)
      end
    end
    -- ribbon.y = ribbon.y + 10 * dt
    -- ribbon.vy = ribbon.vy + 0 * dt
    ribbon.vx = ribbon.vx * 0.9
    ribbon.vy = ribbon.vy * 0.9
    ribbon.x = ribbon.x + ribbon.vx
    ribbon.y = ribbon.y + ribbon.vy
  end
end

-- Renders the game
function love.draw()
  -- Set some drawing filters
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)

  -- Clear the screen
  love.graphics.setColor(254 / 255, 229 / 255, 95 / 255, 1)
  love.graphics.rectangle('fill', 0, 0, GAME_WIDTH, GAME_HEIGHT)
  love.graphics.setColor(1, 1, 1, 1)

  -- Draw ribbons
  love.graphics.setColor(13 / 255, 134 / 255, 244 / 255, 1)
  for _, ribbon in ipairs(ribbons) do
    if ribbon.next then
      love.graphics.line(ribbon.x, ribbon.y, ribbon.next.x, ribbon.next.y)
    end
  end

  -- local mouseX, mouseY = love.mouse.getPosition()
  -- love.graphics.rectangle('fill', mouseX / RENDER_SCALE - 2, mouseY / RENDER_SCALE - 2, 4, 4)
  -- love.graphics.line(0, 0, 100, 100)
end

-- Loads a pixelated image
function loadImage(filePath)
  local image = love.graphics.newImage(filePath)
  image:setFilter('nearest', 'nearest')
  return image
end

-- Draws a sprite from a sprite sheet image, spriteNum=1 is the upper-leftmost sprite
function drawSprite(image, spriteNum, spriteWidth, spriteHeight, flipHorizontally, x, y)
  local columns = math.floor(image:getWidth() / spriteWidth)
  local col = (spriteNum - 1) % columns
  local row = math.floor((spriteNum - 1) / columns)
  local quad = love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, image:getDimensions())
  love.graphics.draw(image, quad, x + (flipHorizontally and spriteWidth or 0), y, 0, flipHorizontally and -1 or 1, 1)
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
