uses GraphABC, ABCObjects, Timers, ABCButtons;
const
  WinWidth = 1152; // ширина создаваемого окна
  WinHeight = 864; // высота создаваемого окна
  WinCenterX = WinWidth div 2; // координаты центра окна по оси X
  WinCenterY = WinHeight div 2; // координаты центра окна по оси Y
  ButtonSize = 70; // размер кнопки с числом на игровом поле
  BetweenDist = 5; // расстояние между кнопками
  EnableCheat = true; // включить подсказку с правильными ответами (только для отладки =)
  maxDimX = 8; // максимальный размер игрового поля
  maxDimY = 8;
  MaxTime = 300; // Времени на игру

type
  {класс кнопки со свсеми ее атрибутами и свойствами}
  cButton = class
  private 
    val: integer; // цифровое значение на самой кнопке
    col: Color; // цвет кнопки
    isPress: boolean; // признак, что кнопка нажата
    isRightAns: boolean; // признак, что эта кнопка с правильным ответом
    
    procedure SetColor(col: Color);// сеттер для цвета кнопки
    begin
      Self.col := col;
    end;
    
    procedure SetIsPressed(isPressed: boolean);// сеттер для признака, что кнопка нажата
    begin
      isPress := isPressed;
    end;
    
    procedure SetIsRightAnswer(isRightAns: boolean);// сеттер для признака, что эта кнопка с правильным ответом
    begin
      Self.isRightAns := isRightAns;
    end;
  
  public 
    // конструктор
    constructor(val: integer; col: Color; isPressed: boolean);
    begin
      Self.val := val;
      Self.col := col;
      Self.isPressed := isPressed;
    end;
    
    property Value: integer read val;// Свойство Value устанавливается только в конструкторе
    property bColor: Color read col write SetColor;
    property IsPressed: boolean read isPress write SetIsPressed;
    property IsRightAnswer: boolean read isRightAns write SetIsRightAnswer;
  end;

var
  M: integer = 3; // размеры игрового поля в кнопках по горизонтали и вертикали
  N: integer = 3; 
  arrField: array [0..maxDimX, 0..maxDimY] of cButton; // массив с кнопками игрового поля
  RightAnswer: integer; // текущий правильный ответ
  isCanUseMouse: boolean;// флаг, что сейчас можно обрабатывать нажатие мыши
  Level1: integer = 1; // уровень по размеру поля
  Level2: integer = 1;// уровень по величине заполняемых цифр
  t: Timer;
  LeftTime: integer = MaxTime;
  StartButton: ButtonABC;// кнопка запуска игры

// отображение игрового поля - кнопки от 3*3 до n*m
//   задается на входе размерность и диапозон значений на заполнение
// при нажатии на кнопку менять цвет на зеленый

{процедура возвращает координаты верхнего угла кнопки по 
 ее позиции и размерности игрового поля}
procedure GetButtonCoord(PosX, PosY, DimX, DimY: integer; var X, Y: integer);
begin
  X := WinCenterX - (ButtonSize * DimX + (DimX - 1) * BetweenDist) div 2 + (ButtonSize * PosX + PosX * BetweenDist);
  Y := WinCenterY - (ButtonSize * DimY + (DimY - 1) * BetweenDist) div 2 + (ButtonSize * PosY + PosY * BetweenDist);
end;

{процедура для отоброжения игрового поля}
procedure DrawField(DimX, DimY: integer);
var
  X, Y: integer;
  MyRoundRectABC: RoundRectABC;
begin
  if LeftTime < 1 then exit; // если время вышло - поле не рисуем
  
  Window.Clear;
  while Objects.Count > 0 do
    Objects[0].Destroy; // уничтожаем кнопки предыдущего поля
  
  // рисуем поле с кнопками
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do // циккл по строкам и столбцам игрового поля
    begin
      GetButtonCoord(i, j, DimX, DimY, X, Y); // получаем координаты создаваемой кнопки
      MyRoundRectABC := new RoundRectABC(X, Y, ButtonSize, ButtonSize, 5, arrField[i, j].bColor); // создаем кнопку
      MyRoundRectABC.Text := arrField[i, j].Value.ToString; // рисуем число на ней
      MyRoundRectABC.dx := i; // сохраняем позицию создаваемой кнопки в массиве классов кнопок
      MyRoundRectABC.dy := j;
    end;
  
  // пишем условие
  SetFontSize(17);
  DrawTextCentered(10, 10, WinWidth - 10, 50, 'Выберете цепочку, чтобы в сумме получилось:');
  SetFontSize(30);
  DrawTextCentered(10, 60, WinWidth - 10, 110, RightAnswer.ToString);
  
  // выводим текущий уровень
  SetFontSize(30);
  DrawTextCentered(10, WinHeight - 100, WinWidth - 10, WinHeight - 60, 'Текущий уровень: ' + IntToStr(Level1) + '.' + IntToStr(Level2));
  
  // запускам обработку мыши
  isCanUseMouse := true;
end;

// процедура для отображения результата в конце игры
procedure DrawResult(Msg: string; Lev1, Lev2: integer);
begin
  Window.Clear;
  while Objects.Count > 0 do
    Objects[0].Destroy; // удаляем все объекты игрового поля
  
  SetFontSize(40);
  DrawTextCentered(10, WinCenterY - 180, WinWidth - 10, WinCenterY - 120, Msg); // выводим сообщение об окончании
  SetFontSize(60);
  DrawTextCentered(10, WinCenterY - 30, WinWidth - 10, WinCenterY + 100, 'Набранный уровень: ' + IntToStr(Lev1) + '.' + IntToStr(Lev2)); // выводим набранный уровень
end;

{процедура для подготовки игрового поля}
procedure PrepareField(DimX, DimY, DiffLevel: integer);
var
  bValue: integer; // для определения значения на кнопке
  raRnd: integer; // для поимка случайной кнопки в ряду. Она будет с правильным ответом
  RndPrv: integer;// номер кнопки с правильным ответом в предыдущем ряду
begin
  // чистим массив и переменные
  for var i := 0 to maxDimX do
    for var j := 0 to maxDimY do
    begin
      arrField[i, j] := nil;
    end;
  
  RightAnswer := 0; // сбрасываем требуемый ответ
  
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      bValue := random(DiffLevel * 10 - 1) + 1; // определяем случаное число на кнопке
      // инициируем кнопку
      arrField[i, j] := new cButton(bValue, clFloralWhite, false);
    end;
  
  // определяем кнопки с правильным ответом
  for var j := 0 to DimY - 1 do
  begin
    case j of
      0: raRnd := 1 + random(DimX - 1);// определяем для первого ряда
    else begin
        // для остальных рядов
        if RndPrv = 0 then raRnd := random(2)
        else if RndPrv = DimX - 1 then raRnd := RndPrv - random(2)
        else raRnd := RndPrv - random(3) + 1;
      end;
    end;
    
    RndPrv := raRnd;
    arrField[raRnd, j].isRightAns := True;
    if EnableCheat then arrField[raRnd, j].SetColor(clAzure);
    RightAnswer += arrField[raRnd, j].Value;
  end;
end;

{ возвращаем сколько кнопок выбрано в ряду}
function PressedInRow(row: integer): shortint;
var
  nTmp: shortint;
begin
  nTmp := 0;
  for var i := 0 to N - 1 do
    if arrField[i, row].isPressed then nTmp += 1;
  result := nTmp;
end;

{ возвращаем значение нажатой кнопки в ряду}
function PressedInRowValue(row: integer): integer;
begin
  for var i := 0 to N - 1 do
    if arrField[i, row].isPressed then begin
      result := arrField[i, row].Value;
      exit;
    end;
end;

{ возвращаем номер нажатой кнопки в заданном ряду}
function PressedInRowNumber(row: integer): integer;
begin
  for var i := 0 to N - 1 do
    if arrField[i, row].isPressed then begin
      result := i;
      exit;
    end;
end;

{ моргаем нажатыми кнопками заданным цветом}
procedure BlinkPressed(cColor: Color);
  procedure SetColor(cColor: Color);
  begin
    for var i := 0 to Objects.Count - 1 do
      if Objects[i] is RoundRectABC then 
        if arrField[Objects[i].dx, Objects[i].dy].IsPressed then
        begin
          arrField[Objects[i].dx, Objects[i].dy].SetColor(cColor);
          Objects[i].Color := cColor;
        end;
  end;

begin
  for var i := 1 to 3 do 
  begin
    SetColor(cColor);
    sleep(100);
    SetColor(clFloralWhite);
    sleep(100);
  end;
end;

{ проверка выбранных ответов:
  - если выбрано в каждом ряду - проверяем полученную сумму цепочки}
function CheckAnswer: boolean;
var
  CurrentResult: integer;
  BlinkColor: Color;
begin
  CurrentResult := 0;
  
  // в каждом ряду выбрана кнопка
  for var j := 0 to N - 1 do 
  begin
    if PressedInRow(j) = 0 then begin
      result := false;
      exit;
    end;
    CurrentResult += PressedInRowValue(j); // считаем ответ в цепочке
  end;
  
  // проверяем, что в предыдущем ряде отклонение в выбранной кнопке не > 1,
  // т.е. цепочка
  for var j := 1 to N - 1 do 
  begin
    if abs(PressedInRowNumber(j - 1) - PressedInRowNumber(j)) > 1 then begin
      BlinkColor := clRed;
      BlinkPressed(BlinkColor);
      result := false;
      exit;
    end;
  end;
  
  if CurrentResult = RightAnswer then begin// сумма в цепочке совпадает с требуемой
    result := true;
    BlinkColor := clGreen
  end
  else begin
    result := false;
    BlinkColor := clRed;
  end;
  BlinkPressed(BlinkColor);
end;

{ нажато две кнопки в ряду - 
  мигаем выбранной и снимаем выбор}
procedure NotSingle(Button: ObjectABC);
begin
  for var i := 1 to 3 do 
  begin
    arrField[Button.dx, Button.dy].SetColor(clRed);
    Button.Color := arrField[Button.dx, Button.dy].bColor;
    sleep(100);
    arrField[Button.dx, Button.dy].SetColor(clFloralWhite);
    Button.Color := arrField[Button.dx, Button.dy].bColor;
    sleep(100);
  end;
  arrField[Button.dx, Button.dy].SetIsPressed(false);  
end;

{ проверка, что есть выбор в каждом из рядов}
function CheckedInAllRows: boolean;
begin
  for var j := 0 to N - 1 do 
  begin
    if PressedInRow(j) = 0 then begin
      result := false;
      exit;
    end;
  end;
  
  result := true;
end;

// Сбрасываем для всех кнопок, что их нажали и красим в начальный цвет
procedure ClearChoose;
begin
  for var i := 0 to Objects.Count - 1 do
    if Objects[i] is RoundRectABC then begin
      arrField[Objects[i].dx, Objects[i].dy].SetIsPressed(false);
      if EnableCheat and arrField[Objects[i].dx, Objects[i].dy].isRightAns then arrField[Objects[i].dx, Objects[i].dy].SetColor(clAzure);
      Objects[i].Color := arrField[Objects[i].dx, Objects[i].dy].bColor;
    end;
end;

// обработка нажатия кнопуи мыши
procedure MyMouseDown(x, y, mb: integer);
begin
  // Нажата левая мышь
  if isCanUseMouse and (mb = 1) and (LeftTime > 0) then
  begin
    isCanUseMouse := false; // отключаем обработку мыши
    var ob := ObjectUnderPoint(x, y); // кликнуто на переменной типа объект ObjectABC
    if ob <> nil then begin
      if arrField[ob.dx, ob.dy].isPress then begin// если снимаем предадущий выбор
        arrField[ob.dx, ob.dy].SetIsPressed(false);
        arrField[ob.dx, ob.dy].SetColor(clFloralWhite);
        if EnableCheat and arrField[ob.dx, ob.dy].isRightAns then arrField[ob.dx, ob.dy].SetColor(clAzure);
      end else begin// выбираем
        arrField[ob.dx, ob.dy].SetIsPressed(true);
        arrField[ob.dx, ob.dy].SetColor(clMoneyGreen);
      end;
      ob.Color := arrField[ob.dx, ob.dy].bColor;
      
      // проверки на составление цепочки и правильный ответ
      // выбрано не больше одной кнопки в ряду
      if PressedInRow(ob.dy) < 2 then begin
        if CheckAnswer then begin// составлена цепочка 
          {увеличиваем счетчик правильных ответов, усложняем}
          Level2 += 1;
          if Level2 = 10 then begin// если это максимальный уровень на текущем размере поля - увеличиваем поле
            Level2 := 1;
            Level1 += 1;
            M += 1;
            N += 1;
            if M > maxDimX then begin
              {пройден максимальный уровень}
              DrawResult('Вы прошли максимальный уровень!', Level1 - 1, 9);
            end;
          end;
          PrepareField(M, N, Level2); // подготавливаем массив под новые уровни
          DrawField(M, N); // рисуем поле
          
        end else if CheckedInAllRows then begin// выбрано в каждом ряду, но это не цепочка или результат не тот
          {сбрасываем, что нажато}
          ClearChoose;
        end
      end else
        NotSingle(ob); // выбрано две кнопки в ряду
    end;    
    isCanUseMouse := true; // включаем обработку мыши
  end;  
end;

// сработал таймер
procedure Timer1;
begin
  // выводим оставшееся время
  SetBrushColor(clWhite);
  FillRectangle(WinWidth - 300, 50, WinWidth - 10, 90);
  LeftTime -= 1;
  SetFontSize(14);
  DrawTextCentered(WinWidth - 300, 50, WinWidth - 10, 90, 'Осталось времени: ' + IntToStr(LeftTime));  
  
  // время вышло - выводим результат  
  if LeftTime = 0 then begin
    t.Stop;
    isCanUseMouse := false;
    DrawResult('Время закончилось!', Level1, Level2);
  end;
end;

// запуск игры
procedure StartGame;
begin
  StartButton.Visible := false;
  OnMouseDown := MyMouseDown;
  
  t := new Timer(1000, Timer1);
  t.Start;
  
  PrepareField(M, N, Level2);
  DrawField(M, N);
end;

begin
  // создаем окно
  Window.Title := 'Считай быстро!';
  SetWindowSize(WinWidth, WinHeight);
  
  // выводим начальное сообщение с правилами  
  SetFontSize(32);
  DrawTextCentered(100, 10, WinWidth - 10, 140, 'Математическая игра "Считай быстро!"');
  SetFontSize(20);
  DrawTextCentered(10, 140, WinWidth - 10, 300, 'Цель игры - построить на игровом связанную цепочку из чисел сверху вниз так, ' + #13 + #10 +
                                                'чтобы они в сумме дали заданный результат. ' + #13 + #10 +
                                                'Игра ведется на время.');
  StartButton := ButtonABC.Create(WinCenterX - 100, WinCenterY + 200, 200, 50, 'Начать игру', clFloralWhite);
  StartButton.OnClick := StartGame; 
  
end.