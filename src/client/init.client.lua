local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Astar = require(ReplicatedStorage.Common.Astar)

local TARGET_COLOR = Color3.fromRGB(0, 0, 160)
local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255)
local PATH_COLOR = Color3.fromRGB(216, 238, 46)
local GRID_SIZE = 10
local BLOCK_SIZE = 5
local GAP_SIZE = 0.2

local firstNode = nil
local secondNode = nil

local reference = {}
local path = {}

for i = 1, GRID_SIZE do
    reference[i] = {}
end

for x = 1, GRID_SIZE do
    for y = 1, GRID_SIZE do
        local block = Instance.new("Part")
        block.Anchored = true
        block.Size = Vector3.new(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
        block.Position = Vector3.new(x * (BLOCK_SIZE + GAP_SIZE), 1, y * (BLOCK_SIZE + GAP_SIZE))
        block.Color = DEFAULT_COLOR

        local node = Astar.Node.new(x, y)
        reference[x][y] = block

        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MouseClick:Connect(function()
            if not firstNode or (firstNode and secondNode) then
                for _, node in pairs(path) do                   
                    reference[node.x][node.y].Color = DEFAULT_COLOR
                end

                if firstNode then
                    reference[firstNode.x][firstNode.y].Color = DEFAULT_COLOR
                end
                if secondNode then
                    reference[secondNode.x][secondNode.y].Color = DEFAULT_COLOR
                end
                firstNode = node
                reference[firstNode.x][firstNode.y].Color = TARGET_COLOR
                secondNode = nil
            else
                secondNode = node
                reference[secondNode.x][secondNode.y].Color = TARGET_COLOR

                path = Astar:FindPath(firstNode, secondNode)

                for i, node in pairs(path) do
                    if i == 1 or i == #path then
                        continue
                    end

                    reference[node.x][node.y].Color = PATH_COLOR
                end
                
            end
        end)
        clickDetector.Parent = block

        block.Parent = workspace
    end
end