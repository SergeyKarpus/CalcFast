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
    
    procedure SetIsPressed(isPress: boolean);// сеттер для признака, что кнопка нажата
    begin
      Self.isPress := isPress;
    end;
    
    procedure SetIsRightAnswer(isRightAns: boolean);// сеттер для признака, что эта кнопка с правильным ответом
    begin
      Self.isRightAns := isRightAns;
    end;
  
  public 
    // конструктор
    constructor(val: integer; col: Color; isPress: boolean);
    begin
      Self.val := val;
      Self.col := col;
      Self.isPress := isPress;
    end;
    
    property Value: integer read val;// Свойство Value устанавливается только в контрукторе
    property bColor: Color read col write SetColor;
    property IsPressed: boolean read isPress write SetIsPressed;
    property IsRightAnswer: boolean read isRightAns write SetIsRightAnswer;
  end;

var
  M, N: integer; // размеры игрового поля в кнопках по горизонтали и вертикали
  arrField: array [0..maxDimX, 0..maxDimY] of cButton;// массив с кнопками игрового поля

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
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      GetButtonCoord(i, j, DimX, DimY, X, Y);
      MyRoundRectABC := new RoundRectABC(X, Y, ButtonSize, ButtonSize, 5, arrField[i, j].bColor);
      MyRoundRectABC.Text := arrField[i, j].Value.ToString;
      MyRoundRectABC.dx := i; // сохраняем позицию создаваемой кнопки в массиве классов кнопок
      MyRoundRectABC.dy := j;
    end;
end;

{процедура для подготовки игрового поля}
procedure PrepareField(DimX, DimY, DiffLevel: integer);
var
  bValue: integer; // для определения значения на кнопке
  raRnd: integer; // для поимка случайной кнопки в ряду. Она будет с правильным ответом
  RndPrv: integer;// номер кнопки с правильным ответом в предыдущем ряду
begin
  // чистим массив
  for var i := 0 to maxDimX do
    for var j := 0 to maxDimY do
    begin
      arrField[i, j] := nil;
    end;
  
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
      0: raRnd := random(DimX);// определяем для первого ряда
    else begin
        // для остальных рядов
        if RndPrv = 0 then raRnd := random(2)
        else if RndPrv = DimX - 1 then raRnd := RndPrv - random(2)
        else raRnd := RndPrv - random(3) + 1;
      end;
    end;
    
    RndPrv := raRnd;
    arrField[raRnd, j].isRightAns := True;
    if EnableCheat then arrField[raRnd, j].bColor := clAzure;
  end;
end;

procedure MyMouseDown(x, y, mb: integer);
begin
  // Нажата левая мышь
  if mb = 1 then
  begin
    var ob := ObjectUnderPoint(x, y); // переменная типа объект ObjectABC
    if ob <> nil then begin
      {!!!!!!!!!!!!!!!!!!}
      ob.Color := clMoneyGreen;
    end;    
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