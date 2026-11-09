function app = launchTeachingModuleInteractiveApps(initialTab)
arguments
    initialTab (1,1) string = "Contents"
end

app = TeachingModuleInteractiveApps(initialTab);

if nargout == 0
    clear app
end
