function savePlot(shouldSave, fig, name)

    if (shouldSave == 0)
        return
    end

    saveas(fig, sprintf('../Informes/Images_tp3/%s', name), 'png');

end