import xlsxwriter
from xlsxwriter import worksheet as wk
#Метод Гаусса (СЛАУ (Только текстовый вариант))
def gauss():
    def prnA(a):
        for i in range(3):
            for j in range(4):
                print('%9.4f'%a[i][j],end='')
            print(end='\n')
        print(end='\n')
     
    # a=[[0.30,-0.04,0.10,0.13],
    #    [-0.04,0.10,0.02,-0.05],
    #    [0.10,0.13,0.31,0.23]]
    print("Необходимо заполнить СЛАУ")
    while (True):
        a = [[], [], []]
        for n in range(3):
            for s in range(4):
                myotvet = float(input("Пожалуйста, введите цифру: "))
                a[n].append(myotvet)
        print("Вы уверены в такой таблице?: ")
        for n in range(3):
            print(a[n],"\n")
        myotvet = input("[y/n] ")
        if (myotvet == "y"):
            break
        else: continue
        
    prnA(a)
    for i in range(2):
        for k in range(i+1,3):
            d=-a[k][i]/a[i][i]
            for j in range(4):
                a[k][j]+=a[i][j]*d
        prnA(a)
    for i in range(2,-1,-1):
        d=0
        j=2
        while j>i:
            d+=a[j][3]*a[i][j]
            j-=1
        a[i][3]-=d;
        a[i][3]/=a[i][i]
    for i in range(3):
        print('x%d='%(i+1),'%-9.4f'%a[i][3],sep='')
#Метод половинного деления
def pol_delenie(name):
    workbook = xlsxwriter.Workbook(name)
    wk = workbook.add_worksheet()
    n = int(input("Кол-во итераций (n): "))
    e = input("Кол-во точности (e): ")
    # n = 30
    a = input("Введите а: ")
    b = input("Введите b: ")
    #Таблица
    wk.write("L1", "Точность: ")
    wk.write("M1", e)
    wk.write("B2", a)
    wk.write("C2", b)
    wk.write("L2", "Хприм=")
    wk.write("M2", "Вставь последнее выражение из столбца с Х (последнее правильное)")
    wk.write("B1", "a")
    wk.write("C1", "b")
    wk.write("D1", "x")
    wk.write("E1", "f(a)")
    wk.write("G1", "Проверка")
    wk.write("F1", "f(x)")
    wk.write("A1", "Итерации")
    wk.write("O1", "x")
    wk.write("P1", "y")
    print("--------------------------------------------------")
    print("Вам необходимо ввести формулу для последнего столбца")
    formula = input("Введите формулу: ")
    formula1 = formula.replace("X", f"B2:B{n+1}")
    formula2 = formula.replace("X", f"D2:D{n+1}")
    formula3 = formula.replace("X", f"O2:O{n+1}")
    for s in range(1, n+1):
        wk.write(s,0,s) #Итерации
        wk.write_formula(s,4,formula1)
        wk.write_formula(s,5,formula2)
        wk.write_formula(s,3, f"=(B2:B{s+1}+C2:C{s+1})/2")
    col = 2
        # myint = 2
    for s in range(n-1):
        wk.write_formula(col, 1, f"=IF(E{col}*F{col}<0,B{s+2},D{s+2})")
        wk.write_formula(col, 2, f"=IF(E{col}*F{col}<0,D{s+2},C{s+2})")
        col += 1
    for s in range(n):
        wk.write_formula(s+1, 6, f"""=IF(abs(F{col})<M$1,"верно","---")""")
    for s in range(1, 10):
        wk.write(f"O{2+s}", s)
        wk.write(f"P{2+s}", formula3)
    workbook.close()
#Вычисление дифф. уравнений с помощью метода Эйлера 
def eiler(name):
    workbook = xlsxwriter.Workbook(name)
    wk = workbook.add_worksheet()
    #h
    h = input("Введите h (пиши через запятую = 0,2): ")
    wk.write("A1", "h=")
    wk.write("B1", h)
    #Сама таблица
    wk.write("A3", "i")
    wk.write("B3", "xi")
    wk.write("C3", "yi")
    wk.write("D3", "f(xi;yi)")
    wk.write("E3", "h*f(xi;yi)")
    n = int(input("Введите n: "))
    wk.write("B4", 0)
    wk.write("C4", 0)
    print("--------------------------------------------------")
    print("Вам необходимо ввести формулу для последнего столбца")
    formula = input("Введите формулу: ")
    formula = formula.replace("X", f"E4:E{n+3}")
    for sus in range(n):
        wk.write(sus+3, 0, sus)
        wk.write_formula(sus+3, 3, formula)
        wk.write_formula(sus+3, 4 , f"=B$1*B{sus+4}") #h*f(xi;yi) 
        if (sus == n-1):
            break
        else: 
            wk.write_formula(sus+4, 1, f"=B{sus+4}+B$1") #xi
            wk.write_formula(sus+4, 2, f"=C{sus+4}+E{sus+4}") #yi
            
    #Ответ
    wk.write("G3", "Ответ: ")
    wk.write("H3", f"=C{n+3}")
    workbook.close()
    print("Ваш файл создан под именем {}".format(name))
    return 0
#Поиск интегралов
def integrals(name): # Доделать
    workbook = xlsxwriter.Workbook(name)
    wk = workbook.add_worksheet()
    a = input("Введите а (если десятичная дробь, то == 0,2): ")
    b = input("Введите b (если десятичная дробь, то == 0,2): ")
    n = int(input("Введите n: "))
    #Начальные значения
    wk.write(0,0,'a=')
    wk.write(0,1,a)
    wk.write(1,0,'b=')
    wk.write(1,1,b)
    wk.write(2,0,"n=")
    wk.write(2,1,n)
    #Вычисляемое значение (b-a)/n
    wk.write(3,0,"△x=(b-a)/n")
    wk.write_formula(3,1, "=(B2-B1)/B3")
    #Сама таблица
    #n1,2,3...
    row = 5
    for s in range(n):
        wk.write(row,0,f"n{s}=")
        wk.write(row, 1, s)
        row += 1
    #x1,2,3...
    row = 5
    num = 6                         # Костыль
    for s in range(n):
        wk.write(row, 3, f"x{s}=")
        wk.write(row, 4, f"=B$1+B{num}*B$4")
        num += 1
        row += 1
    #y1,2,3...
    row = 5
    num=6
    print("--------------------------------------------------")
    print("Вам необходимо ввести формулу для последнего столбца")
    formula = input("Введите формулу: ")
    formula = formula.replace("X", f"E6:E{n+5}")
    for s in range(n):
        wk.write(row, 6, f"y{s}=")
        wk.write(row, 7, formula)

        row += 1
        num += 1
    #Ответ
    wk.write(5, 9, "Ответ: ")
    wk.write(5, 10, "=SUM(H6:H100)*B4") # Ебейший костыль
    #Относительная погрешность
    wk.write(6,9,"Относительная погрешность: ")
    wk.write(6,10,"=(K6-B4)/K6")
    workbook.close()
    print("Ваш файл создан под именем {}".format(name))
    return 0
#Сама программа
while(True):
    print("Выберите что вы хотите получить в итоге: ")
    print("1. Выход")
    print("2. Вычисление интеграла: ")
    print("3. Вычисление дифф. уравнений с помощью метода Эйлера ")
    print("4. Решение уравнения с помощью половинного деления")
    print("5. Решение СЛАУ с помощью метода ГАУССА (только текстовый вариант)")
    name = "math.xlsx"
    otvet = input("Ваш ответ: ")
    if (otvet == "2"):
        integrals(name)
        print("--------------------------------------------------------")
        continue
    if (otvet == "3"):
        eiler(name)
        print("--------------------------------------------------------")
        continue
    if (otvet == "4"):
        pol_delenie(name)
        print("--------------------------------------------------------")
        continue
    if (otvet == "5"):
        gauss()
        print("--------------------------------------------------------")
        continue
    if (otvet == "1"):
        exit(0)
    else:
            print("Вы ввели что-то не то...")
    print("--------------------------------------------------------")
