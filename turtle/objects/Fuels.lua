function Fuels()
  local self = {}
  local data

  function self.getFuels()
    return data.list
  end
  
  function self.setRefuelTries(tries)
    data.tries = tries
  end
  
  function self.getRefuelTries()
    return data.tries
  end
  
  function self.addRefuelTries()
    data.tries = data.tries + 1
  end

  function self.start(tabela)
    data = tabela
  end 

  return self
end
