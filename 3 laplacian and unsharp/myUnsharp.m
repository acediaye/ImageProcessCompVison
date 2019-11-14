function output = myUnsharp(image,k,filt_size)
    %assumes filt_size is odd
    myimage=imread(image);
    [row,col,channel]=size(myimage);
    if channel>1%if color image, convert to intensity image
        myimage=rgb2gray(myimage);
    end
    
    figure(1)
    subplot(2,2,1)
    imshow(myimage,[0 255])%shows original image
    title('original')
    
    pad=floor((filt_size-1)/2);%given filter size, calculate padding size needed
    padimage=zeros(row+(2*pad),col+(2*pad));%creates padded array
    for i=1:row
        for j=1:col
            padimage(i+pad,j+pad)=myimage(i,j);%padded array start is shifted 
        end
    end
    %subplot(2,2,2)
    %imshow(padimage,[0 255])
    %title('pad')
    
    kernel=ones(filt_size,filt_size)/(filt_size*filt_size);%create square kernel / num of elements, kernel adds to 1
    blurimage=zeros(row,col);
    for i=1:row
        for j=1:col
            blurimage(i,j)=sum(sum(kernel.*padimage(i:i+2*pad,j:j+2*pad)));%kernel * subarray of image
        end%sum(sum(array)) makes array into a row of sums then into a scalar of sums
    end
    subplot(2,2,2)
    imshow(blurimage,[0 255])%display blurred image
    title('blur')
    
    maskimage=zeros(row,col);
    for i=1:row
        for j=1:col
            maskimage(i,j)=myimage(i,j)-blurimage(i,j);%creates mask array of high pass filter
        end
    end
    subplot(2,2,3)
    imshow(maskimage,[0 255])%shows mask
    title('mask')
    
    unsharpimage=zeros(row,col);
    for i=1:row
        for j=1:col
            unsharpimage(i,j)=myimage(i,j)+k*maskimage(i,j);%mask gets boosted by k before adding to original image
        end
    end
    subplot(2,2,4)
    imshow(unsharpimage,[0 255])%shows final image
    title('unsharp')
    
    output=unsharpimage;
end

