function Fuels()
  local self = {}
  local data

  function self.getFuels()
    return data.list
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
