---PARAMETER:---
function set_parameter()
    fuel_value = 80--Kohle Value
    maxFuel = turtle.getFuelLimit()--20.000 Bei normalen Turtles
    minFuelAmount = 200
    maxMinFuelAmount = 5000
    coal_string = "coal"
    chest_string = "chest"
    enderchest_string = "enderstorage:ender_storage"
    --building_block_obj wird in input dialog gesetzt
end

---DIALOG:---
function input_dialog()
    repeat
        print("Platzieren Sie den Baublock im ersten Slot und drücken Sie danach ENTER")
        read()
        building_block_obj = turtle.getItemDetail(1)
    until building_block_obj ~= nil
    print("Bitte geben Sie folgende Daten ein..")
    length = tonumber(dialog_einzelne_xyz_eingabe("Länge"))
    height = tonumber(dialog_einzelne_xyz_eingabe("Höhe"))
end

function dialog_einzelne_xyz_eingabe(xyz_string)
    local xyz = nil
    while tonumber(xyz) == nil or tonumber(xyz) == 0 do
        write(xyz_string..":")
        xyz = read()
        if tonumber(xyz) == 0 then
            print("Der Wert darf nicht null sein")
        end
        if tonumber(xyz) == nil then
            print("Bitte geben Sie die Daten in Zahlenformat ein.")
        end
    end
    return xyz
    
end

function build()
    --Startet über den ersten zu platzierenden Block
    select_block = select_item(building_block_obj.name)

    local i_height = 1
    while i_height <= height do

        --Durchgänge der Ebenen
        i_height = i_height + 1
        if i_height > 2 then--Falls es gedanklich keinen Sinn ergibt, vergesse nicht den Zähler ein paar Zeilen drüber
            --Die Turtle dreht sich um, um die Reihe in die andere Richtung nochmal zu platzieren.
            --Diesmal eine Ebene höher.
            force_move("up")
            turtle.turnLeft()
            turtle.turnLeft()
        end

        local i_length = 1
        while i_length <= length do
            --Durchgänge an einzelnen Blocklängen
            i_length = i_length + 1

            check_and_select_building_block()
            force_place("down")

            if i_length <= length then--Falls es gedanklich keinen Sinn ergibt, vergesse nicht den Zähler ein paar Zeilen drüber
                --Ende der Reihe noch nicht erreicht..
                force_move("forward")
            end

        end
    end
    
end

function select_item(item, find_string)
    --sucht gibt in einer table alle Slots wieder, wo das Item gefunden wird.
    local slot_table = {}
	for i_select = 1 , 16 , 1 do
        local item_data = turtle.getItemDetail(i_select)
        if item_data ~= nil then--Diese Abfrage wird benötigt, weil bei einer ".name" abfrage von nil das Programm stirbt
            if find_string == true then
                if string.find(item_data.name, item) == true then
                    table.insert(slot_table, i_select)
                end
            elseif item_data.name == item then
                table.insert(slot_table, i_select)
            end
            
        end
    end
    return slot_table
end

function check_and_select_building_block()
    if turtle.getItemDetail(select_block[1]) == nil then
        --Kein Item im Slot
        local i_repeat_select = 1
        repeat
            select_block = select_item(building_block_obj.name)
            i_repeat_select = i_repeat_select + 1

            if i_repeat_select == 16 and select_block ~= nil then
                print("Folgender Block fehlt:")
                print(building_block_obj.name)
                print("Drücke zum fortfahren ENTER")
            end
        until select_block ~= nil
    end
end
function start_position()
    force_move("up")
    force_move("forward")
end

function force_place(direction)

    if direction == "infront" then

        if turtle.place() == false then
            repeat
                turtle.attack()
                turtle.dig()
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.place() == true
        end
        turtle.place()

    elseif direction == "up" then

        if turtle.placeUp() == false then
            repeat
                turtle.attackUp()
                turtle.digUp()
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.placeUp() == true
        end
        turtle.placeUp()

    elseif direction == "down" then

        if turtle.placeDown() == false then
            repeat
                turtle.attackDown()
                turtle.digDown()
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.placeDown() == true
        end
        turtle.placeDown()

    end
end

function force_move(direction)
    if direction == "up" then
        --Gravel-Schutz Script:
        if turtle.up() == false then
            repeat
                turtle.attackUp()
                if turtle.detectUp() == true then
                    counter_cobblestone("up")
                    turtle.digUp()
                end
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.up() == true

        end
        comming_from = "down"

    elseif direction == "down" then
        --Runter:
        --Gravel-Schutz Script:
        if turtle.down() == false then
            repeat
                turtle.attackDown()
                if turtle.detectDown() == true then
                    counter_cobblestone("down")
                    turtle.digDown()
                end
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.down() == true
            
        end
        comming_from = "up"

    elseif direction == "forward" then
        --Gravel-Schutz Script:
        if turtle.forward() == false then
            repeat
                turtle.attack()
                if turtle.detect() == true then
                    counter_cobblestone("forward")
                    turtle.dig()
                end
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.forward() == true

        end
        comming_from = "back"

    else
        print("ERROR: False force move string.")
    end
end

function github_update()
    shell.run("proxy/update.lua")
end

---!!!Start:!!!---
github_update()
set_parameter()
input_dialog()
start_position()
build()
print("Done!")