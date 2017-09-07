classdef StatusLine < handle
    % inspired by textprogressbar.m
    
    properties

        text = 'status ... ';

        % characters to delete '\b'
        strCR = '';
    end
    
    methods
        function Update(obj,newtext)
            obj.text = newtext;
            
            strOut = [obj.text];
            fprintf([obj.strCR strOut]);
            obj.strCR = repmat('\b',1,length(strOut));
%             if(obj.autocomplete && c==100)
%                 obj.Finish();
%             end
        end
        function UpdateText(obj,newtext)
            obj.Update(newtext);
        end
        function Finish(obj)
            if(~isempty(obj.strCR))
                fprintf('\n');
            end
            obj.strCR = '';
        end        
    end
end

