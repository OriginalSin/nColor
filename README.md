# @texel/color

![generated](./test/banner.png)

Минимальная и современная библиотека цветов для JavaScript. Особенно полезна для приложений реального времени, генеративного искусства и графики в сети.

Возможности: быстрое преобразование цветов, цветовое различие, сопоставление гаммы и сериализация
Оптимизирован для скорости: примерно в 5-125 раз быстрее, чем Colorjs.io (см. тесты )
Оптимизирован для малого объема памяти и минимального выделения памяти: в функциях преобразования и отображения гаммы не создаются массивы или объекты.
Оптимизировано для компактных пакетов: отсутствие зависимостей, а неиспользуемые цветовые пространства могут быть автоматически удалены для небольших размеров (например, ~3,5 КБ минифицированы, если вам требуется только преобразование OKLCH в sRGB)
Оптимизировано для точности: высокоточные матрицы цветового пространства
Ориентирован на минимальный и современный набор цветовых пространств:
xyz (D65), xyz-d50, oklab, oklch, okhsv, okhsl, srgb, srgb-linear, display-p3, display-p3-linear, rec2020, rec2020-linear, a98-rgb, a98-rgb-linear, prophoto-rgb, prophoto-rgb-linear


https://www.shadertoy.com/view/WlGyDG
