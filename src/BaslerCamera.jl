module BaslerCamera

export Camera, get_data, connect, start_acquisition, stop_acquisition

export start_ffmpeg, end_ffmpeg, change_ffmpeg_folder

using Libdl, FFMPEG

const mydl = string(dirname(Base.source_path()),"/../deps/BaslerCamera.so")

function __init__()
    try
        init_pylon()
    catch
        println("Could not successfully load Pylon libraries. Are they installed?")
    end
end

mutable struct Camera
    cam::Ptr{Nothing}
    connected::Bool
    acquiring::Bool
    recording::Bool
    w::Int64
    h::Int64
    bytes::Int64
    ffmpeg_path::String
    ffmpeg_input_opts::String
    ffmpeg_output_opts::String
    output_folder::String
    num_cam::Int64
end

function Camera(h,w,_bytes,num_cam=1)
    cam = init_camera(num_cam)
    Camera(cam,false,false,false,w,h,_bytes,FFMPEG.ffmpeg_path,"","",".",num_cam)
end

function get_data(cam::Camera)
    get_camera_data(cam.cam,cam.w,cam.h,cam.num_cam)
end

function connect(cam::Camera)
    connect_camera(cam.cam)
    sleep(1.0)
    change_resolution(cam.cam,cam.w,cam.h)
end

function start_acquisition(cam)
    start_acquisition(cam.cam)
end

function stop_acquisition(cam)
    stop_acquisition(cam.cam)
end

function init_pylon()
    ccall((:initPylon,mydl),Nothing,())
    nothing
end

function init_camera(num_cam=1)
    cam = ccall((:newMyCamera,mydl),Ptr{Nothing},(Int32,),num_cam)
end

function connect_camera(cam)
    ccall((:MyCamera_Connect,mydl),Nothing,(Ptr{Nothing},),cam)
    nothing
end

function start_acquisition(cam)
    ccall((:MyCamera_StartAcquisition,mydl),Nothing,(Ptr{Nothing},),cam)
    nothing
end

function stop_acquisition(cam)
    ccall((:MyCamera_StopAcquisition,mydl),Nothing,(Ptr{Nothing},),cam)
    nothing
end

function get_camera_data(cam,w,h,n_cam=1)
    ccall((:MyCamera_GrabFrames,mydl),Nothing,(Ptr{Nothing},),cam)

    #If there is no TTL trigger, the data matrix
    #Associated with the camera may not be initialized
    #and we will just return a blank matrix
    grabbed = ccall((:MyCamera_GetFramesGrabbed,mydl),Bool,(Ptr{Nothing},),cam)
    if (grabbed)
        a = ccall((:MyCamera_GetData,mydl),Ptr{UInt8},(Ptr{Nothing},),cam)
        b=unsafe_wrap(Array,a,w*h*n_cam)
        c=reshape(b,(convert(Int64,h),convert(Int64,w*n_cam)))
    else
        c = zeros(UInt8,w,h*n_cam)
    end

    (c, grabbed)
end

function start_ffmpeg(cam)
    ccall((:MyCamera_StartFFMPEG,mydl),Nothing,(Ptr{Nothing},),cam)
    nothing
end

function end_ffmpeg(cam)
    ccall((:MyCamera_EndFFMPEG,mydl),Nothing,(Ptr{Nothing},),cam)
    nothing
end

function change_resolution(cam,w,h)
    ccall((:MyCamera_changeResolution,mydl),Nothing,(Ptr{Nothing},Int32,Int32),cam,w,h)
    nothing
end

function change_ffmpeg_folder(cam,folder)

    ccall((:MyCamera_ChangeFolder,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam,pointer(string(folder,"/")))

    nothing
end

function change_camera_config(cam,path)
    ccall((:MyCamera_ChangeCameraConfig,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam,pointer(string(path)))

    nothing
end

function change_ffmpeg_path(cam,path)
    ccall((:MyCamera_ChangeFFMPEG,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam,pointer(string(path)))

    nothing
end

function change_ffmpeg_input_opts(cam,opts)
    ccall((:MyCamera_ChangeFFMPEGInputOptions,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam,pointer(string(opts)))

    nothing
end

function change_ffmpeg_output_opts(cam,opts)
    ccall((:MyCamera_ChangeFFMPEGOutputOptions,mydl),Nothing,(Ptr{Nothing},Ptr{UInt8}),cam,pointer(string(opts)))

    nothing
end

function change_bytes(cam,_bytes)
    ccall((:MyCamera_ChangeBytes,mydl),Nothing,(Ptr{Nothing},Int32),cam,_bytes)

    nothing
end

end
