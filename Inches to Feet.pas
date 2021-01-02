Uses
   Windows,classes,Crt,SysUtils;
Var
   Clipboard_Stringlist,Output_Stringlist           : tstringList;
   Input,InputString,Previous_Input                 :AnsiString;
   Input_Inches,Calculation,Fraction                :Double;
   Inches,Feet,Numerator,Denominator,Inputchars,Num,
   BorlandIDEBlockType,MSDEVColumnSelect : Word;
   KeyInput                                         : Char;
   Vertical                                         :Boolean;

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
(**********************************************************)
(***               Remove All Spaces                    ***)
(**********************************************************)
Function NoSpaces(S:ANSIString):ANSIString;
Var
   X     : LongWord;
   Tmp   : ANSIString;
Begin
   Tmp:='';
   For X := 1 To Length(S) Do
      Begin
         If (S[X]<>' ') Then
            Begin
               Tmp:=Tmp+S[X];
            End;
      End;
   NoSpaces:=Tmp;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Value(VS:String):Double;
Var
   Errv : Integer;
   VOUT : Double;
Begin
   If VS<>'' Then
      Begin
         Val(NoSpaces(VS),VOUT,errv);
         If errv=0 then
            Begin
               If VOUT = -0 then VOUT :=0;
               Value:=VOUT;
            End;
      End
   Else
      Value:=0
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
function GetWinClipBoardData(Fmt_ID:Word;var p : pchar;var l : longint) : boolean;
var
  h : HGlobal;
  pp : pchar;
begin
  p:=nil;
  GetWinClipBoardData:=False;
  h:=GetClipboardData(Fmt_ID);
  if h<>0 then
    begin
      pp:=pchar(GlobalLock(h));
      l:=strlen(pp)+1;
      getmem(p,l);
      move(pp^,p^,l);
      GlobalUnlock(h);
    end;
  GetWinClipBoardData:=h<>0;
end;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
function GetTextWinClipBoardData(var p : pchar;var l : longint) : boolean;
var
  h : HGlobal;
  pp : pchar;
begin
  p:=nil;
  GetTextWinClipBoardData:=False;
  if not OpenClipboard(0) then
    exit;
  h:=GetClipboardData(CF_OEMText);
  if h<>0 then
    begin
      pp:=pchar(GlobalLock(h));
      l:=strlen(pp)+1;
      getmem(p,l);
      move(pp^,p^,l);
      GlobalUnlock(h);
    end;
  GetTextWinClipBoardData:=h<>0;
  CloseClipboard;
end;


function SetTextWinClipBoardData(Vertical:Boolean;p : pchar;l : longint) : boolean;
var
  h : HGlobal;
  pp,q : pchar;
  res : boolean;
begin
  SetTextWinClipBoardData:=False;
  if (l=0) or (l>65520) then
    exit;
  if not OpenClipboard(0) then
    exit;
  EmptyClipBoard;
  h:=GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE,l+1);
  pp:=pchar(GlobalLock(h));
  move(p^,pp^,l+1);
  GlobalUnlock(h);
  res:=(SetClipboardData(CF_OEMTEXT,h)=h);
  h:=GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE,l+1);
  pp:=pchar(GlobalLock(h));
  OemToCharBuffA(p,pp,l+1);
  SetClipboardData(CF_TEXT,h);
  GlobalUnlock(h);
  If Vertical then
    Begin
      q:=#0;
      q:=StrAlloc(0);
      h:=GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE,l+1);
      pp:=pchar(GlobalLock(h));
      move(q^,pp^,l+1);
      SetClipboardData(MSDEVColumnSelect,h);
      GlobalUnlock(h);
      q:=#2#0;
      h:=GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE,l+1);
      pp:=pchar(GlobalLock(h));
      move(q^,pp^,l+1);
      SetClipboardData(BorlandIDEBlockType,h);
      GlobalUnlock(h);
    End;
  SetTextWinClipBoardData:=res;
  CloseClipBoard;
end;

Function GetClipboard_in_Tstringlist(Var Clipboard_SL: Tstringlist):DWord;
Var
   Clipdata: Pchar;
   Clipboard_Line:ansistring;
   clp,ClipLength:Longint;
Begin
   ClipData:='';
   ClipLength:=0;
   GetTextWinClipBoardData(Clipdata,ClipLength);
   Clipboard_Line:='';
   for clp:= 0 to ClipLength - 1 do
      Begin
         If (Clipdata[clp]<> #0) and (Clipdata[clp]<> #13) Then
            Begin
               If (Clipdata[clp]<> #10) Then
                  Clipboard_Line:=Clipboard_Line+Clipdata[clp];
            End
         else
            Begin
               If Clipboard_Line <> #0 Then
                  Clipboard_SL.add(Clipboard_Line);
               Clipboard_Line:='';
            End;
      End;
   GetClipboard_in_Tstringlist:=ClipLength;
End;

Function SetClipboard_in_Tstringlist(Vertical:Boolean;Var Clipboard_SL: Tstringlist):Boolean;
Var
   Clipdata: Pchar;
   Clipline:ansistring;
   clp,ClipLength:Longint;
Begin
   Clipline:='';
   For clp := 0 to Clipboard_SL.Count-1 do
      Begin
         Clipline:=Clipline+Clipboard_SL[clp];
         If clp<Clipboard_SL.Count-1 Then
            Clipline:=Clipline+#13;
      End;
   ClipData:=Pchar(Clipline+#0#0);
   Cliplength:=Length(Clipdata);
   SetClipboard_in_Tstringlist:=SetTextWinClipBoardData(Vertical,Clipdata,ClipLength);
End;

Procedure ShowClipboard(Var Clipboard_SL: Tstringlist);
Var
   clp:Longint;
Begin
   Textcolor(15);
   Write('Clipboard Size: ');
   Textcolor(10);
   Writeln(Clipboard_SL.count,' Lines ');
   For clp := 0 to Clipboard_SL.Count-1 do
      Begin
         Textcolor (14);
         Write(clp);
         Textcolor(12);
         Write('|');
         Textcolor(9);
         Write(Clipboard_SL[clp]);
         Textcolor(12);
         Writeln('|');
      End;
End;

Function Vertical_Edit(Verbose:Boolean):Boolean;
Type
   BT = Record
      BT_ID: Byte;
      BT_Name: String;
   End;

Const
Builtin_Type: Array [0..22] of BT = (
{ 0} (BT_ID:2   ;BT_Name:'CF_BITMAP'         ),
{ 1} (BT_ID:8   ;BT_Name:'CF_DIB'            ),
{ 2} (BT_ID:17  ;BT_Name:'CF_DIBV5'          ),
{ 3} (BT_ID:5   ;BT_Name:'CF_DIF'            ),
{ 4} (BT_ID:130 ;BT_Name:'CF_DSPBITMAP'      ),
{ 5} (BT_ID:142 ;BT_Name:'CF_DSPENHMETAFILE' ),
{ 6} (BT_ID:131 ;BT_Name:'CF_DSPMETAFILEPICT'),
{ 7} (BT_ID:129 ;BT_Name:'CF_DSPTEXT'        ),
{ 8} (BT_ID:14  ;BT_Name:'CF_ENHMETAFILE'    ),
{ 9} (BT_ID:15  ;BT_Name:'CF_HDROP'          ),
{10} (BT_ID:16  ;BT_Name:'CF_LOCALE'         ),
{11} (BT_ID:18  ;BT_Name:'CF_MAX'            ),
{12} (BT_ID:3   ;BT_Name:'CF_METAFILEPICT'   ),
{13} (BT_ID:7   ;BT_Name:'CF_OEMTEXT'        ),
{14} (BT_ID:128 ;BT_Name:'CF_OWNERDISPLAY'   ),
{15} (BT_ID:9   ;BT_Name:'CF_PALETTE'        ),
{16} (BT_ID:10  ;BT_Name:'CF_PENDATA'        ),
{17} (BT_ID:11  ;BT_Name:'CF_RIFF'           ),
{18} (BT_ID:4   ;BT_Name:'CF_SYLK'           ),
{19} (BT_ID:1   ;BT_Name:'CF_TEXT'           ),
{20} (BT_ID:6   ;BT_Name:'CF_TIFF'           ),
{21} (BT_ID:13  ;BT_Name:'CF_UNICODETEXT'    ),
{22} (BT_ID:12  ;BT_Name:'CF_WAVE'           ));

Var
   i,j,k,l,Number_Of_Formats,Name_Length : Byte;
   m                                     : Dword;
   FormatID                              : Word;
   Format_ID                             : Array of Word;
   FN                                    : Array[0..255] of Byte;
   Format_Name                           : Array of AnsiString;
   Clipdata                              : Array of Pchar;
   ClipLength                            : Array of Longint;

Begin
   Vertical_Edit:=False;
   OpenClipboard(0);
   Number_Of_Formats := CountClipboardFormats();
   If Verbose Then
      Writeln('Number of formats: ',Number_Of_Formats);
   SetLength(Format_ID,Number_Of_Formats);
   SetLength(Format_Name,Number_Of_Formats);
   SetLength(ClipData,Number_Of_Formats);
   SetLength(Cliplength,Number_Of_Formats);
   If (Number_Of_Formats>=1) and (Number_Of_Formats<=255) Then
      Begin
         for i := 0 to Number_Of_Formats-1 do
            Begin
               Format_Name[i] := 'FAILED';
               FormatID:=EnumClipboardFormats(FormatID);
               Format_ID[i]:=FormatID;
               For J:= 0 to 22 do
                  Begin
                     If Format_ID[i] = Builtin_Type[J].BT_ID then
                        Format_Name[i] := Builtin_Type[J].BT_Name;
                  End;
               If Format_Name[i] = 'FAILED' Then
                  Begin
                     Name_Length:=GetClipboardFormatName(Format_Id[i],LPTSTR(@FN[0]),255);
                     If Name_Length >0 Then
                        Begin
                           Format_Name[i]:='';
                           For k:= 0 to Name_Length-1 Do
                              Format_Name[i]:=Format_Name[i]+Chr(FN[k]);
                        End;
                  End;
               If Format_Name[i] = 'Borland IDE Block Type' then
                  Begin
                     Vertical_Edit:=True;
                     BorlandIDEBlockType:=Format_ID[i];
                  End;
               If Format_Name[i] = 'MSDEVColumnSelect' then
                  Begin
                     Vertical_Edit:=True;
                     MSDEVColumnSelect:=Format_ID[i];
                  End;
            End;
         If Verbose Then
            Begin
               For i := 0 to Number_Of_Formats-1 do
                  Begin
                     ClipData[i]:='';
                     ClipLength[i]:=0;
                     GetWinClipBoardData(Format_ID[i],Clipdata[i],ClipLength[i]);
                     Writeln(Format_ID[i],' ',Format_Name[i]);
                        m:=ClipLength[i];
                        if m>=256 then
                           m:=255;
                        If  m>= 1 then
                           Begin
                              for l:= 0 to m - 1 do
                                 Write('#',ORD(ClipData[i][l]),' ');
                              Writeln;
                              Write('|');
                              for l:= 0 to m - 1 do
                                 Write((ClipData[i][l]));
                              Writeln('|');
                           End
                        Else
                           Writeln('||');
                  End;
            End
         Else
            If Verbose Then
               Writeln('Clipboard Empty');
      End;
CloseClipboard();
End;


Function Convert_To_Feet_Inches_and_Fractions(Input_String:AnsiString):AnsiString;
Begin
   Convert_To_Feet_Inches_and_Fractions:='';
   Calculation:=Value(Input_String);
   If Calculation>0.0000000000001 Then
      Begin
         //Writeln(Calculation:0:5);
         Feet:=Trunc(Calculation/12);
         Inches:=Trunc(Calculation)-(Feet*12);
         Fraction:=Frac(Calculation);
         Numerator:=Round(Fraction*16);
         If Odd(Numerator) Then
            Denominator := 16
         Else
            Case(Numerator) of
            2:Begin
                  Numerator:= 1;
                  Denominator:=8;
               End;
            4:Begin
                  Numerator:= 1;
                  Denominator:=4;
               End;
            6:Begin
                  Numerator:= 3;
                  Denominator:=8;
               End;
            8:Begin
                  Numerator:= 1;
                  Denominator:=2;
               End;
            10:Begin
                  Numerator:= 5;
                  Denominator:=8;
               End;
            12:Begin
                  Numerator:= 3;
                  Denominator:=4;
               End;
            14:Begin
                  Numerator:= 7;
                  Denominator:=8;
               End;
            16:Begin
                  Numerator:= 0;
                  Denominator:=0;
                  Inc(Inches);
               End;

            End;
         If (Numerator > 0) and (Denominator > 0) then
            Begin
               Writeln(Calculation:0:5 ,' Inches = ',Feet,''' ',Inches,'-',Numerator,'/',Denominator,'"');
               Convert_To_Feet_Inches_and_Fractions:=' = '+inttostr(Feet)+''' '+inttostr(Inches)+'-'+inttostr(Numerator)+'/'+InttoStr(Denominator)+'"';
            End
         Else
            Begin
               Writeln(Calculation:0:5 ,' Inches = ',Feet,''' ',Inches,'"');
               Convert_To_Feet_Inches_and_Fractions:=' = '+inttostr(Feet)+''' '+inttostr(Inches)+'"';
            End;
      End;
End;
Begin
   Previous_Input:='';
   Clipboard_Stringlist:=TStringlist.Create;
      Output_Stringlist:=TStringlist.Create;
   Repeat
      If Keypressed then
         Begin
            Textcolor(11);
            InputString := '';
            Repeat
               KeyInput:=ReadKey;
               If ((KeyInput >= '0') And (KeyInput <= '9')) or (Keyinput ='.') or (Keyinput ='-') Then
                  Begin
                     InputString:=InputString+KeyInput;
                     Write(KeyInput);
                  End;
               if KeyInput = #27 Then
                  Halt;
            Until Keyinput=#13;
            Writeln;
            If (InputString <> '') Then
               Begin
                  Output_Stringlist.Clear;
                  Output_Stringlist.add(InputString+Convert_To_Feet_Inches_and_Fractions(InputString));
                  SetClipboard_in_Tstringlist(False,Output_Stringlist);
               End;
         End;
      Clipboard_Stringlist.Clear;
      InputChars:=GetClipboard_in_Tstringlist(Clipboard_Stringlist);
      Vertical:=Vertical_Edit(False);
      If (InputChars>0) Then
         Begin
            //Writeln('clip in',Clipboard_Stringlist[0],'  prev',Previous_Input);
            If (Clipboard_Stringlist[0]<>Previous_Input) Then
               Begin
                  If Vertical Then
                     Writeln('Vertical');
                  If (Value(Clipboard_Stringlist[0])>0.0000000000001) then
                     Begin
                        //Writeln('Value',Value(Clipboard_Stringlist[0]):0:30);
                        Textcolor(10);
                        Writeln(InputChars,' Characters received from Clipboard');
                        ShowClipboard(Clipboard_Stringlist);
                        Output_Stringlist.Clear;
                        For Num:= 0 to Clipboard_Stringlist.Count-1 Do
                           Begin
                              Output_Stringlist.add(Clipboard_Stringlist[Num]+Convert_To_Feet_Inches_and_Fractions(Clipboard_Stringlist[Num]));
                           End;
                        //ShowClipboard(Output_Stringlist);
                        SetClipboard_in_Tstringlist(Vertical,Output_Stringlist);
                        Previous_Input:=Output_Stringlist[0];
                     End
                  Else
                     Previous_Input:=Clipboard_Stringlist[0];
               End;
         End;
      Sleep(500);
   Until 1=0;
   Clipboard_Stringlist.free;
   Output_Stringlist.free;
end.
