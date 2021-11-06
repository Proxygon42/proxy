barrel_string = "minecraft:barrel"
i_infinite_barrel = 1

function barrel()
    turtle.place()
    turtle.suck()
    for i_barrel = 1, 16, 1 do
        turtle.select(i)
        local item_detail = turtle.getItemDetail()
        if item_detail ~= nil then
            if item_detail.name == barrel_string then
                i_infinite_barrel = i_barrel
            else
                turtle.dropUp(i_barrel)
            end
        end
    end
    
    turtle.dig()
end

while true do
    print("Just one more...")
    for i = 1, 16, 1 do
        turtle.select(i)
        local item_detail = turtle.getItemDetail()
        if item_detail ~= nil then
            if i == i_infinite_barrel then

                barrel()

            else
                turtle.dropUp(i)
            end
        end
    end
end