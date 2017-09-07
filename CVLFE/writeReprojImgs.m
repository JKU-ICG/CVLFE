function [ ] = writeReprojImgs( reproj4D, illum4D, folder, name )

    dst_folder = fullfile( folder, 'recording' );
    if ~exist( dst_folder, 'dir' ), mkdir(dst_folder); end;
    
    mlaImg = mlaFromLF( reproj4D, false );
    imwrite( mlaImg, fullfile( dst_folder, [name '-RECTIFIED.png'] ) );
    
    mlaIllum = mlaFromLF( illum4D, false );
    imwrite( mlaIllum, fullfile( dst_folder, [name '-ILLUMINATION.png'] ) );

end

