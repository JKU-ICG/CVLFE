classdef AdvancedTextProgressBar < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    % inspired by textprogressbar.m
    
    properties
        starttime = -1;
        startpct = 0;
        maxcount = 100; %default 100 percent
        text = 'progress ... ';
        % Vizualization parameters
        strPercentageLength = 6;   %   Length of percentage string (must be >5)
        strDotsMaximum      = 10;   %   The total number of dots in a progress bar
        computeeta = true;
        autocomplete = true;
        strCR = '';
    end
    
    methods
        function UpdateProgress(obj, numdone)
            pct = numdone/obj.maxcount*100;
            c = floor(pct);
            percentageOut = [num2str(c) '%%'];
            percentageOut = [percentageOut repmat(' ',1,obj.strPercentageLength-length(percentageOut)-1)];
            nDots = floor(c/100*obj.strDotsMaximum);
            dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,obj.strDotsMaximum-nDots) ']'];
            strOut = [obj.text percentageOut dotOut];
                
            if(obj.computeeta)
                if(obj.starttime==-1)
                    obj.starttime = tic();
                    obj.startpct = pct;
                end
                timediff = toc(obj.starttime);
                esttime = timediff/(pct-obj.startpct)*(100-obj.startpct);
                timeleft = max(0,esttime-timediff);
                
                strOut = sprintf('%s elapsed: %s left: %s',strOut,obj.FormatTime(timediff),obj.FormatTime(timeleft));
            end
            fprintf([obj.strCR strOut]);
            obj.strCR = repmat('\b',1,length(strOut)-1);
            if(obj.autocomplete && c==100)
                obj.Finish();
            end
        end
        function UpdateText(obj,newtext)
            obj.text = newtext;
        end
        function SetMaxCount(obj,newmax)
            obj.maxcount = newmax;
        end
        function Finish(obj)
            if(~isempty(obj.strCR))
                fprintf('\n');
            end
            obj.strCR = '';
            obj.starttime=-1;
            obj.startpct=0;
        end
        function str = FormatTime(~,tsec)
            if(tsec==Inf)
                str = 'unknown';
            else
                hrs = floor(tsec/3600);
                min = floor((tsec-hrs*3600)/60);
                sec = floor(tsec-hrs*3600-min*60);
                str = '';
                if(hrs>0)
                    str = [str sprintf('%dh',hrs)];
                end
                if(min>0 || hrs>0)
                    str = [str sprintf('%dm',min)];
                end
                str = [str sprintf('%ds',sec)];
            end
        end
    end
end

