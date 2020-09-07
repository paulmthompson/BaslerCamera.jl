
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

    #run(`wget https://www.dropbox.com/s/1dr7g8x270xdrup/whisk-1.1.0d-64bit-Linux.tar.gz`)
    #run(`tar -xzf whisk-1.1.0d-64bit-Linux.tar.gz`)
    #rm("whisk-1.1.0d-64bit-Linux.tar.gz")
    #run(`mv whisk-1.1.0d-Linux whisk`)
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
        run(`wget https://www.dropbox.com/sh/dnq78bfrr9misq5/AAA48DbnuClV7mPVbE3dHJIja`)
    end

end
