local Node = {}
Node.__index = Node
Node.x = 0
Node.y = 0
Node.g = 0
Node.h = 0
Node.parent = nil

function Node.new(x, y)
    return setmetatable({x = x, y = y}, Node)
end

export type Node = typeof(Node)

local Astar = {}

function Astar:GetNeighbors(currentNode : Node) : Array<Node>
    return {
        Node.new(currentNode.x + 1, currentNode.y),
        Node.new(currentNode.x - 1, currentNode.y),
        Node.new(currentNode.x, currentNode.y + 1),
        Node.new(currentNode.x, currentNode.y - 1),
    }
end

function Astar:FindPath(start : Node, target : Node) : Array<Node>
    
end

Astar.Node = Node

return Astar