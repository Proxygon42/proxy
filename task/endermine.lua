---!!!FUNCTIONS:!!!---

---PARAMETER:---
function set_parameter()
    --TODO x_start_coordination, y_start_coordination, z_start_coordination, weiteres
    --TODO y_loop_start->bildet sich aus y_start_coordination, aber in relation zu wie weit in y_direction schon gegraben wurde
    --TODO z_loop_start->bildet sich aus z_start_coordination, aber in relation zu wie weit in z_direction schon gegraben wurde
    fuel_value = 80--Kohle Value
    maxFuel = turtle.getFuelLimit()--20.000 Bei normalen Turtles
    height = 0
    minFuelAmount = 200
    maxMinFuelAmount = 5000
    coal_string = "minecraft:coal"
    chest_string = "minecraft:chest"--TODO ender chest einrichten
    enderchest_string = "minecraft:ender_storage"
    comming_from = "back"--Letzte Richtung aus der Die Turtle gekommen ist["back","forward","up","down"]
    z_xyz = 16--Default arbeitet die turtle 16 Blöcke Tiefe ab
    y_deep_dark_farming_plane = 58--von Höhe 4 bis Höhe 61 kann gefarmt werden
    endermodem_string = "computercraft:advanced_modem"
end

---DIALOG:---
function input_dialog()
    --Wie tief,Breit,Hoch das zu minende Gebiet vor der Turtle
    local dialog_read = ""
    while dialog_read ~= "y" do
        print("Ready to lose me?(y/n)")
        dialog_read = read()
    end
    write("I will miss you")
    sleep(0.5)
    write(".")
    sleep(1)
    write(".")
    sleep(1)
    write(".")
end



---MINING/MOVING:---
function route_mine()

    if  y_xyz > 0 then
        --Die eingegebene Höhe ist positiv und es muss als erste y_direction nach oben gegangen werden
        y_direction = 1
    else
        --Die eingegebene Höhe ist negativ und es muss als erste y_direction nach unten gegangen werden
        y_direction = -1
    end


    if x_xyz < 0 then
        x_forloop = math.abs(x_xyz) + 1

        --Die Breite gibt die Reihen links von der Turtle abzubauen.
        x_direction = -1
    else
        x_forloop = x_xyz

        --Die Breite gibt die Reihen rechts von der Turtle abzubauen.
        x_direction = 1
    end

    while true do
        --Unendlich Reihen

        for i_z = z_loop_start , z_xyz , 1 do
            --Die Tiefe, welche z ist, bestimmt wie weit eine Reihe gegangen wird.
            
            turtle_turn(i_z)--Checkt ob ein turn benötigt wird und führt diesen aus

            for i_y = y_loop_start , y_deep_dark_farming_plane , 1 do
                --Die Höhe, welche y ist, bestimmt wie hoch oder tief in jedem Feld gegangen wird.
                
                --Bevor eine Bewegung gemacht wird, wird überprüft ob mehr Fuel als der minFuelAmount gegeben ist.
                checker_fuel()

                if i_y == 1 then
                    --Erster Durchgang wird gerade aus gegangen:

                    --Gravel-Schutz Script:
                    if turtle.forward() == false then
                        repeat
                            turtle.attack()
                            turtle.dig()
                            sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
                        until turtle.forward() == true
                    end
                    comming_from = "back"
                else
                    --Es wird hoch oder runter gegangen
                    if y_direction == 1 then
                        --Hoch:
                        --Gravel-Schutz Script:
                        if turtle.up() == false then
                            repeat
                                turtle.attackUp()
                                if turtle.detectUp() == true then
                                    counter_cobblestone()
                                    turtle.digUp()
                                end
                                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
                            until turtle.up() == true
                        end
                        comming_from = "down"
                    elseif y_direction == -1 then
                        --Runter:
                        --Gravel-Schutz Script:
                        if turtle.down() == false then
                            repeat
                                turtle.attackDown()
                                if turtle.detectDown() == true then
                                    counter_cobblestone()
                                    turtle.digDown()
                                end
                                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
                            until turtle.down() == true
                        end
                        comming_from = "up"
                    end
                end
                --Überprüft, ob nach dem abbauen noch PLatz im Inventar für neue Items ist:
                inventory_space()
            end
            y_loop_start = 1--y_loop_start ist wieder 1

            --Da die turtle schon an der Höhe angekommen ist, muss sie bei der nächsten runde in die andere Richtung, was Höhe angeht:
            y_direction = y_direction * -1
        end
        
        z_loop_start = 1--z_loop_start ist wieder 1
    end
end
function counter_cobblestone()
    local block_exists , inspect_block = turtle.inspect()
    --Zählt wie viel cobble abgebaut wird
    if inspect_block.name == cobblestone_string then
        inventar_counter_cobblestone = inventar_counter_cobblestone + 1

        if inventar_counter_cobblestone >= maxCobblestone then
            --Wenn 64 cobble aufgesammelt wurde, wird alles an cobble im Inventar gedroppt
            for i_cobble_slot = 1, 16, 1 do
                turtle.select(i_cobble_slot)
                if turtle.getItemDetail().name == cobblestone_string then
                    turtle.drop()
                end
            end
        end
    end
end

function turtle_turn(z_tiefe)
    if z_tiefe == 16 then
        --turn rechts
        turtle.turnRight()
    elseif z_tiefe == 1 then
        --turn links
        turtle.turnLeft()
    end
end

function select_item(item)
    --sucht gibt in einer table alle Slots wieder, wo das Item gefunden wird.
    local slot_table = {}
	for i_select = 1 , 16 , 1 do
        local item_data = turtle.getItemDetail(i_select)
        if item_data ~= nil then--Diese Abfrage wird benötigt, weil bei einer ".name" abfrage von nil das Programm stirbt
            if item_data.name == item then
                table.insert(slot_table, i_select)
            end
            
        end
    end
    return slot_table
end

function inventory_space()
    while checker_empty_slots()[1] == nil do
        --Wenn kein freier Slot gefunden wurde, wird das Inventar in eine chest entleert
        chest_place()
    end
end

function checker_empty_slots()
    --Gibt in einem table die leeren slot numbers
    local free_slots = {}
    for i_slot = 1 , 16 , 1 do
        if turtle.getItemCount(i_slot) == 0 then
            --Wenn ein freier Slot gefunden wird;
            table.insert(free_slots, i_slot)
            
        end
    end
    return free_slots


end



function chest_place()
    --TODO für enderchest anpassen + print anpassen
    --Wenn keine Chest im Inventory ist, wird geprintet "Bitte entleeren sie das Inventar" oder so.

    local selector_chest = choose_chest()
    while selector_chest == nil do
        print("Das Inventar der turtle ist voll.")
        print("Bitte entleeren sie das Inventar oder geben Sie eine Chest dem Inventar hinzu.")
        print("Drücken Sie danach ENTER zum fortfahren.")
        read()
        if checker_empty_slots()[1] ~= nil then
            --Es wurde vom User ein Slot frei geräumt
            return
        end
        selector_chest = choose_chest()

    end
    --Selects the Chest:
    turtle.select(selector_chest)
    
    if comming_from == "back" then
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.place()
        drop_inventory_chest()

        if chest == enderchest_string then
            --If Enderchest, take it with you
            turtle.dig()
        end

        turtle.turnRight()
        turtle.turnRight()
    elseif comming_from == "up" then
        turtle.placeUp()

        if chest == enderchest_string then
            --If Enderchest, take it with you
           turtle.digUp()
        end

    elseif comming_from == "down" then
        turtle.placeDown()
        drop_inventory_chest()

        if chest == enderchest_string then
            --If Enderchest, take it with you
            turtle.digDown()
        end

    end

    
end
function drop_inventory_chest()
    --Es wird zunächst alle Mögliche Kohle bis auf 1 zum refuelen verwendet, wenn die Turtle nicht schon wirklich genug fuel hat:
    if turtle.getFuelLevel() < maxMinFuelAmount then
        turtle_refuel()
    end


    for i = 1, 16, 1 do

        turtle.select(i)
        local selected_item = turtle.getItemDetail(i)
        if selected_item ~= nil then
            if selected_item.name ~= coal_string and selected_item.name ~= chest_string then
                --Wenn das Item keine Kohle und keine Chest ist, wird gedroppt
                if comming_from == "back" then
                    turtle.drop()
                elseif comming_from == "up" then
                    turtle.dropUp()                
                elseif comming_from == "down" then
                    turtle.dropDown()
                end
            end
        end
    end
end
function choose_chest()
    --If enderchest vorhanden
    local select_chest = select_item(enderchest_string)[1]
    if select_chest ~= nil then
        chest = enderchest_string--Parameter
        return select_chest
    end
    --Else search for normal chest
        chest = chest_string--Parameter

    select_chest = select_item(chest_string)[1]
    return select_chest

end

---FUELING:---
function checker_fuel()
    --Dieser Code bezieht sich auf Kohle Energie
    while turtle.getFuelLevel() <= minFuelAmount do
        --Solange minFuelAmount nicht übertroffen wurde, wird diese Schleife wiederholt.
        
        --Die function turtle_refuel() wird aufgerufen, wodurch refueled wird, aber im Falle fehlender Kohle nil ausgegeben wird:
        if turtle_refuel() == nil then
            --Wenn keine Kohle gefunden wurde
            print("Nicht genug Kohle gefunden. Bitte befüllen.")
            print("Drücken Sie ENTER, wenn sie Kohle eingeführt haben.")
            read()
        else
            --Gefueled
            print("Turtle goes brrr")
        end
    end
end

function turtle_refuel()
    --Fueled + gibt den Fuel Stand mit, wenn es tanken konnte und nil, wenn nicht
    local coal_slot = select_item(coal_string)
    if coal_slot[1] ~= nil then
        --Wenn Kohle gefunden wurde
        local i_checker_fuel = 1
        while coal_slot[i_checker_fuel] ~= nil do
            --Es wird solange das inv geleert, bis maxFuel erreicht wurde oder keine Kohle mehr gefunden wurde
            
            
            slot_coal = coal_slot[i_checker_fuel]--Gibt einen Slot von Kohle wieder oder nil, wenn keine Kohle gefunden wurde.
            coal_amount = turtle.getItemCount(slot_coal)
            if i_checker_fuel == 1 then
                --Bei dem ersten Durchgang, wird 1 Kohle übrig gelassen, damit immer ein Slot für Kohle freigehalten wird.
                coal_amount = coal_amount - 1
            end
            -- Max Anzahl an Items beachten, um nicht mehr als max möglich zu fuelen:
            maxFuel_items = math.floor((maxFuel-turtle.getFuelLevel())/fuel_value)
            if coal_amount > maxFuel_items then
                coal_amount = maxFuel_items
            end

            --Refuel:
            turtle.select(slot_coal)
            turtle.refuel(coal_amount)
            --Zähler um zu wissen, ob es der erste Durchgang ist:
            i_checker_fuel = i_checker_fuel + 1
        end
        return turtle.getFuelLevel()
    else
        return nil
    end
end

function github_update()
    shell.run("proxy/update.lua")
end

---!!!Start:!!!---
github_update()
input_dialog()
set_parameter()
route_mine()
print("Done!")