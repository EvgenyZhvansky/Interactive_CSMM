function img_filtered=median2D(img)
dot_plus=1; %how many pixels to adda in each direction for median filtering
% img_filtered=0*img;
width=1+2*dot_plus;
img_large=padarray(img,[dot_plus*2 dot_plus*2],'symmetric','both');
img_filtering=zeros([size(img),width^2]);
for i=-dot_plus:dot_plus
    for j=-dot_plus:dot_plus
        img_filtering(:,:,(i+dot_plus)*width+j+dot_plus+1)=img_large(width+i:end-width+i+1,width+j:end-width+j+1);
    end
end
img_filtered=median(img_filtering,3);
end