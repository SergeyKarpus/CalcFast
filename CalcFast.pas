uses GraphABC, ABCObjects, Timers, ABCButtons;
const
  WinWidth = 1152; // ������ ������������ ����
  WinHeight = 864; // ������ ������������ ����
  WinCenterX = WinWidth div 2; // ���������� ������ ���� �� ��� X
  WinCenterY = WinHeight div 2; // ���������� ������ ���� �� ��� Y
  ButtonSize = 70; // ������ ������ � ������ �� ������� ����
  BetweenDist = 5; // ���������� ����� ��������
  EnableCheat = true; // �������� ��������� � ����������� �������� (������ ��� ������� =)
  maxDimX = 8; // ������������ ������ �������� ����
  maxDimY = 8;
  MaxTime = 300; // ������� �� ����

type
  {����� ������ �� ������ �� ���������� � ����������}
  cButton = class
  private 
    val: integer; // �������� �������� �� ����� ������
    col: Color; // ���� ������
    isPress: boolean; // �������, ��� ������ ������
    isRightAns: boolean; // �������, ��� ��� ������ � ���������� �������
    
    procedure SetColor(col: Color);// ������ ��� ����� ������
    begin
      Self.col := col;
    end;
    
    procedure SetIsPressed(isPressed: boolean);// ������ ��� ��������, ��� ������ ������
    begin
      isPress := isPressed;
    end;
    
    procedure SetIsRightAnswer(isRightAns: boolean);// ������ ��� ��������, ��� ��� ������ � ���������� �������
    begin
      Self.isRightAns := isRightAns;
    end;
  
  public 
    // �����������
    constructor(val: integer; col: Color; isPressed: boolean);
    begin
      Self.val := val;
      Self.col := col;
      Self.isPressed := isPressed;
    end;
    
    property Value: integer read val;// �������� Value ��������������� ������ � ������������
    property bColor: Color read col write SetColor;
    property IsPressed: boolean read isPress write SetIsPressed;
    property IsRightAnswer: boolean read isRightAns write SetIsRightAnswer;
  end;

var
  M: integer = 3; // ������� �������� ���� � ������� �� ����������� � ���������
  N: integer = 3; 
  arrField: array [0..maxDimX, 0..maxDimY] of cButton; // ������ � �������� �������� ����
  RightAnswer: integer; // ������� ���������� �����
  isCanUseMouse: boolean;// ����, ��� ������ ����� ������������ ������� ����
  Level1: integer = 1; // ������� �� ������� ����
  Level2: integer = 1;// ������� �� �������� ����������� ����
  t: Timer;
  LeftTime: integer = MaxTime;
  StartButton: ButtonABC;// ������ ������� ����

// ����������� �������� ���� - ������ �� 3*3 �� n*m
//   �������� �� ����� ����������� � �������� �������� �� ����������
// ��� ������� �� ������ ������ ���� �� �������

{��������� ���������� ���������� �������� ���� ������ �� 
 �� ������� � ����������� �������� ����}
procedure GetButtonCoord(PosX, PosY, DimX, DimY: integer; var X, Y: integer);
begin
  X := WinCenterX - (ButtonSize * DimX + (DimX - 1) * BetweenDist) div 2 + (ButtonSize * PosX + PosX * BetweenDist);
  Y := WinCenterY - (ButtonSize * DimY + (DimY - 1) * BetweenDist) div 2 + (ButtonSize * PosY + PosY * BetweenDist);
end;

{��������� ��� ����������� �������� ����}
procedure DrawField(DimX, DimY: integer);
var
  X, Y: integer;
  MyRoundRectABC: RoundRectABC;
begin
  if LeftTime < 1 then exit; // ���� ����� ����� - ���� �� ������
  
  Window.Clear;
  while Objects.Count > 0 do
    Objects[0].Destroy; // ���������� ������ ����������� ����
  
  // ������ ���� � ��������
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do // ����� �� ������� � �������� �������� ����
    begin
      GetButtonCoord(i, j, DimX, DimY, X, Y); // �������� ���������� ����������� ������
      MyRoundRectABC := new RoundRectABC(X, Y, ButtonSize, ButtonSize, 5, arrField[i, j].bColor); // ������� ������
      MyRoundRectABC.Text := arrField[i, j].Value.ToString; // ������ ����� �� ���
      MyRoundRectABC.dx := i; // ��������� ������� ����������� ������ � ������� ������� ������
      MyRoundRectABC.dy := j;
    end;
  
  // ����� �������
  SetFontSize(17);
  DrawTextCentered(10, 10, WinWidth - 10, 50, '�������� �������, ����� � ����� ����������:');
  SetFontSize(30);
  DrawTextCentered(10, 60, WinWidth - 10, 110, RightAnswer.ToString);
  
  // ������� ������� �������
  SetFontSize(30);
  DrawTextCentered(10, WinHeight - 100, WinWidth - 10, WinHeight - 60, '������� �������: ' + IntToStr(Level1) + '.' + IntToStr(Level2));
  
  // �������� ��������� ����
  isCanUseMouse := true;
end;

// ��������� ��� ����������� ���������� � ����� ����
procedure DrawResult(Msg: string; Lev1, Lev2: integer);
begin
  Window.Clear;
  while Objects.Count > 0 do
    Objects[0].Destroy; // ������� ��� ������� �������� ����
  
  SetFontSize(40);
  DrawTextCentered(10, WinCenterY - 180, WinWidth - 10, WinCenterY - 120, Msg); // ������� ��������� �� ���������
  SetFontSize(60);
  DrawTextCentered(10, WinCenterY - 30, WinWidth - 10, WinCenterY + 100, '��������� �������: ' + IntToStr(Lev1) + '.' + IntToStr(Lev2)); // ������� ��������� �������
end;

{��������� ��� ���������� �������� ����}
procedure PrepareField(DimX, DimY, DiffLevel: integer);
var
  bValue: integer; // ��� ����������� �������� �� ������
  raRnd: integer; // ��� ������ ��������� ������ � ����. ��� ����� � ���������� �������
  RndPrv: integer;// ����� ������ � ���������� ������� � ���������� ����
begin
  // ������ ������ � ����������
  for var i := 0 to maxDimX do
    for var j := 0 to maxDimY do
    begin
      arrField[i, j] := nil;
    end;
  
  RightAnswer := 0; // ���������� ��������� �����
  
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      bValue := random(DiffLevel * 10 - 1) + 1; // ���������� �������� ����� �� ������
      // ���������� ������
      arrField[i, j] := new cButton(bValue, clFloralWhite, false);
    end;
  
  // ���������� ������ � ���������� �������
  for var j := 0 to DimY - 1 do
  begin
    case j of
      0: raRnd := 1 + random(DimX - 1);// ���������� ��� ������� ����
    else begin
        // ��� ��������� �����
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

{ ���������� ������� ������ ������� � ����}
function PressedInRow(row: integer): shortint;
var
  nTmp: shortint;
begin
  nTmp := 0;
  for var i := 0 to N - 1 do
    if arrField[i, row].isPressed then nTmp += 1;
  result := nTmp;
end;

{ ���������� �������� ������� ������ � ����}
function PressedInRowValue(row: integer): integer;
begin
  for var i := 0 to N - 1 do
    if arrField[i, row].isPressed then begin
      result := arrField[i, row].Value;
      exit;
    end;
end;

{ ���������� ����� ������� ������ � �������� ����}
function PressedInRowNumber(row: integer): integer;
begin
  for var i := 0 to N - 1 do
    if arrField[i, row].isPressed then begin
      result := i;
      exit;
    end;
end;

{ ������� �������� �������� �������� ������}
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

{ �������� ��������� �������:
  - ���� ������� � ������ ���� - ��������� ���������� ����� �������}
function CheckAnswer: boolean;
var
  CurrentResult: integer;
  BlinkColor: Color;
begin
  CurrentResult := 0;
  
  // � ������ ���� ������� ������
  for var j := 0 to N - 1 do 
  begin
    if PressedInRow(j) = 0 then begin
      result := false;
      exit;
    end;
    CurrentResult += PressedInRowValue(j); // ������� ����� � �������
  end;
  
  // ���������, ��� � ���������� ���� ���������� � ��������� ������ �� > 1,
  // �.�. �������
  for var j := 1 to N - 1 do 
  begin
    if abs(PressedInRowNumber(j - 1) - PressedInRowNumber(j)) > 1 then begin
      BlinkColor := clRed;
      BlinkPressed(BlinkColor);
      result := false;
      exit;
    end;
  end;
  
  if CurrentResult = RightAnswer then begin// ����� � ������� ��������� � ���������
    result := true;
    BlinkColor := clGreen
  end
  else begin
    result := false;
    BlinkColor := clRed;
  end;
  BlinkPressed(BlinkColor);
end;

{ ������ ��� ������ � ���� - 
  ������ ��������� � ������� �����}
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

{ ��������, ��� ���� ����� � ������ �� �����}
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

// ���������� ��� ���� ������, ��� �� ������ � ������ � ��������� ����
procedure ClearChoose;
begin
  for var i := 0 to Objects.Count - 1 do
    if Objects[i] is RoundRectABC then begin
      arrField[Objects[i].dx, Objects[i].dy].SetIsPressed(false);
      if EnableCheat and arrField[Objects[i].dx, Objects[i].dy].isRightAns then arrField[Objects[i].dx, Objects[i].dy].SetColor(clAzure);
      Objects[i].Color := arrField[Objects[i].dx, Objects[i].dy].bColor;
    end;
end;

// ��������� ������� ������ ����
procedure MyMouseDown(x, y, mb: integer);
begin
  // ������ ����� ����
  if isCanUseMouse and (mb = 1) and (LeftTime > 0) then
  begin
    isCanUseMouse := false; // ��������� ��������� ����
    var ob := ObjectUnderPoint(x, y); // �������� �� ���������� ���� ������ ObjectABC
    if ob <> nil then begin
      if arrField[ob.dx, ob.dy].isPress then begin// ���� ������� ���������� �����
        arrField[ob.dx, ob.dy].SetIsPressed(false);
        arrField[ob.dx, ob.dy].SetColor(clFloralWhite);
        if EnableCheat and arrField[ob.dx, ob.dy].isRightAns then arrField[ob.dx, ob.dy].SetColor(clAzure);
      end else begin// ��������
        arrField[ob.dx, ob.dy].SetIsPressed(true);
        arrField[ob.dx, ob.dy].SetColor(clMoneyGreen);
      end;
      ob.Color := arrField[ob.dx, ob.dy].bColor;
      
      // �������� �� ����������� ������� � ���������� �����
      // ������� �� ������ ����� ������ � ����
      if PressedInRow(ob.dy) < 2 then begin
        if CheckAnswer then begin// ���������� ������� 
          {����������� ������� ���������� �������, ���������}
          Level2 += 1;
          if Level2 = 10 then begin// ���� ��� ������������ ������� �� ������� ������� ���� - ����������� ����
            Level2 := 1;
            Level1 += 1;
            M += 1;
            N += 1;
            if M > maxDimX then begin
              {������� ������������ �������}
              DrawResult('�� ������ ������������ �������!', Level1 - 1, 9);
            end;
          end;
          PrepareField(M, N, Level2); // �������������� ������ ��� ����� ������
          DrawField(M, N); // ������ ����
          
        end else if CheckedInAllRows then begin// ������� � ������ ����, �� ��� �� ������� ��� ��������� �� ���
          {����������, ��� ������}
          ClearChoose;
        end
      end else
        NotSingle(ob); // ������� ��� ������ � ����
    end;    
    isCanUseMouse := true; // �������� ��������� ����
  end;  
end;

// �������� ������
procedure Timer1;
begin
  // ������� ���������� �����
  SetBrushColor(clWhite);
  FillRectangle(WinWidth - 300, 50, WinWidth - 10, 90);
  LeftTime -= 1;
  SetFontSize(14);
  DrawTextCentered(WinWidth - 300, 50, WinWidth - 10, 90, '�������� �������: ' + IntToStr(LeftTime));  
  
  // ����� ����� - ������� ���������  
  if LeftTime = 0 then begin
    t.Stop;
    isCanUseMouse := false;
    DrawResult('����� �����������!', Level1, Level2);
  end;
end;

// ������ ����
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
  // ������� ����
  Window.Title := '������ ������!';
  SetWindowSize(WinWidth, WinHeight);
  
  // ������� ��������� ��������� � ���������  
  SetFontSize(32);
  DrawTextCentered(100, 10, WinWidth - 10, 140, '�������������� ���� "������ ������!"');
  SetFontSize(20);
  DrawTextCentered(10, 140, WinWidth - 10, 300, '���� ���� - ��������� �� ������� ��������� ������� �� ����� ������ ���� ���, ' + #13 + #10 +
                                                '����� ��� � ����� ���� �������� ���������. ' + #13 + #10 +
                                                '���� ������� �� �����.');
  StartButton := ButtonABC.Create(WinCenterX - 100, WinCenterY + 200, 200, 50, '������ ����', clFloralWhite);
  StartButton.OnClick := StartGame; 
  
end.