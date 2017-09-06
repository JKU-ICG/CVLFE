classdef StatusLine < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
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
%         function str = FormatTime(~,tsec)
%             if(tsec==Inf)
%                 str = 'unknown';
%             else
%                 hrs = floor(tsec/3600);
%                 min = floor((tsec-hrs*3600)/60);
%                 sec = floor(tsec-hrs*3600-min*60);
%                 str = '';
%                 if(hrs>0)
%                     str = [str sprintf('%dh',hrs)];
%                 end
%                 if(min>0 || hrs>0)
%                     str = [str sprintf('%dm',min)];
%                 end
%                 str = [str sprintf('%ds',sec)];
%             end
%         end
    end
end

