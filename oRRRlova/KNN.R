#��������������� �������
mc.dist = function(p1, p2) sqrt(sum((p1 - p2) ^ 2)) #��������� ����������
mc.distances = function(points, u) apply(points, 1, mc.dist, u) #���������� �� ���� points �� ����� u
mc.sumByClass = function(class, arr) sum(arr[names(arr) == class]) #��������� �������� ������� ������
mc.contains = function(points, u) any(apply(points, 1, function(v) all(v == u)))

plot.limits = function(arr, deviation = 0) c(min(arr) - deviation, max(arr) + deviation) #����������� � ������������ �������� � �����������

#KNN
mc.KNN.w = function(i, k) +(i <= k)

mc.KNN = function(sortedDistances, k) {
    orderedDistances = 1:length(sortedDistances)
    names(orderedDistances) = names(sortedDistances)

    weights = mc.KNN.w(orderedDistances, k)
    weightsByClass = sapply(unique(names(weights)), mc.sumByClass, weights)

    bestClass = names(which.max(weightsByClass))
}

#LOO
mc.LOO.KNN = function(points, classes) {
    n = dim(points)[1]
    loo = rep(0, n-1) #n-1, ������ ��� ���� ������� ������ ����� ������������� � �������

    for (i in 1:n) {
        u = points[i,]
        sample = points[-i,]

        distances = mc.distances(sample, u)
        names(distances) = classes[-i]
        sortedDistances = sort(distances)

        for (k in 1:(n-1)) {
            classified = mc.KNN(sortedDistances, k)
            loo[k] = loo[k] + (classified != classes[i])
        }
    }

    loo = loo / n
}

#��������� LOO
mc.draw.LOO.KNN = function(points, classes) {
    loo = mc.LOO.KNN(points, classes)

    x = 1:length(loo)
    y = loo

    plot(x, y, type = "l", main = "LOO ��� KNN", xlab = "K", ylab = "LOO", col.lab = "blue")

    k = which.min(loo)
    k.loo = round(loo[k], 4)

    points(k, k.loo, pch = 19, col = "blue")
    label = paste("K = ", k, "\n", "LOO = ", k.loo, sep = "")
    text(k, k.loo, labels = label, pos = 3, col = "blue", family = "mono", font = 2)

    return(k)
}

#��������� ����� �������������
mc.draw.KNN = function(points, classes, colors, k) {
    uniqueClasses = unique(classes)
    names(colors) = uniqueClasses

    x = points[, 1]
    y = points[, 2]
    xlim = plot.limits(x, 0.3)
    ylim = plot.limits(y, 0.3)
    plot(points, bg = colors[classes], pch = 21, asp = 1, xlim = xlim, ylim = ylim, main = "����� ������������� KNN", col.lab = "blue") #������ ��������� �����

    #�������������� �����
    step = 0.1
    ox = seq(xlim[1], xlim[2], step)
    oy = seq(ylim[1], ylim[2], step)

    for (x in ox) {
        for (y in oy) {
            x = round(x, 1) #�������� ������� 0.1 + 0.2 = 0.3000000004
            y = round(y, 1) #�������� ������� 0.1 + 0.2 = 0.3000000004
            u = c(x, y)

            if (mc.contains(points, u)) next #�� ���������������� ��������� �����

            distances = mc.distances(points, u)
            names(distances) = classes
            classified = mc.KNN(sort(distances), k)

            #������ ����� ������������������ �����
            points(u[1], u[2], col = colors[classified], pch = 21) #u
        }
    }

    legend("topright", legend = uniqueClasses, pch = 21, pt.bg = colors[uniqueClasses], xpd = T) #������� ������� ��� ������� �������
}

#��������� ���������
test = function() {
    petals = iris[, 3:4]
    petalNames = iris[, 5]

    par(mfrow = c(1, 2))
    k = mc.draw.LOO.KNN(petals, petalNames)
    mc.draw.KNN(petals, petalNames, colors = c("red", "green3", "blue"), k = k)
}