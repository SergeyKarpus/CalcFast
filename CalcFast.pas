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
    
    procedure SetIsPressed(isPress: boolean);// ������ ��� ��������, ��� ������ ������
    begin
      Self.isPress := isPress;
    end;
    
    procedure SetIsRightAnswer(isRightAns: boolean);// ������ ��� ��������, ��� ��� ������ � ���������� �������
    begin
      Self.isRightAns := isRightAns;
    end;
  
  public 
    // �����������
    constructor(val: integer; col: Color; isPress: boolean);
    begin
      Self.val := val;
      Self.col := col;
      Self.isPress := isPress;
    end;
    
    property Value: integer read val;// �������� Value ��������������� ������ � �����������
    property bColor: Color read col write SetColor;
    property IsPressed: boolean read isPress write SetIsPressed;
    property IsRightAnswer: boolean read isRightAns write SetIsRightAnswer;
  end;

var
  M, N: integer; // ������� �������� ���� � ������� �� ����������� � ���������
  arrField: array [0..maxDimX, 0..maxDimY] of cButton;// ������ � �������� �������� ����

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
  for var i := 0 to DimX - 1 do
    for var j := 0 to DimY - 1 do
    begin
      GetButtonCoord(i, j, DimX, DimY, X, Y);
      MyRoundRectABC := new RoundRectABC(X, Y, ButtonSize, ButtonSize, 5, arrField[i, j].bColor);
      MyRoundRectABC.Text := arrField[i, j].Value.ToString;
      MyRoundRectABC.dx := i; // ��������� ������� ����������� ������ � ������� ������� ������
      MyRoundRectABC.dy := j;
    end;
end;

{��������� ��� ���������� �������� ����}
procedure PrepareField(DimX, DimY, DiffLevel: integer);
var
  bValue: integer; // ��� ����������� �������� �� ������
  raRnd: integer; // ��� ������ ��������� ������ � ����. ��� ����� � ���������� �������
  RndPrv: integer;// ����� ������ � ���������� ������� � ���������� ����
begin
  // ������ ������
  for var i := 0 to maxDimX do
    for var j := 0 to maxDimY do
    begin
      arrField[i, j] := nil;
    end;
  
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
      0: raRnd := random(DimX);// ���������� ��� ������� ����
    else begin
        // ��� ��������� �����
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
  // ������ ����� ����
  if mb = 1 then
  begin
    var ob := ObjectUnderPoint(x, y); // ���������� ���� ������ ObjectABC
    if ob <> nil then begin
      {!!!!!!!!!!!!!!!!!!}
      ob.Color := clMoneyGreen;
    end;    
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