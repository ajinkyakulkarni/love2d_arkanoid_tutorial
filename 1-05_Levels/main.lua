-- Ball
local ball = {}
ball.position_x = 200
ball.position_y = 500
ball.speed_x = 700
ball.speed_y = 700
ball.radius = 10

function ball.update( dt )
   ball.position_x = ball.position_x + ball.speed_x * dt
   ball.position_y = ball.position_y + ball.speed_y * dt   
end

function ball.draw()
   local segments_in_circle = 16
   love.graphics.circle( 'line',
			 ball.position_x,
			 ball.position_y,
			 ball.radius,
			 segments_in_circle )   
end

function ball.rebound( shift_ball_x, shift_ball_y )
   local min_shift = math.min( math.abs( shift_ball_x ),
			       math.abs( shift_ball_y ) )
   if math.abs( shift_ball_x ) == min_shift then
      shift_ball_y = 0
   else
      shift_ball_x = 0
   end
   ball.position_x = ball.position_x + shift_ball_x
   ball.position_y = ball.position_y + shift_ball_y
   if shift_ball_x ~= 0 then
      ball.speed_x  = -ball.speed_x
   end
   if shift_ball_y ~= 0 then
      ball.speed_y  = -ball.speed_y
   end
end

function ball.reposition()
   ball.position_x = 200
   ball.position_y = 500   
end


-- Platform
local platform = {}
platform.position_x = 500
platform.position_y = 500
platform.speed_x = 500
platform.width = 70
platform.height = 20

function platform.update( dt )
   if love.keyboard.isDown("right") then
      platform.position_x = platform.position_x + (platform.speed_x * dt)
   end
   if love.keyboard.isDown("left") then
      platform.position_x = platform.position_x - (platform.speed_x * dt)
   end   
end

function platform.draw()
   love.graphics.rectangle( 'line',
			    platform.position_x,
			    platform.position_y,
			    platform.width,
			    platform.height )   
end

function platform.bounce_from_wall( shift_platform_x, shift_platform_y )
   platform.position_x = platform.position_x + shift_platform_x
end

-- Bricks
local bricks = {}
bricks.rows = 8
bricks.columns = 11
bricks.top_left_position_x = 70
bricks.top_left_position_y = 50
bricks.brick_width = 50
bricks.brick_height = 30
bricks.horizontal_distance = 10
bricks.vertical_distance = 15
bricks.current_level_bricks = {}
bricks.no_more_bricks = false

function bricks.new_brick( position_x, position_y, width, height )
   return( { position_x = position_x,
	     position_y = position_y,
	     width = width or bricks.brick_width,
	     height = height or bricks.brick_height } )
end

function bricks.update_brick( single_brick )   
end

function bricks.draw_brick( single_brick )
   love.graphics.rectangle( 'line',
			    single_brick.position_x,
			    single_brick.position_y,
			    single_brick.width,
			    single_brick.height )   
end

function bricks.construct_level( level_bricks_arrangement )
   bricks.no_more_bricks = false
   for row_index, row in ipairs( level_bricks_arrangement ) do
      for col_index, bricktype in ipairs( row ) do
	 if bricktype ~= 0 then
	    local new_brick_position_x = bricks.top_left_position_x +
	       ( col_index - 1 ) *
	       ( bricks.brick_width + bricks.horizontal_distance )
	    local new_brick_position_y = bricks.top_left_position_y +
	       ( row_index - 1 ) *
	       ( bricks.brick_height + bricks.vertical_distance )
	    local new_brick = bricks.new_brick( new_brick_position_x,
						new_brick_position_y )
	    table.insert( bricks.current_level_bricks, new_brick )
	 end
      end
   end
end

function bricks.update( dt )
   if #bricks.current_level_bricks == 0 then
      bricks.no_more_bricks = true
   else
      for _, brick in pairs( bricks.current_level_bricks ) do
	 bricks.update_brick( brick )
      end      
   end
end

function bricks.draw()
   for _, brick in pairs( bricks.current_level_bricks ) do
      bricks.draw_brick( brick )
   end
end

function bricks.brick_hit_by_ball( i, brick, shift_ball_x, shift_ball_y )
   table.remove( bricks.current_level_bricks, i )
end

-- Walls 
local walls = {}
walls.wall_thickness = 20
walls.current_level_walls = {}

function walls.new_wall( position_x, position_y, width, height )
   return( { position_x = position_x,
	     position_y = position_y,
	     width = width,
	     height = height } )
end

function walls.update_wall( single_wall )
end

function walls.draw_wall( single_wall )
   love.graphics.rectangle( 'line',
			    single_wall.position_x,
			    single_wall.position_y,
			    single_wall.width,
			    single_wall.height )
end

function walls.construct_walls()
   local left_wall = walls.new_wall(
      0,
      0,
      walls.wall_thickness,
      love.graphics.getHeight()
   )
   local right_wall = walls.new_wall(
      love.graphics.getWidth() - walls.wall_thickness,
      0,
      walls.wall_thickness,
      love.graphics.getHeight()
   )
   local top_wall = walls.new_wall(
      0,
      0,
      love.graphics.getWidth(),
      walls.wall_thickness
   )
   local bottom_wall = walls.new_wall(
      0,
      love.graphics.getHeight() - walls.wall_thickness,
      love.graphics.getWidth(),
      walls.wall_thickness
   ) 
   walls.current_level_walls["left"] = left_wall
   walls.current_level_walls["right"] = right_wall
   walls.current_level_walls["top"] = top_wall
   walls.current_level_walls["bottom"] = bottom_wall
end

function walls.update( dt )
   for _, wall in pairs( walls.current_level_walls ) do
      walls.update_wall( wall )
   end
end

function walls.draw()
   for _, wall in pairs( walls.current_level_walls ) do
      walls.draw_wall( wall )
   end
end


-- Collisions
local collisions = {}

function collisions.resolve_collisions()
   collisions.ball_platform_collision( ball, platform )
   collisions.ball_walls_collision( ball, walls )
   collisions.ball_bricks_collision( ball, bricks )
   collisions.platform_walls_collision( platform, walls )
end

function collisions.check_rectangles_overlap( a, b )
   local x_overlap, x_b_shift = collisions.overlap_along_axis(
      a.center_x, a.halfwidth, b.center_x, b.halfwidth )
   local y_overlap, y_b_shift = collisions.overlap_along_axis(
      a.center_y, a.halfheight, b.center_y, b.halfheight )
   local overlap = ( x_overlap > 0 ) and ( y_overlap > 0 )
   return overlap, x_b_shift, y_b_shift
end

function collisions.overlap_along_axis( a_pos, a_size, b_pos, b_size )
   local diff = b_pos - a_pos
   local dist = math.abs( diff )
   local overlap_value = a_size + b_size - dist
   local b_shift = diff / dist * overlap_value
   return overlap_value, b_shift
end

function collisions.ball_platform_collision( ball, platform )
   local overlap, shift_ball_x, shift_ball_y
   local a = { center_x = platform.position_x + platform.width / 2,
	       center_y = platform.position_y + platform.height / 2,
	       halfwidth = platform.width / 2,
	       halfheight = platform.height / 2 }
   local b = { center_x = ball.position_x,
	       center_y = ball.position_y,
	       halfwidth = ball.radius,
	       halfheight = ball.radius }
   overlap, shift_ball_x, shift_ball_y =
      collisions.check_rectangles_overlap( a, b )   
   if overlap then
      ball.rebound( shift_ball_x, shift_ball_y )
   end      
end

function collisions.ball_walls_collision( ball, walls )
   local overlap, shift_ball_x, shift_ball_y
   local b = { center_x = ball.position_x,
	       center_y = ball.position_y,
	       halfwidth = ball.radius,
	       halfheight = ball.radius }
   for _, wall in pairs( walls.current_level_walls ) do
      local a = { center_x = wall.position_x + wall.width / 2,
		  center_y = wall.position_y + wall.height / 2,
		  halfwidth = wall.width / 2,
		  halfheight = wall.height / 2 }
      overlap, shift_ball_x, shift_ball_y =
      	 collisions.check_rectangles_overlap( a, b )
      if overlap then
	 ball.rebound( shift_ball_x, shift_ball_y )
      end
   end
end

function collisions.ball_bricks_collision( ball, bricks )
   local overlap, shift_ball_x, shift_ball_y
   local b = { center_x = ball.position_x,
	       center_y = ball.position_y,
	       halfwidth = ball.radius,
	       halfheight = ball.radius }
   for i, brick in pairs( bricks.current_level_bricks ) do   
      local a = { center_x = brick.position_x + brick.width / 2,
		  center_y = brick.position_y + brick.height / 2,
		  halfwidth = brick.width / 2,
		  halfheight = brick.height / 2 }
      overlap, shift_ball_x, shift_ball_y =
      	 collisions.check_rectangles_overlap( a, b )
      if overlap then	 
	 ball.rebound( shift_ball_x, shift_ball_y )
	 bricks.brick_hit_by_ball( i, brick,
				   shift_ball_x, shift_ball_y )
      end
   end
end

function collisions.platform_walls_collision()
   local overlap, shift_platform_x, shift_platform_y
   local b = { center_x = platform.position_x + platform.width / 2,
	       center_y = platform.position_y + platform.height / 2,
	       halfwidth = platform.width / 2,
	       halfheight = platform.height / 2 }
   for _, wall in pairs( walls.current_level_walls ) do
      local a = { center_x = wall.position_x + wall.width / 2,
		  center_y = wall.position_y + wall.height / 2,
		  halfwidth = wall.width / 2,
		  halfheight = wall.height / 2 }      
      overlap, shift_platform_x, shift_platform_y =
      	 collisions.check_rectangles_overlap( a, b )
      if overlap then	 
	 platform.bounce_from_wall( shift_platform_x,
				    shift_platform_y )
      end
   end
end

-- Levels
local levels = {}
levels.current_level = 1
levels.gamefinished = false
levels.sequence = {}
levels.sequence[1] = {
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1 },
   { 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1 },
   { 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0 },
   { 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0 },
   { 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

levels.sequence[2] = {
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1 },
   { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0 },
   { 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0 },
   { 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0 },
   { 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

function levels.switch_to_next_level( bricks )
   if bricks.no_more_bricks then
      if levels.current_level < #levels.sequence then
	 levels.current_level = levels.current_level + 1
	 bricks.construct_level( levels.sequence[levels.current_level] )
	 ball.reposition()
      else
	 levels.gamefinished = true
      end
   end
end



function love.load()
   bricks.construct_level( levels.sequence[levels.current_level] )
   walls.construct_walls()
end
 
function love.update( dt )
   ball.update( dt )
   platform.update( dt )
   bricks.update( dt )
   walls.update( dt )
   collisions.resolve_collisions()
   levels.switch_to_next_level( bricks )
end
 
function love.draw()
   ball.draw()
   platform.draw()
   bricks.draw()
   walls.draw()
   if levels.gamefinished then
      love.graphics.printf( "Congratulations!\n" ..
			       "You have finished the game!",
			    300, 250, 200, "center" )
   end
end

function love.keyreleased( key, code )
   if  key == 'escape' then
      love.event.quit()
   end    
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
