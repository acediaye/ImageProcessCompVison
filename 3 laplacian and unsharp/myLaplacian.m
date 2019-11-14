function output = myLaplacian(image)
    [row,col,channel]=size(imread(image));
    if channel>1%if color image, convert to intensity image
        myimage=double(rgb2gray(imread(image)));
    else%reads black and white image
        myimage=double(imread(image));
    end
    %whos myimage;
    
    figure(1)
    subplot(2,2,1)
    imshow(myimage,[0 255])%display original image
    title('original')
    
    pad=1;
    padimage=zeros(row+(2*pad),col+(2+pad));%create padded array
    for i=1:row
        for j=1:col
            padimage(i+pad,j+pad)=myimage(i,j);%padded array doesnt start at origin
        end
    end
    subplot(2,2,2)
    imshow(padimage,[0 255])%shows padded image
    title('padimage')
    [m n]=size(padimage);
    %whos padimage;
    
    maskimage=zeros(row,col);
    kernel=[-1 -1 -1;
            -1  8 -1;
            -1 -1 -1];%kernel adds to 0    
    for i=1:row
        for j=1:col
            maskimage(i,j)=sum(sum(kernel.*padimage(i+pad-1:i+pad+1,j+pad-1:j+pad+1)));%keranl * subarray of image 
        end%sum(sum(array)) makes the array into a row of sums then into a scalar of sums
    end
    subplot(2,2,3)
    imshow(maskimage,[0 255])%shows mask
    title('mask')
    
    laplacianimage=zeros(row,col);
    for i=1:row
        for j=1:col
            laplacianimage(i,j)=myimage(i,j)+maskimage(i,j);%added the derivative intensity to the original image
        end
    end
    subplot(2,2,4)
    imshow(laplacianimage,[0 255])%shows final image
    title('mylaplacian')
    
    output=laplacianimage;
end

