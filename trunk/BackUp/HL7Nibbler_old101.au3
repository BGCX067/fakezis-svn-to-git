#include <GUIConstants.au3>
#include <date.au3>
#include <INet.au3>
#include <array.au3>
#include <GUIComboBox.au3>
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=e:\data\icons\fertibase_document.ico
#AutoIt3Wrapper_Outfile=HL7 Nibbler.exe
#AutoIt3Wrapper_Res_Comment=Tijdschrijven zonder gedoe...
#AutoIt3Wrapper_Res_Description=You're asking to describe the undescribable
#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=Teuker Beheer Riel (BC) B.V.
#AutoIt3Wrapper_Res_Language=1043
#AutoIt3Wrapper_Res_Icon_Add=e:\data\icons\fertibase_document.ico
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/tc 2 /rel
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;
;________ DECLARATIONS __________________________________________________________________________
;
Dim $r_bit, $r_nibble, $r_part, $r_segment, $temp
Dim $debug = 1
If $debug = 1 Then
  Dim $debugfile = FileOpen(@ScriptDir & "\nibbler.debug", 1)
EndIf
;
;________ INTERFACE __________________________________________________________________________
;
$Form1 = GUICreate("HL7 Nibbler 0.1", 633, 447, 192, 124)
$i_response = GUICtrlCreateEdit("", 8, 192, 617, 241)
Dim $returnFile
$returnFile = FileRead(@ScriptDir & "\QRY^Q01_2.4.txt")
GUICtrlSetData($i_response, $returnFile)
$i_segment = GUICtrlCreateInput("", 80, 40, 40, 21)
$i_segRep = GUICtrlCreateInput("", 172, 40, 40, 21)
$i_part = GUICtrlCreateInput("", 80, 72, 40, 21)
$i_bit = GUICtrlCreateInput("", 80, 104, 40, 21)
$i_nibble = GUICtrlCreateInput("", 80, 136, 40, 21)
$r_segment = GUICtrlCreateInput("", 224, 40, 393, 21)
$r_part = GUICtrlCreateInput("", 224, 72, 393, 21)
$r_bit = GUICtrlCreateInput("", 224, 104, 393, 21)
$r_nibble = GUICtrlCreateInput("", 224, 136, 393, 21)
GUICtrlCreateLabel("Segment", 25, 40, 46, 17)
GUICtrlCreateLabel("Occ.", 135, 40, 35, 17)
GUICtrlCreateLabel("Part", 25, 72, 23, 17)
GUICtrlCreateLabel("Bit", 25, 104, 16, 17)
GUICtrlCreateLabel("Nibble", 25, 136, 34, 17)
GUICtrlCreateLabel("Enter the segments you would like to see", 10, 8, 237, 17)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlCreateLabel("Paste the HL7 response below", 10, 168, 177, 17)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)
While 1
  $nMsg = GUIGetMsg()
  Switch $nMsg
    Case $GUI_EVENT_CLOSE
      Exit
    Case $i_response
      _parse()
    Case $i_bit
      _parse()
    Case $i_nibble
      _parse()
    Case $i_part
      _parse()
    Case $i_segment
      _parse()
  EndSwitch
WEnd
;________ FUNCTIONS __________________________________________________________________________
;
Func _parse()
  ; ---- PARSE THA BEAST
  ; set returnfile
  Local $returnFile
  $returnFile = FileRead(@ScriptDir & "\QRY^Q01_2.4.txt")
  Local $startSeg
  Local $endSeg
  Dim $pid
  Dim $parts[100], $part, $partnum
  Dim $bits[100], $bit, $bitnum
  Dim $nibbles[100], $nibble, $nibblenum
  ; get gui values
  Local $resp = GUICtrlRead($i_response)
  GUICtrlSetData($i_response, $returnFile)
  Local $segment = GUICtrlRead($i_segment)
  Local $seg_occ = GUICtrlRead($i_segRep)
  Local $part = GUICtrlRead($i_part)
  Local $bit = GUICtrlRead($i_bit)
  Local $nibble = GUICtrlRead($i_nibble)
  ; get number of segments
  $numSeg = StringInStr($resp, $segment)
  _log("number of segments", $numSeg)
  If $numSeg > 0 And GUICtrlRead($i_segment) <> "" Then
    ; we have the segment
    $startSeg = $numSeg
    $line = StringMid($resp, $startSeg, 999)
    _log("line", $line)
    ; reduce to first chr(13)
    $endSeg = StringInStr($line, Chr(13))
    _log("endseg", $endSeg)
    $line = StringMid($resp, $startSeg, $endSeg)
    _log("SEGMENT", $line)
    GUICtrlSetData($r_segment, $line)
    ; get the part
    $parts = StringSplit($line, "|")
    ;_ArrayDisplay($parts)
    $partnum = GUICtrlRead($i_part) + 1
    If StringInStr($line, "|") > 0 And GUICtrlRead($i_part) <> "" and $parts[0] >= $partnum Then
      _log("partnum", $partnum)
      $part = $parts[$partnum]
      _log("part", $part)
      GUICtrlSetData($r_part, $part)
      ;
      ; get the bit
      $bits = StringSplit($part, "^")
      ;_ArrayDisplay($bits)
      $bitnum = GUICtrlRead($i_bit) + 1
      If StringInStr($part, "^") > 0 And GUICtrlRead($i_bit) <> "" And $bits[0] >= $bitnum Then
        _log("bitnum", $bitnum)
        $bit = $bits[$bitnum]
        _log("bit", $bit)
        GUICtrlSetData($r_bit, $bit)
        ;
        ; get nibbles
        $nibbles = StringSplit($bit, "&")
        ;_ArrayDisplay($nibbles)
        $nibblenum = GUICtrlRead($i_nibble) + 1
        If StringInStr($bit, "&") > 0 And GUICtrlRead($i_nibble) <> "" And $nibbles[0] >= $nibblenum Then
          _log("nibblenum", $nibblenum)
          $nibble = $nibbles[$nibblenum]
          _log("nibble", $nibble)
          GUICtrlSetData($r_nibble, $nibble)
        Else
          ; no nibble
          Select
            Case $nibblenum = ""
              GUICtrlSetData($r_nibble, "")
            Case $nibbles >= $nibblenum
              GUICtrlSetData($r_nibble, "-- nibble " & $nibblenum - 1 & " out of bounds--")
            Case Else
              GUICtrlSetData($r_nibble, "--")
          EndSelect
        EndIf
      Else
        ; no bit
        Select
          Case $bitnum = ""
            GUICtrlSetData($r_bit, "")
          Case $bits >= $bitnum
            GUICtrlSetData($r_bit, "-- nibble " & $bitnum - 1 & " out of bounds--")
          Case Else
            GUICtrlSetData($r_bit, "--")
        EndSelect
        ;GUICtrlSetData($r_bit, "-- no bit " & $bitnum - 1 & " found--")
      EndIf
    Else
      ; no part
      GUICtrlSetData($r_part, "-- no part " & $partnum - 1 & " found--")
    EndIf
  Else
    ;; no segment found
    GUICtrlSetData($r_segment, "-- no segment " & $segment & " found --")
  EndIf
EndFunc   ;==>_parse
;
;---- LOG
;
Func _log($what, $value = "")
  If $debug = 1 Then
    $data = @YEAR & @MON & @MDAY & "@" & @HOUR & @MIN & " - " & $what & " (Err:" & @error & " Value: " & $value & ")" & @CRLF
    ConsoleWrite($data)
    FileWriteLine($debugfile, $data)
  EndIf
EndFunc   ;==>_log
