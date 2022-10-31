local Node = {}
Node.__index = Node
Node.x = 0
Node.y = 0
Node.g = 0
Node.h = 0
Node.f = 0
Node.parent = nil

function Node.new(x, y, g)
    return setmetatable({x = x, y = y, g = g or 1}, Node)
end

export type Node = typeof(Node)

local Boundaries = {}
Boundaries.__index = Boundaries
Boundaries.minimumX = 0
Boundaries.maximumX = 0
Boundaries.minimumY = 0
Boundaries.maximumY = 0

function Boundaries.new(mX : number, maxX : number, mY : number, maxY : number)
    return setmetatable({minimumX = mX, maximumX = maxX, minimumY = mY, maximumY = maxY}, Boundaries)
end

export type Boundaries = typeof(Boundaries)

local AStar = {}

function AStar:GetNeighbors(currentNode : Node, boundaries : Boundaries, blackList : Array<Node>) : Array<Node>
    blackList = blackList or {}

    local result : Array<Node> = {
        Node.new(currentNode.x + 1, currentNode.y),
        Node.new(currentNode.x - 1, currentNode.y),
        Node.new(currentNode.x, currentNode.y + 1),
        Node.new(currentNode.x, currentNode.y - 1),
    }

    for i = #result, 1, -1 do
        local n : Node = result[i]

        if self:OutOfBounds(n, boundaries) then
            table.remove(result, i)
            continue 
        end

        for _, bn : Node in pairs(blackList) do
            if self:AreEqual(n, bn) then
                table.remove(result, i)
            end
        end
    end 

    return result
end

function AStar:OutOfBounds(node : Node, boundaries : Boundaries) : boolean
    if 
    node.x < boundaries.minimumX or 
    node.x > boundaries.maximumX or
    node.y < boundaries.minimumY or
    node.y > boundaries.maximumY then
        return true
    end


    return false
end

function AStar:GetPath(node : Node) : Array<Node>
    local temp : Array<Node> = {}
    local result : Array<Node> = {}

    local currentNode : Node = node

    while currentNode do
        table.insert(temp, currentNode)
        currentNode = currentNode.parent 
    end

    for i = #temp, 1, -1 do
        table.insert(result, temp[i])
    end

    return result
end

function AStar:Heuristic(currentNode : Node, endNode : Node) : number
    return math.abs(currentNode.x - endNode.x) + math.abs(currentNode.y - endNode.y)
end

function AStar:AreEqual(node1 : Node, node2 : Node) : boolean
    return node1.x == node2.x and node1.y == node2.y
end

function AStar:Find(table : Array<Node>, node : Node)
    for i : number, currentNode : Node in pairs(table) do
        if 
        self:AreEqual(currentNode, node)
        then
            return i
        end
    end
    return nil
end

function AStar:FindPath(start : Node, target : Node, boundaries : Boundaries, blackList : Array<Node>?) : Array<Node>
    local openList : Array<Node> = {start}
    local closedList : Array<Node> = {}

    while #openList > 0 do
        local currentNode : Node = openList[1]

        for _, node in pairs(openList) do
            if node.f < currentNode.f then
                currentNode = node
            end
        end

        --Final Case
        if self:AreEqual(currentNode, target) then
            return self:GetPath(currentNode)
        end

        --Move the current node from the openSet, closedSet
        table.insert(closedList, currentNode)
        table.remove(openList, self:Find(openList, currentNode))

        --Normal case
        local neighbors : Array<Node> = self:GetNeighbors(currentNode, boundaries, blackList)
        for _, neighbor : Node in pairs(neighbors) do
            if self:Find(closedList, neighbor) then
                continue
            end

            local possibleG = currentNode.g + neighbor.g

            if not self:Find(openList, neighbor) then
                table.insert(openList, neighbor)
            elseif possibleG >= neighbor.g then
                continue
            end

            neighbor.g = possibleG
            neighbor.h = self:Heuristic(neighbor, target)
            neighbor.f = neighbor.g + neighbor.h
            neighbor.parent = currentNode
        end
    end

    --Couldn't find a path
    return {}
end

AStar.Boundaries = Boundaries
AStar.Node = Node

return AStar