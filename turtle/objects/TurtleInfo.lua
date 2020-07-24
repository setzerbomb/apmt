function TurtleInfo()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.getId()
    return data.id
  end

  function self.getName()
    return data.name
  end

  function self.getWorld()
    return data.world
  end

  function self.setWorld(world)
    data.world = world
  end

  function self.activateSlaveBehavior()
    data.isSlave = true
  end

  function self.deactivateSlaveBehavior()
    data.isSlave = false
  end

  function self.isSlave()
    return data.isSlave
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
