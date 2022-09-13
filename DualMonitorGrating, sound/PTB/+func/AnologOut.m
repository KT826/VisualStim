function AnologOut(ao,data)

try
    ao.IsContinuous = true;  
queueOutputData(ao,data);  
startBackground(ao);
        
catch
    queueOutputData(ao,data);  
startBackground(ao);


end
