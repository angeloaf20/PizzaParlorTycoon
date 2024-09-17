local ManagerRegister = {}

function ManagerRegister:RegisterManager(name, instance)
    ManagerRegister[name] = instance
end

function ManagerRegister:GetManager(name)
    return ManagerRegister[name]
end

return ManagerRegister