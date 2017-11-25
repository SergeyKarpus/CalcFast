uses GraphABC, ABCObjects;
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
    
    property Value: integer read val;// Свойство Value устанавливается только в контрукторе
    property bColor: Color read col write SetColor;
    property IsPressed: boolean read isPress write SetIsPressed;
    property IsRightAnswer: boolean read isRightAns write SetIsRightAnswer;
  end;

var
  M, N: integer; // размеры игрового поля в кнопках по горизонтали и вертикали
  arrField: array [0..maxDimX, 0..maxDimY] of cButton; // массив с кнопками игрового поля
  RightAnswer: integer; // текущий правильный ответ
  isCanUseMouse: boolean;// флаг, что сейчас можно обрабатывать нажатие мыши

// отображение игрового поля - кнопки от 3*3 до n*m
//   задается на входе размерность и диапозон значений на заполнение
// при нажатии на кнопку менять цвет на зеленый

{
TODO:
проверка на собранный ряд
сверка ответов, если ряд собран
мигать цветом кнопок при правильном/неправильном ответе
фиксация результатов
игра на время
уровни
}

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
  // рисуем поле с кнопками
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      GetButtonCoord(i, j, DimX, DimY, X, Y);
      MyRoundRectABC := new RoundRectABC(X, Y, ButtonSize, ButtonSize, 5, arrField[i, j].bColor);
      MyRoundRectABC.Text := arrField[i, j].Value.ToString;
      MyRoundRectABC.dx := i; // сохраняем позицию создаваемой кнопки в массиве классов кнопок
      MyRoundRectABC.dy := j;
    end;
  
  // пишем условие
  SetFontSize(17);
  DrawTextCentered(10, 10, WinWidth - 10, 50, 'Выберете цепочку, чтобы в сумме получилось:');
  SetFontSize(30);
  DrawTextCentered(10, 60, WinWidth - 10, 110, RightAnswer.ToString);
  
  // запускам обработку мыши
  isCanUseMouse := true;
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
  RightAnswer := 0;
  
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      bValue := random(DiffLevel * 10 - 1) + 1;
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
  for var j := 0 to N - 1 do 
  begin
    if PressedInRow(j) = 0 then begin
      result := false;
      exit;
    end;
    CurrentResult += PressedInRowValue(j);
  end;
  
  if CurrentResult = RightAnswer then BlinkColor := clGreen
  else BlinkColor := clRed;
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
  
end;

procedure MyMouseDown(x, y, mb: integer);
begin
  // Нажата левая мышь
  if isCanUseMouse and (mb = 1) then
  begin
    isCanUseMouse := false; // отключаем обработку мыши
    var ob := ObjectUnderPoint(x, y); // переменная типа объект ObjectABC
    if ob <> nil then begin
      arrField[ob.dx, ob.dy].SetIsPressed(true);
      arrField[ob.dx, ob.dy].SetColor(clMoneyGreen);
      ob.Color := arrField[ob.dx, ob.dy].bColor;
      
      // выбрано не больше одной кнопки в ряду
      if PressedInRow(ob.dy) < 2 then begin
        if CheckAnswer then begin
          {!!!!!!!!!!!!!!}
        end;
      end else
        NotSingle(ob);
      
      {!!!!!!!!!!!!!!!!!!!!!!!!!}
    end;    
    isCanUseMouse := true; // включаем обработку мыши
  end;  
end;

begin
  Window.Title := 'Считай быстро!';
  SetWindowSize(WinWidth, WinHeight);
  OnMouseDown := MyMouseDown;
  
  M := 5;N := 5;
  PrepareField(M, N, 1);
  DrawField(M, N);
  
end.