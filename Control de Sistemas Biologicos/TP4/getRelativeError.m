function e = getRelativeError(absoluteError, realValue)

    e = zeros(1, length(absoluteError));

    if (length(absoluteError) ~= length(realValue))
        fprintf("ERROR: se esperaba que los vectores de error relativo sean de las mismas dimensiones\n");
        return;
    end

    for i = 1:length(absoluteError)
    
        if (realValue(i) < 1e-3) && (absoluteError(i) < 1e-3)
            e(i) = 1;
        elseif (realValue(i) < 1e-3) && (absoluteError(i) > 1e-2)
            e(i) = 100;
         elseif (realValue(i) > 1e-2) && (absoluteError(i) < 1e-3)
            e(i) = 0;
        else
            e(i) = 100*absoluteError(i)/realValue(i);
        end

    end

end