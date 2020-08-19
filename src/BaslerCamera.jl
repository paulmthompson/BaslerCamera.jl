module BaslerCamera

export init_camera, init_pylon, connect_camera, start_acquisition,
stop_acquisition, get_camera_data, start_ffmpeg, end_ffmpeg, change_ffmpeg_folder, change_resolution

using Libdl, FFMPEG

const mydl = "/home/wanglab/Programs/WhiskerTask/BaslerCpp.so"

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

end
