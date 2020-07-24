function CommonFunctions()
  local self = {}

  local oldseed = os.time()

  function self.switch(t)
    t.case = function(self, x)
      local f = self[x] or self.default
      if f then
        if type(f) == "function" then
          f(x, self)
        else
          error("Case " .. tostring(x) .. " is not a function")
        end
      end
    end
    return t
  end

  function self.try(f, catch_f)
    local status, exception = pcall(f)
    if not status then
      catch_f(exception)
    end
  end

  function self.limitToWrite(limit)
    local timer = os.startTimer(limit)

    while true do
      local event, result = os.pullEvent()
      if event == "timer" and timer == result then
        return 0
      else
        if event == "key" then
          return io.read()
        end
      end
    end
  end

  function self.randomness(minimo, maximo)
    math.randomseed(oldseed)
    oldseed = ((oldseed - math.tan(os.time())) * ((os.clock() * 1000) + (os.time() / 1000))) / oldseed
    return math.random(minimo, maximo)
  end

  return self
end
