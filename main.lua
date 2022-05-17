--- PROXY ---

print("--- Welcome to Proxy ---")

---DIALOG:---
function input_dialog()
    --Mining oder building?
    print("What do you want to do?")
    local FileList = fs.list("proxy/task")
    for key, file in ipairs(FileList) do --Loop. Underscore because we don't use the key, ipairs so it's in order
        print("["..key.."]".." "..file)
    end
    
    shell.run("proxy/task/"..FileList[tonumber(ask("Give the number"))])
end

function ask(question)
    write(question..":")
    return read()
end

function github_update()
    shell.run("proxy/ci/update.lua")
end

---!!!Start:!!!---
github_update()
input_dialog()
print("Done!")