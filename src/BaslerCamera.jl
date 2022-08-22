module BaslerCamera

export Camera, get_data, init_camera, load_configuration, change_save_path, set_record


const mydl = string(dirname(Base.source_path()),"/../deps/libCameraManager.so")

function __init__()
end

mutable struct Camera
    cam::Ptr{Nothing}
    recording::Bool
    w::Int64
    h::Int64
    config_path::String
end

function Camera(h,w,config_file)
    cam = init_camera()
    Camera(cam,false,w,h,config_file)
end

function get_data(cam::Camera)
    get_camera_data(cam.cam,cam.w,cam.h)
end

function init_camera()
    cam = ccall((:newCameraManager,mydl),Ptr{Nothing},())
end

function load_configuration(cam::Camera, path)
    ccall((:CameraManager_LoadConfigurationFile,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam.cam,pointer(string(path)))
end

function get_camera_data(cam::Ptr{Nothing},w,h)
    grabbed = ccall((:CameraManager_AcquisitionLoop,mydl),Int32,(Ptr{Nothing},),cam)

    #If there is no TTL trigger, the data matrix
    #Associated with the camera may not be initialized
    #and we will just return a blank matrix

    c = zeros(UInt8,w,h)
    if (grabbed > 0)
        ccall((:CameraManager_GetImage,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8},Int32),cam,pointer(c),0)
    end

    (c, grabbed)
end

function change_save_path(cam,path)
    ccall((:CameraManager_ChangeFileNames,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam,pointer(string(path)))

    nothing
end

function get_camera_ids(cam)
    output_ids = zeros(Int32,20)
    num_cam = ccall((:CameraManager_GetActiveCameras,mydl),Int32,(Ptr{Nothing},Ptr{Int32}),cam,pointer(output_ids))
    println("A total of ", num_cam, " are connected with IDs of ")
    for i=1:num_cam
        println(output_ids[i])
    end
    output_ids[1:num_cam]
end

function set_record(cam,state)
    ccall((:CameraManager_SetRecord,mydl),Nothing,(Ptr{Nothing},Bool),cam,state)
end

end
