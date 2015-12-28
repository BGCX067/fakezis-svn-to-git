#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=teukerfile.ico
#AutoIt3Wrapper_outfile=\\fertibase\FERTISHARE\FakeZis\FakeZIS2.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;SERVER!! Start Me First !!!!!!!!!!!!!!!
#include <GUIConstants.au3>

; Set Some reusable info
; Set your Public IP address (@IPAddress1) here.
Dim $szIPADDRESS = @IPAddress1
Dim $nPORT = 9999
Dim $MainSocket = 0
Dim $varresponse = ""




; Create a GUI for messages
;==============================================
Dim $GOOEY = GUICreate("FakeZIS for FertiBase testing", 500, 670)


GUICtrlCreateLabel("IP:", 10, 13)
Dim $gIP = GUICtrlCreateInput($szIPADDRESS, 40, 10, 100, 20, $ES_READONLY)
GUICtrlCreateLabel("Port:", 150, 13)
Dim $gPORT = GUICtrlCreateInput($nPORT, 180, 10, 70, 20, 0x2000)

GUICtrlCreateLabel("Closing characters (ASCII code):", 10, 43)
Dim $cc1 = GUICtrlCreateInput("13", 180, 40, 30, 20, 0x0001)
Dim $cc2 = GUICtrlCreateInput("28", 220, 40, 30, 20, 0x0001)
Dim $cc3 = GUICtrlCreateInput("13", 260, 40, 30, 20, 0x0001)

Dim $btn_startzis = GUICtrlCreateButton("Start ZIS", 260, 10, 70, 20, $BS_DEFPUSHBUTTON)
Dim $btn_stopzis = GUICtrlCreateButton("Stop ZIS", 340, 10, 70, 20, $WS_DISABLED)

GUICtrlCreateLabel("Connection results:", 10, 80)
Dim $edit = GUICtrlCreateEdit("", 10, 100, 480, 100)

GUICtrlCreateLabel("String to return:", 10, 230)

Dim $textresponsefile = FileRead ( @scriptdir & "\response.txt" )
Dim $returnstring = GUICtrlCreateEdit( $textresponsefile, 10, 250, 480, 400)

GUICtrlCreateLabel("©2007 - Teuker Beheer BV", 380, 655)
GUICtrlSetFont(-1, 7, 400)
GUICtrlSetColor(-1, 0x0000ff)

GUISetState()




While 1
	;--basisloop

	$msg = GUIGetMsg()

	; BTN START
	;--------------------
	If $msg = $btn_startzis Then
		$nPORT = GUICtrlRead($gPORT)
		Dim $state = "running" ; reset state of listening loops.
		GUICtrlSetStyle($btn_startzis, $WS_DISABLED)
		GUICtrlSetStyle($btn_stopzis, $BS_DEFPUSHBUTTON)
		GUICtrlSetStyle($gPORT, $ES_READONLY)
		GUICtrlSetStyle($cc1, $ES_READONLY)
		GUICtrlSetStyle($cc2, $ES_READONLY)
		GUICtrlSetStyle($cc3, $ES_READONLY)
		GUICtrlSetData($edit, _
				"ZIS Started..." & _
				"Listening on port: " & $nPORT)
		Runzis()
	EndIf
	
	; GUI Closed
	;--------------------
	If $msg = $GUI_EVENT_CLOSE Then
		GUIDelete($GOOEY)
		Exit
	EndIf
	
	
WEnd



Func Runzis()
	
	; Start The TCP Services
	;==============================================
	TCPStartup()

	; Create a Listening "SOCKET".
	;   Using your IP Address and Port 33891.
	;==============================================
	$MainSocket = TCPListen($szIPADDRESS, $nPORT)

	; If the Socket creation fails, exit.
	If $MainSocket = -1 Then
		MsgBox(16, "Error", "TCP Socket cannot be opened.", 10)
		Exit
	EndIf

	
	While 1
		; Initialize a variable to represent a connection
		;==============================================
		Dim $ConnectedSocket = -1
		Dim $SendingSocket = -1


		;Wait for and Accept a connection
		;==============================================
		Do
			$ConnectedSocket = TCPAccept($MainSocket)
			$msg = GUIGetMsg()

			; GUI Closed
			;--------------------
			If $msg = $GUI_EVENT_CLOSE Then
				GUIDelete($GOOEY)
				Exit
			EndIf
			
			; STOP PRESSED
			;--------------------
			If $msg = $btn_stopzis Then
				StopZis()
				
				ExitLoop
			EndIf
			
		Until $ConnectedSocket <> -1


		; Get IP of client connecting
		Dim $szIP_Accepted = SocketToIP($ConnectedSocket)

		Dim $msg, $recv
		
		If $state = "stopped" Then ExitLoop
		
		; GUI Message Loop
		;==============================================
		While 1
			$msg = GUIGetMsg()

			; GUI Closed
			;--------------------
			If $msg = $GUI_EVENT_CLOSE Then
				GUIDelete($GOOEY)
				Exit
			EndIf
			
			; STOP PRESSED
			;--------------------
			If $msg = $btn_stopzis Then
				StopZis()
				
				ExitLoop
			EndIf
			
			
			
			

			; Try to receive (up to) 2048 bytes
			;----------------------------------------------------------------
			$recv = TCPRecv($ConnectedSocket, 2048)
			
			; If the receive failed with @error then the socket has disconnected
			;----------------------------------------------------------------
			If @error Then
				
				Switch @error
					Case "10054"
						GUICtrlSetData($edit, _
								$szIP_Accepted & " >> " & "Connection closed" & @CRLF & GUICtrlRead($edit))
					Case "-1"
						GUICtrlSetData($edit, _
								$szIP_Accepted & " >> " & "Connection closed" & @CRLF & GUICtrlRead($edit))
					Case Else
						GUICtrlSetData($edit, _
								$szIP_Accepted & " >> " & "Error " & @error & @CRLF & GUICtrlRead($edit))
				EndSwitch
				
				ExitLoop
				
			EndIf

			; Update the edit control with what we have received
			;----------------------------------------------------------------
			If $recv <> "" Then
				$QRDseg=StringMid($recv,StringInStr($recv,"QRD|"),99)
				$PatID=StringMid($QRDseg,StringInStr($QRDseg,"|","",8)+1,StringInStr($QRDseg,"|","",9)-StringInStr($QRDseg,"|","",8)-1)
				;$SendingSocket = TCPConnect ( $szIP_Accepted , $nPORT )
				GUICtrlSetData($edit, _
						"Open sending socket:" & " >> " & $ConnectedSocket & "(Err: " & @error & ")" & @CRLF & GUICtrlRead($edit))
				
				GUICtrlSetData($edit, _
						$szIP_Accepted & " >>> " & $recv & @CRLF & GUICtrlRead($edit))
				
				

				If $ConnectedSocket > -1 Then
					
					
					;veld vullen met return
					
					$QRDseg=StringMid($recv,StringInStr($recv,"MSH|"),99)
					$querytype=StringMid($QRDseg,StringInStr($QRDseg,"|","",8)+1,StringInStr($QRDseg,"|","",9)-StringInStr($QRDseg,"|","",8)-1)
					ConsoleWrite ("qtype " & $querytype)
					$varresponse = FileRead ( @scriptdir & "\"& $querytype & ".txt" )
			
					
					If $varresponse <> "" Then
						If StringLeft($patID,1) < 5 Then
							$gender="F"
						Else
							$gender="M"
						EndIf
						$reply = StringReplace(StringReplace($varresponse,"<<patnr>>",$patID),"<<gender>>",$gender)
					Else
						$reply = "No return string specified"
					EndIf
					
					GUICtrlSetData ( $returnstring , $varresponse )
					
					$closechars = ""
					If GUICtrlRead($cc1) <> "" Then $closechars = $closechars & Chr(GUICtrlRead($cc1))
					If GUICtrlRead($cc2) <> "" Then $closechars = $closechars & Chr(GUICtrlRead($cc2))
					If GUICtrlRead($cc3) <> "" Then $closechars = $closechars & Chr(GUICtrlRead($cc3))
					
					$ret = TCPSend($ConnectedSocket, $reply & $closechars)

					GUICtrlSetData($edit, _
							$szIP_Accepted & " << " & $ret & " characters returned (incl stop Chars)" & @CRLF & GUICtrlRead($edit))
					
				EndIf


				;TCPSend( $ConnectedSocket , "Ontvangen~~~~")
				;TCPSend($szIP_Accepted,"OntvangenSLUITEN" & @CRLF)
				
				
			EndIf
			

		WEnd
		;----------------------------------------------------------------
		;If $ConnectedSocket <> -1 Then TCPCloseSocket( $ConnectedSocket )

		;TCPShutDown()
	WEnd
	
EndFunc   ;==>Runzis
;--end RunZis



;--------------------------------------------------------------------
; Function to return IP Address from a connected socket.
;----------------------------------------------------------------------
Func SocketToIP($SHOCKET)
	Local $sockaddr = DllStructCreate("short;ushort;uint;char[8]")

	Local $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $SHOCKET, _
			"ptr", DllStructGetPtr($sockaddr), "int", DllStructGetSize($sockaddr))
	If Not @error And $aRet[0] = 0 Then
		$aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sockaddr, 3))
		If Not @error Then $aRet = $aRet[0]
	Else
		$aRet = 0
	EndIf
	
	#cs
	Local $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $SHOCKET, _
			"ptr", DllStructGetPtr($sockaddr), "int_ptr", DllStructGetSize($sockaddr))
	If Not @error And $aRet[0] = 0 Then
		$aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sockaddr, 3))
		If Not @error Then $aRet = $aRet[0]
	Else
		$aRet = 0
	EndIf
	#ce

	$sockaddr = 0

	Return $aRet
EndFunc   ;==>SocketToIP

Func OnAutoItExit()
	;ON SCRIPT EXIT close opened sockets and shutdown TCP service
	;----------------------------------------------------------------------
	;If $ConnectedSocket > -1 Then
	;   TCPSend( $ConnectedSocket, "~~bye" )
	;   Sleep(2000)
	;   TCPRecv( $ConnectedSocket,  512 )
	;   TCPCloseSocket( $ConnectedSocket )
	;EndIf
	StopZis()

EndFunc   ;==>OnAutoItExit

Func StopZis()
	$state = "stopped"
	GUICtrlSetData($edit, "ZIS Stopped." & @CRLF & GUICtrlRead($edit))
	GUICtrlSetStyle($gPORT, 0x2000)
	GUICtrlSetStyle($cc1, 0x0001)
	GUICtrlSetStyle($cc2, 0x0001)
	GUICtrlSetStyle($cc3, 0x0001)
	GUICtrlSetStyle($btn_stopzis, $WS_DISABLED)
	GUICtrlSetStyle($btn_startzis, $BS_DEFPUSHBUTTON)
	TCPCloseSocket($MainSocket)
	TCPShutdown()
	
EndFunc   ;==>StopZis