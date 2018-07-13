function GhostItems()
  local self = {}
  local data

  function self.getLightGhosts()
    return data.lightGhosts
  end

  function self.getStorageGhosts()
    return data.storageGhosts
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
