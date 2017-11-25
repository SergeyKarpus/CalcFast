uses GraphABC, ABCObjects;
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
    
    property Value: integer read val;// �������� Value ��������������� ������ � �����������
    property bColor: Color read col write SetColor;
    property IsPressed: boolean read isPress write SetIsPressed;
    property IsRightAnswer: boolean read isRightAns write SetIsRightAnswer;
  end;

var
  M, N: integer; // ������� �������� ���� � ������� �� ����������� � ���������
  arrField: array [0..maxDimX, 0..maxDimY] of cButton; // ������ � �������� �������� ����
  RightAnswer: integer; // ������� ���������� �����
  isCanUseMouse: boolean;// ����, ��� ������ ����� ������������ ������� ����

// ����������� �������� ���� - ������ �� 3*3 �� n*m
//   �������� �� ����� ����������� � �������� �������� �� ����������
// ��� ������� �� ������ ������ ���� �� �������

{
TODO:
�������� �� ��������� ���
������ �������, ���� ��� ������
������ ������ ������ ��� ����������/������������ ������
�������� �����������
���� �� �����
������
}

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
  // ������ ���� � ��������
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      GetButtonCoord(i, j, DimX, DimY, X, Y);
      MyRoundRectABC := new RoundRectABC(X, Y, ButtonSize, ButtonSize, 5, arrField[i, j].bColor);
      MyRoundRectABC.Text := arrField[i, j].Value.ToString;
      MyRoundRectABC.dx := i; // ��������� ������� ����������� ������ � ������� ������� ������
      MyRoundRectABC.dy := j;
    end;
  
  // ����� �������
  SetFontSize(17);
  DrawTextCentered(10, 10, WinWidth - 10, 50, '�������� �������, ����� � ����� ����������:');
  SetFontSize(30);
  DrawTextCentered(10, 60, WinWidth - 10, 110, RightAnswer.ToString);
  
  // �������� ��������� ����
  isCanUseMouse := true;
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
  RightAnswer := 0;
  
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      bValue := random(DiffLevel * 10 - 1) + 1;
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
  
end;

procedure MyMouseDown(x, y, mb: integer);
begin
  // ������ ����� ����
  if isCanUseMouse and (mb = 1) then
  begin
    isCanUseMouse := false; // ��������� ��������� ����
    var ob := ObjectUnderPoint(x, y); // ���������� ���� ������ ObjectABC
    if ob <> nil then begin
      arrField[ob.dx, ob.dy].SetIsPressed(true);
      arrField[ob.dx, ob.dy].SetColor(clMoneyGreen);
      ob.Color := arrField[ob.dx, ob.dy].bColor;
      
      // ������� �� ������ ����� ������ � ����
      if PressedInRow(ob.dy) < 2 then begin
        if CheckAnswer then begin
          {!!!!!!!!!!!!!!}
        end;
      end else
        NotSingle(ob);
      
      {!!!!!!!!!!!!!!!!!!!!!!!!!}
    end;    
    isCanUseMouse := true; // �������� ��������� ����
  end;  
end;

begin
  Window.Title := '������ ������!';
  SetWindowSize(WinWidth, WinHeight);
  OnMouseDown := MyMouseDown;
  
  M := 5;N := 5;
  PrepareField(M, N, 1);
  DrawField(M, N);
  
end.