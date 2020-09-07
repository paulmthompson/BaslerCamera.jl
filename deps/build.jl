
function get_pylon_version()
    if Sys.islinux()
        PYLON_VERSION = 0
        try
            println("Try version 5")
            PYLON_VERSION=parse(Int64,Char(read(`/opt/pylon5/bin/pylon-config --version`)[1]))
        catch
            println("Try version 6")
            try
                PYLON_VERSION=parse(Int64,Char(read(`/opt/pylon/bin/pylon-config --version`)[1]))
            catch
                println("Pylon 5 or 6 not found :()")
            end
        end
    println(PYLON_VERSION)
    elseif Sys.iswindows()

    elseif Sys.isosx()
        println("No Mac support!")
    else
        println("Operating system not recognized.")
    end
    PYLON_VERSION
end

PYLON_VERSION = get_pylon_version()

if Sys.islinux()
    if PYLON_VERSION == 5
        run(`wget https://www.dropbox.com/s/1m0gfqxt7944kay/BaslerCamera.so`)
    end

end
