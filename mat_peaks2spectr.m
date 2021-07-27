function spectr=mat_peaks2spectr(data_sp, low, high, n)
spectr=zeros(1,high-low+1);
for i=1:size(data_sp,2)
    mzi=round(data_sp(1,i)*n)-low+1;
    if mzi<high-low+1 && mzi>0
        spectr(mzi)=spectr(mzi)+data_sp(2,i);
    end
end
end