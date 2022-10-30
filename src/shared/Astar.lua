local Node = {}
Node.__index = Node
Node.x = 0
Node.y = 0
Node.g = 0
Node.h = 0
Node.f = 0
Node.parent = nil

function Node.new(x, y)
    return setmetatable({x = x, y = y}, Node)
end

export type Node = typeof(Node)

local Astar = {}

function Astar:GetNeighbors(currentNode : Node, blackList : Array<Node>) : Array<Node>
    blackList = blackList or {}

    local result : Array<Node> = {
        Node.new(currentNode.x + 1, currentNode.y),
        Node.new(currentNode.x - 1, currentNode.y),
        Node.new(currentNode.x, currentNode.y + 1),
        Node.new(currentNode.x, currentNode.y - 1),        
    }

    for i = #result, 1, -1 do
        local n : Node = result[i]

        for _, bn : Node in pairs(blackList) do
            if self:AreEqual(n, bn) then
                table.remove(result, i)
            end
        end
    end 

    return result
end

function Astar:GetPath(node : Node) : Array<Node>
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

function Astar:Heuristic(currentNode : Node, endNode : Node) : number
    return math.abs(currentNode.x - endNode.x) + math.abs(currentNode.y - endNode.y)
end

function Astar:AreEqual(node1 : Node, node2 : Node) : boolean
    return node1.x == node2.x and node1.y == node2.y
end

function Astar:Find(table : Array<Node>, node : Node)
    for i : number, currentNode : Node in pairs(table) do
        if 
        self:AreEqual(currentNode, node)
        then
            return i
        end
    end
    return nil
end

function Astar:FindPath(start : Node, target : Node, blackList : Array<Node>?) : Array<Node>
    local openList : Array<Node> = {start}
    local closedList : Array<Node> = {}

    while #openList > 0 do
        local currentNode = openList[1]

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
        local neighbors : Array<Node> = self:GetNeighbors(currentNode, blackList)
        for _, neighbor : Node in pairs(neighbors) do
            if self:Find(closedList, neighbor) then
                continue
            end

            local possibleG = currentNode.g + 1

            if not self:Find(openList, neighbor) then
                table.insert(openList, neighbor)
            elseif possibleG >= neighbor.g then
                continue
            end

            neighbor.g = possibleG
            neighbor.h = self:Heuristic(neighbor, target)
            neighbor.f = neighbor.g + neighbor.f
            neighbor.parent = currentNode
        end
    end

    --Couldn't find a path
    return {}
end

Astar.Node = Node

return Astar