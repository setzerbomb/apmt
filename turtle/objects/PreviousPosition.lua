function PreviousPosition()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.getF()
    return data.f
  end

  function self.setF(f)
    data.f = f
  end

  function self.getY()
    return data.y
  end
  function self.setY(y)
    data.y = y
  end

  function self.getX()
    return data.x
  end

  function self.setX(x)
    data.x = x
  end

  function self.getZ()
    return data.z
  end

  function self.setZ(z)
    data.z = z
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
