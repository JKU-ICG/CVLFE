classdef RecordingSimulate < RecordingInterface
    properties
        mD
        mA
        
        % stack things:
        mIllumStack
        mNames
    end
    
    
    methods
        function obj = RecordingSimulate( Dexpect, A )
            obj.mD = Dexpect;
            obj.mA = A;
            obj.mIllumStack = {};
            obj.mNames = {};
        end
        
        function obj = pushIllum(obj, illumination, name)
            
            
            % add an illumination to the stack
            cId = length(obj.mIllumStack) + 1;
            if nargin < 3
                name = num2str( cId );
            end
            obj.mIllumStack{cId} = illumination;
            obj.mNames{cId} = name;
        end
        
        
        function obj = wait(obj)
            % wait for the recordings (e.g. from camera)
            
            % do nothing here!
        end
        
        function [obj, img, exposure] = popImaging(obj, name)
            % get a recording from the stack
            
            cId = 1;
            assert( strcmp( obj.mNames{cId}, name ) );
            
            imgFloat = simulate_illumination( obj.mD, obj.mA, obj.mIllumStack{cId} );
            
            exposure = 1 / max(imgFloat(:));
            if isinf( exposure )
               exposure = 1.0; % avoid division by zero! 
            end
            nImg = imgFloat .* exposure;
            img = uint8( nImg * 255.0 );
            
            % delete from stack
            obj.mNames(cId) = [];
            obj.mIllumStack(cId) = [];
        end
        
    end
    
end

