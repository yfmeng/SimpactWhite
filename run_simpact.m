if ~isdeployed
addpath( [fileparts(which(mfilename)) '\lib'] );
end
startup

%have to add it twice because somewhere startup removes the path
if ~isdeployed
addpath( [fileparts(which(mfilename)) '\lib'] );
end
SIMPACTGUI

