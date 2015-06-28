classdef setConditionalEventData < event.EventData
    
   properties
      yConditional
      yConditionalDates      
      yConditionalX
      yConditionalDatesX
   end   

   methods
      function data=setConditionalEventData(varargin)
         n=nargin;
         for i=1:2:n
            data.(varargin{i})=varargin{i+1};
         end;
      end
   end
end