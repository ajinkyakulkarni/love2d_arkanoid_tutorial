local Wall = require "Wall"
local vector = require "vector"
local love = love
local setmetatable = setmetatable
local table = table
local pairs = pairs

local WallsContainer = {}

if setfenv then
   setfenv(1, WallsContainer) -- for 5.1
else
   _ENV = WallsContainer -- for 5.2
end

function WallsContainer:new( o )
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   o.name = o.name or "walls_container"   
   o.walls = o.walls or {}
   o.collider = o.collider or {}
   o.wall_thickness = o.wall_thickness or 20
   local left_wall = Wall:new{
      position = vector( 0, 0 ),
      width = o.wall_thickness,
      height = love.window.getHeight(),
      collider = o.collider
   }
   local right_wall = Wall:new{
      position = vector( love.window.getWidth() - o.wall_thickness, 0 ),
      width = o.wall_thickness,
      height = love.window.getHeight(),
      collider = o.collider
   }
   local top_wall = Wall:new{
      position = vector( 0, 0 ),
      width = love.window.getWidth(),
      height = o.wall_thickness,
      collider = o.collider
   }
   local bottom_wall = Wall:new{
      position = vector( 0, love.window.getHeight() - o.wall_thickness ),
      width = love.window.getWidth(),
      height = o.wall_thickness,
      collider = o.collider
   }   
   o.walls.left = left_wall
   o.walls.right = right_wall
   o.walls.top = top_wall
   o.walls.bottom = bottom_wall
   return o
end

function WallsContainer:update( dt )
   for _, wall in pairs( self.walls ) do
      wall:update( dt ) 
   end   
end

function WallsContainer:draw()
   for _, wall in pairs( self.walls ) do
      wall:draw()
   end   
end

return WallsContainer
