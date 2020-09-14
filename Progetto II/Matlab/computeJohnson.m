%pTimes: matrice nx2 contenente i processing time nelle due macchine

function [jobsOrder] = computeJohnson(pTimes)

n = size(pTimes, 1);

head = 1;
tail = n;
jobsOrder = zeros(1,n);
pTimesCopy = pTimes;

for i=1:n
    [M, I] = min(pTimesCopy(:));
    [r, c] = ind2sub(size(pTimesCopy),I);
    if(c == 1)
        jobsOrder(head) = r;
        head = head +1;
    elseif(c == 2)
        jobsOrder(tail) = r;
        tail = tail-1;
    end
    pTimesCopy(r,:) = [+Inf +Inf];
end




end

