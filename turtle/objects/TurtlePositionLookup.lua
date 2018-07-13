TurtlePositionLookup = function()

  local sef = {}

  --Lua adaptation of Trilateration.js by Peter Locker [https://github.com/PeterBrain/trilateration/]

  local function trilaterate(p1, p2, p3,p4)

    local function norm(a)
      return math.sqrt((a.x^2) + (a.y^2) + (a.z^2));
    end

    local function dot(a, b)
      return a.x * b.x + a.y * b.y + a.z * b.z;
    end

    local function vector_subtract(a, b)
      return
        {
          x = a.x - b.x,
          y = a.y - b.y,
          z = a.z - b.z
        }
    end

    local function vector_add(a, b)
      return
        {
          x = a.x + b.x,
          y = a.y + b.y,
          z = a.z + b.z
        }
    end

    local function vector_divide(a, b)
      return
        {
          x = a.x / b,
          y = a.y / b,
          z = a.z / b
        }
    end

    local function vector_multiply(a, b)
      return
        {
          x = a.x * b,
          y = a.y * b,
          z = a.z * b
        }
    end

    local function vector_cross(a, b)
      return
        {
          x = a.y * b.z - a.z * b.y,
          y = a.z * b.x - a.x * b.z,
          z = a.x * b.y - a.y * b.x
        }
    end

    local ex, ey, ez, i, j, d, a, x, y, z, b= nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil;

    ex = vector_divide(vector_subtract(p2, p1), norm(vector_subtract(p2, p1)));

    i = dot(ex, vector_subtract(p3, p1));
    a = vector_subtract(vector_subtract(p3, p1), vector_multiply(ex, i));
    ey = vector_divide(a, norm(a));
    ez =  vector_cross(ex, ey);
    d = norm(vector_subtract(p2, p1));
    j = dot(ey, vector_subtract(p3, p1));

    x = ((p1.r^2) - (p2.r^2) + (d^2)) / (2 * d);
    y = ((p1.r^2) - (p3.r^2) + (i^2) + (j^2)) / (2 * j) - (i / j) * x;

    b = (p1.r^2) - (x^2) - (y^2);

    if (math.abs(b) < 0.0000000001)	then
      b = 0;
    end

    z = math.sqrt(b);

    if (z == nil) then
      return null;
    end

    a = vector_add(p1, vector_add(vector_multiply(ex, x), vector_multiply(ey, y)))
    local p4a = vector_add(a, vector_multiply(ez, z));
    local p4b = vector_subtract(a, vector_multiply(ez, z));

    local r1 = math.sqrt((p4a.x - p4.x)^2 + (p4a.y - p4.y)^2 + (p4a.z - p4.z)^2)
    local r2 = math.sqrt((p4b.x - p4.x)^2 + (p4b.y - p4.y)^2 + (p4b.z - p4.z)^2)

    local precision = 0.05

    if ((r1 + precision)  > p4.r and (r1 - precision) < p4.r) then
      return p4a
    else
      return p4b
    end

    --return {a,p4a, p4b};
  end

  local vectorToObject = function(vetor)
    local objeto = {}
    objeto.x = vetor[1]
    objeto.y = vetor[2]
    objeto.z = vetor[3]
    objeto.f = vetor[4]
    objeto.r = vetor[5]
    return objeto
  end

  local hasDifferences = function(data)
    local diffOnX = false
    local diffOnY = false
    local diffOnZ = false
    local indexes = {}

    local function addIndex(index,data)
      if (data[index] == nil) then
        data[index] = index
      end
    end

    for i  = 1,#data-1 do
      for j = i+1,#data do
        if (data[i].x ~= data[j].x) then
          diffOnX = true
          addIndex(i,indexes)
          addIndex(j,indexes)
        end
        if (data[i].y ~= data[j].y) then
          diffOnY = true
          addIndex(i,indexes)
              addIndex(j,indexes)
        end
        if (data[i].z ~= data[j].z) then
          diffOnZ = true
          addIndex(i,indexes)
          addIndex(j,indexes)
        end
      end
      if (diffOnX and diffOnY and diffOnZ) then
        return true,indexes
      end
    end

    return diffOnX and diffOnY and diffOnZ, indexes
  end

  local findCoordinatesReferences = function(data,locationIDs,protocol)

    local receivedData = {}

    for i=1,#locationIDs do
      rednet.send(locationIDs[i],"help",protocol)
      receivedData[i] = {rednet.receive(protocol,5)}
      if (receivedData[i] ~= nil) then
        data[i] = vectorToObject(textutils.unserialize(receivedData[i][2]))
      end
    end
  end

  local round = function(data)
    local function floorOrCeil(value)
      if ((value - math.floor(value)) > 0.5) then
        return math.ceil(value)
      else
        return math.floor(value)
      end
    end

    data.x = floorOrCeil(data.x)
    data.y = floorOrCeil(data.y)
    data.z = floorOrCeil(data.z)

    return data
  end

  self.main = function()
    local p = LoadPeripherals()
    if (p.openWirelessModem(p.getTypes())) then

      local locationIDs = {rednet.lookup("location")}
      local data = {}

      local protocol = "location"

      findCoordinatesReferences(data,locationIDs,protocol)

      if (#data >= 4) then
        local success, indexes = hasDifferences(data)
        if (success) then
          local counter = 1
          local serialized  = {}
          for k,v in ipairs(indexes) do
            serialized[counter] = v
            counter = counter + 1
          end

          local references = {}

          for i = 1,#serialized do
            references[i] = data[serialized[i]]
            data[serialized[i]] = nil
          end

          if (#references < 4) then
            for k,v in ipairs(data) do
              references[counter] = v
            end
          end

          return round(trilaterate(references[1],references[2],references[3],references[4]))
        end
      end
    end
    return nil
  end

  return self
end
