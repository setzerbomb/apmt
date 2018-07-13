function Escape()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.setTries(novo)
    data.tries = novo
  end

  function self.getTries()
    return data.tries
  end

  function self.addTries()
    data.tries = data.tries + 1
  end

  function self.setTryToEscape(action)
    data.tryToEscape = action
  end

  function self.getTryToEscape()
    return data.tryToEscape
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
