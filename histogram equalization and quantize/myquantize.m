function y=myquantize(image,quant_num)
    [row,col]=size(image);
    quant=image;%copy original image
    limits = linspace(0,256,quant_num+1);%divide grayscale to quant_num of bins
    for i=1:row%go through each pixel
        for j=1:col
            for k=1:quant_num%for each pixel, remap original values to bins
                lowerbound=limits(k);%lower limit of bin
                upperbound=limits(k+1);%upper limit of bin
                average=round((lowerbound+upperbound)/2);%each bin is average of low and upper limit
                if lowerbound<image(i,j) && image(i,j)<=upperbound%if intnensity is within current bin limits
                    quant(i,j)=average;%rewrite new intensity
                else%else dont touch intensity
                end
            end
        end
    end
    figure(1)
    imshow(quant, [0 255])%display quantized version of image
    title(sprintf('Quantized image with quantnum=%d',quant_num))
    y=quant;%return quantized image in array
end