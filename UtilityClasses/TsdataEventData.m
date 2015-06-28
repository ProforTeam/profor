classdef TsdataEventData < event.EventData
    
   properties
      usedMethod
   end

   methods
      function data = TsdataEventData(method)
         data.usedMethod = method;
      end
   end
end
