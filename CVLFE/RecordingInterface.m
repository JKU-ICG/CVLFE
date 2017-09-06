classdef RecordingInterface
    properties
    end
    
    methods
    end
    
    methods (Abstract)
      pushIllum(obj, illumination, name)
      % add an illumination to the stack
      wait(obj)
      % wait for the recordings (e.g. from camera)
      [img, exposure] = popImaging(obj, name)
      % get a recording from the stack
   end
    
end

