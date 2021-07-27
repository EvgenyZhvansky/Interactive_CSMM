function img_filtered=div_simple(img, pow)
img1=[img(:,2:end),img(:,end)];
img2=[img(2:end,:);img(end,:)];
img_filtered=abs(img-img1).*max(img,img1).^pow+abs(img-img2).*max(img,img2).^pow;
img_filtered=img_filtered/max(img_filtered(:));
end