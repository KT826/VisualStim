%%
outputSingleScan(do.TTL.w,[1])
outputSingleScan(do.TTL.w,[0])
%%
outputSingleScan(do.TTL.k,[1])
outputSingleScan(do.TTL.k,[0])
%%
outputSingleScan(do.TTL.trigger,[1])
outputSingleScan(do.TTL.trigger,[0])
%%
outputSingleScan(do.TTL.SE,[1]) % reset TTL
outputSingleScan(do.TTL.SE,[0]) % reset TTL
%%

queueOutputData(ao,ao_vector.ao1.vector);  
startBackground(ao);