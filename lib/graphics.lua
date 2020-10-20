graphics = {}

function graphics.init()
  graphics.fps = 30
  graphics.glow = 0
  graphics.glow_up = true
  graphics.frame = 0
  graphics.splash_lines_open = {}
  graphics.splash_lines_close = {}
  graphics.splash_lines_close_available = {}
  for i=1,45 do graphics.splash_lines_open[i] = i end
  for i=1,64 do graphics.splash_lines_close_available[i] = i end
end

function graphics.redraw_clock()
  while true do
    if fn.dirty_screen() then
      redraw()
      fn.dirty_screen(false)
    end
    clock.sleep(1 / 30)
  end
end

function graphics:frame_clock()
  while true do
    graphics:handle_frames()
    fn.dirty_screen(true)
    clock.sleep(1 / graphics.fps)
  end
end

function graphics:handle_frames()
  self.frame = self.frame + 1
  if self.frame % 16 == 0 then
    self.glow_up =  not self.glow_up
  end
  self.glow = self.glow_up and self.frame % 16 or math.abs((self.frame % 16) - 16)
end

function graphics:draw_slots()
  for i = 1, 8 do
    self:rect(100, (i - 1) * 8, 28, 6, 15)
  end
end

function graphics:draw_terminal()
  self:text(screen.text_extents(y.buffer), 62, " >", graphics.glow)
  self:text(0, 62, y.buffer, 15)
end

function graphics:setup()
  screen.clear()
  screen.aa(0)
  self:reset_font()
end

function graphics:reset_font()
  screen.font_face(0)
  screen.font_size(8)
end

function graphics:teardown()
  screen.update()
end

-- northern information splash screen

function graphics:splash()
  local col_x = 34
  local row_x = 34
  local y = 45
  local l = self.frame >= 49 and 0 or 15
  if self.frame >= 49 then
    self:rect(0, 0, 128, 50, 15)
  end
  self:ni(col_x, row_x, y, l)
  if #self.splash_lines_open > 1 then 
    local delete = math.random(1, #self.splash_lines_open)
    table.remove(self.splash_lines_open, delete)
    for i = 1, #self.splash_lines_open do
      self:mlrs(1, self.splash_lines_open[i] + 4, 128, 1, 0)
    end
  end
  if self.frame >= 49 then
    self:text_center(64, 60, "NORTHERN INFORMATION")
  end
  if self.frame > 100 then
    if #self.splash_lines_close_available > 0 then 
      local add = math.random(1, #self.splash_lines_close_available)
      table.insert(self.splash_lines_close, self.splash_lines_close_available[add])
      table.remove(self.splash_lines_close_available, add)
    end
    for i = 1, #self.splash_lines_close do
      self:mlrs(1, self.splash_lines_close[i], 128, 1, 0)
    end
  end
  if #self.splash_lines_close_available == 0 then
    fn.break_splash(true)
    page:select(1)
  end
  fn.dirty_screen(true)
end

function graphics:ni(col_x, row_x, y, l)
  self:n_col(col_x, y, l)
  self:n_col(col_x+20, y, l)
  self:n_col(col_x+40, y, l)
  self:n_row_top(row_x, y, l)
  self:n_row_top(row_x+20, y, l)
  self:n_row_top(row_x+40, y, l)
  self:n_row_bottom(row_x+9, y+37, l)
  self:n_row_bottom(row_x+29, y+37, l)
end

function graphics:n_col(x, y, l)
  self:mls(x, y, x+12, y-40, l)
  self:mls(x+1, y, x+13, y-40, l)
  self:mls(x+2, y, x+14, y-40, l)
  self:mls(x+3, y, x+15, y-40, l)
  self:mls(x+4, y, x+16, y-40, l)
  self:mls(x+5, y, x+17, y-40, l)
end

function graphics:n_row_top(x, y, l)
  self:mls(x+20, y-39, x+28, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+19, y-37, x+27, y-37, l)
  self:mls(x+19, y-36, x+27, y-36, l)
end

function graphics:n_row_bottom(x, y, l)
  self:mls(x+21, y-40, x+29, y-40, l)
  self:mls(x+21, y-39, x+29, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+20, y-37, x+28, y-37, l)
end


-- northern information graphics abstractions

function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end

return graphics