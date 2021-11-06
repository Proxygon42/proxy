barrel_string = "minecraft:barrel"

function barrel()
    turtle.place()
    turtle.suck()
    for i = 1, 16, 1 do
        turtle.select(i)
        local item_detail = turtle.getItemDetail()
        if item_detail ~= nil then
            if item_detail.name == barrel_string then
                turtle.placeUp(i)
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
            if item_detail.name == barrel_string then

                barrel()

            end
        end
    end
end