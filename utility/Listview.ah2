; ======================================================================================================================
; Namespace:      ListViewExtensions
; Function:       Add some more or less useful methods to Gui.ListView controls.
;                 Most of them just wrap the common list view control messages.
;                 For the purpose and the usage of the messages see:
;                 https://docs.microsoft.com/en-us/windows/win32/controls/bumper-list-view-control-reference-messages
;                 To add the methods
;                 -  create a Gui.ListView control:
;                    LV := Gui.AddListView("...", "...")
;                 -  set ListViewExtensions.Prototype as the base of this control:
;                    LV.Base := ListViewExtensions.Prototype
;                 -  or call the helper function ListViewExtensions_Add(LV).
; Tested with:    AHK 2.0-beta.1
; Tested on:      Win 10 (x64)
; Changelog:
;     0.0.00.00/20210925/just me     -  initial alpha release.
; Notes:
;     In terms of Microsoft
;        Item     stands for the whole row or the first column of the row
;        SubItem  stands for the second to last column of a row
; Credits:
;     Thanks to
;     -  TheArkive for GuiControl_Ex showing me the basic concepts.
;        -> www.autohotkey.com/boards/viewtopic.php?f=83&t=86124
;     LV_EX tile view functions:
;        Initial idea by segalion (old forum: /board/topic/80754-listview-with-multiline-in-report-mode-help/)
;        based on code from Fabio Lucarelli (http://users.skynet.be/oleole/ListView_Tiles.htm).
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; Adds the extensions to an existing ListView control.
ListViewExtensions_Add(LV) {
   LV.Base := ListViewExtensions.Prototype
}
; ======================================================================================================================
Class ListViewExtensions Extends Gui.ListView {
   ; ===================================================================================================================
   ; Type shown by GuiControl.Type
   ; ===================================================================================================================
   Type => "ListViewX"
   ; ===================================================================================================================
   ; Additional methods
   ; ===================================================================================================================
   ; Calculates the approximate width and height required to display a given number of items.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-approximateviewrect
   CalcViewSize(Rows := 0) {
      Local Size
      Size := DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1040, "Ptr", Rows - 1, "Ptr", 0, "UInt")
      Return {W: (Size & 0xFFFF), H: (Size >> 16) & 0xFFFF}
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Enables or disables whether the items in a list-view control display as a group.
   EnableGroupView(Enable := True) {
      Return !(DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x109D, "Ptr", !!Enable, "Ptr", 0, "Int") < 0)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Searches the first column for an item containing the specified string.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-finditem
   FindString(Str, Start := 0, Partial := False) {
      Static SizeOfLVFI := 40
      LVFI := Buffer(SizeOfLVFI, 0)
      Flags := 0x0002 ; LVFI_STRING
      If (Partial)
         Flags |= 0x0008 ; LVFI_PARTIAL
      NumPut("UInt", Flags, LVFI)
      NumPut("Ptr", StrPtr(Str),  LVFI, A_PtrSize)
      Return (DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1053, "Ptr", Start - 1, "Ptr", LVFI, "Int") + 1)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Searches all columns or the specified column for a subitem containing the specified string.
   FindStringEx(Str, Column := 0, Start := 0, Partial := False) {
      If !IsInteger(Column) || (Column < 0) || (Column > This.GetCount("Col"))
         Throw ValueError("Parameter Column is invalid!", A_ThisFunc, Column)
      If !IsInteger(Start) || (Start < 0)
         Throw ValueError("Parameter Start is invalid!", A_ThisFunc, Start)
      Len := StrLen(Str)
      Row := Col := 0
      ItemList := ListViewGetContent("", This.HWND)
      Loop Parse, ItemList, "`n"
      {
         If (A_Index > Start) {
            Row := A_Index
            Columns := StrSplit(A_LoopField, "`t")
            If (Column > 0) {
               If (Partial) {
                  If (SubStr(Columns[Column], 1, Len) = Str)
                     Col := Column
               }
               Else {
                  If (Columns[Column] = Str)
                     Col := Column
               }
            }
            Else {
               For Index, ColumnText In Columns {
                  If (Partial) {
                     If (SubStr(ColumnText, 1, Len) = Str)
                        Col := Index
                  }
                  Else {
                     If (ColumnText = Str)
                        Col := Index
                  }
               } Until (Col > 0)
            }
         }
      } Until (Col > 0)
      Return (Col > 0) ? {Row: Row, Col: Col} : 0
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the background color of a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getbkcolor
   GetBkColor() {
      BC := DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1000, "Ptr", 0, "Ptr", 0, "UInt")
      Return Format("0x{:06X}", ((BC & 0x0000FF) << 16) | (BC & 0X00FF00) | ((BC & 0xFF0000) >> 16))
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the current left-to-right order of columns in a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getcolumnorderarray
   GetColumnOrder() {
      Cols := This.GetCount("Col")
      COA := Buffer(Cols * 4, 0)
      If !DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x103B, "Ptr", Cols, "Ptr", COA, "UInt")
         Return False
      ColArray := []
      Off := -4
      Loop Cols
         ColArray.Push(NumGet(COA, Off += 4, "Int") + 1)
      Return ColArray
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the width of a column in report or list view.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getcolumnwidth
   GetColumnWidth(Column) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x101D, "Ptr", Column - 1, "Ptr", 0, "Int")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; GetEditControl     -> 0x1018 - not supported as yet
   ; GetEmptyText       -> 0x10CC - not supported as yet
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the extended styles that are currently in use for a given list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getextendedlistviewstyle
   GetExtendedStyle() {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1037, "Ptr", 0, "Ptr", 0, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; GetFocusedGroup    -> 0x105D - not supported as yet
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the ID of the group the list-view item belongs to.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitem
   GetGroup(Row) {
      Static OffGroupID := 28 + (A_PtrSize * 3)
      This.Create_LVITEM(&LVITEM, 0x00000100, Row) ; LVIF_GROUPID
      DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104B, "Ptr", 0, "Ptr", LVITEM, "UInt")
      Return NumGet(LVITEM, OffGroupID, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the handle of the header control used by the list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getheader
   GetHeader() {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Determines the spacing between icons in the icon view.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitemspacing
   GetIconSpacing(SmallIcon := 1, &CX := 0, &CY := 0) {
      CX := CY := 0
      SP := DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1033, "Ptr", !!SmallIcon, "Ptr", 0, "UInt")
      CX := SP & 0xFFFF, CY := (SP >> 16) & 0xFFFFF
      Return SP
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the value of the item's lParam field.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitem
   GetItemParam(Row) {
      Static OffParam := 24 + (A_PtrSize * 2)
      This.Create_LVITEM(&LVITEM, 0x00000004, Row) ; LVIF_PARAM
      DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104B, "Ptr", 0, "Ptr", LVITEM, "UInt")
      Return NumGet(LVITEM, OffParam, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the bounding rectangle for all or part of an item in the current view.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitemrect
   GetItemRect(Row := 1, LVIR := 0, &RECT := "") {
      RECT := Buffer(16, 0)
      NumPut("Int", LVIR, RECT)
      If !DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x100E, "Ptr", Row - 1, "Ptr", RECT, "UInt")
         Return False
      Result := {}
      Result.X := NumGet(RECT,  0, "Int"), Result.Y := NumGet(RECT,  4, "Int")
      Result.R := NumGet(RECT,  8, "Int"), Result.B := NumGet(RECT, 12, "Int")
      Result.W := Result.R - Result.X,     Result.H := Result.B - Result.Y
      Return Result
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the state of a list-view item.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getitemstate
   ; LVITEM state
   ; LVIS_FOCUSED            = 0x0001
   ; LVIS_SELECTED           = 0x0002
   ; LVIS_CUT                = 0x0004
   ; LVIS_DROPHILITED        = 0x0008
   ; LVIS_CHECKED            = 0x2000  ; not defined by MS
   GetItemState(Row, StateMask := 0x200F) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x102C, "Ptr", Row - 1, "Ptr", StateMask & 0x200F, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the height of the specified row.
   GetRowHeight(Row := 1) {
      Return This.GetItemRect(Row).H
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Calculates the number of items that can fit vertically in the visible area of a list-view
   ; control when in list or report view. Only fully visible items are counted.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getcountperpage
   GetRowsPerPage() {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1028, "Ptr", 0, "Ptr", 0, "Int")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves information about the bounding rectangle for a subitem in a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getsubitemrect
   GetSubItemRect(Column, Row := 1, LVIR := 0, &RECT := "") {
      RECT := Buffer(16, 0)
      NumPut("Int", LVIR, "Int", Column - 1, RECT)
      If !DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1038, "Ptr", Row - 1, "Ptr", RECT, "UInt")
         Return False
      If (Column = 1) && ((LVIR = 0) || (LVIR = 3))
         NumPut("Int", NumGet(RECT, 0, "Int") + This.GetColumnWidth(1), RECT, 8)
      Result := {}
      Result.X := NumGet(RECT,  0, "Int"), Result.Y := NumGet(RECT,  4, "Int")
      Result.R := NumGet(RECT,  8, "Int"), Result.B := NumGet(RECT, 12, "Int")
      Result.W := Result.R - Result.X,     Result.H := Result.B - Result.Y
      Return Result
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the maximum number of additional text lines in each tile, not counting the title.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-gettileviewinfo
   GetTileViewLines() {
      Static SizeOfLVTVI := 40, OffLines := 20
      LVTVI := Buffer(SizeOfLVTVI, 0) ; LVTILEVIEWINFO
      NumPut("UInt", SizeOfLVTVI, "UInt", 0x00000002, LVTVI)   ; cbSize, dwMask = LVTVIM_COLUMNS
      DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10A3, "Ptr", 0, "Ptr", LVTVI, "Int")
      Lines := NumGet(LVTVI, OffLines, "Int")
      Return (Lines > 0 ? --Lines : 0)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the index of the topmost visible item when in list or report view.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-gettopindex
   GetTopIndex() {
      Return (DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1027, "Ptr", 0, "Ptr", 0, "Int") + 1)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Retrieves the current view of a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getview
   GetView() {
      Static Views := {0x00: "Icon", 0x01: "Report", 0x02: "IconSmall", 0x03: "List", 0x04: "Tile"}
      View := DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x108F, "Ptr", 0, "Ptr", 0, "UInt")
      Return Views.HasOwnProp(View) ? Views.%View% : ""
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets group information.  !!!Not supported as yet!!!
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getgroupinfo
   ; LVGROUP mask
   ; LVGF_ALIGN              = 0x00000008
   ; LVGF_DESCRIPTIONBOTTOM  = 0x00000800    ; >= Vista  pszDescriptionBottom is valid
   ; LVGF_DESCRIPTIONTOP     = 0x00000400    ; >= Vista  pszDescriptionTop is valid
   ; LVGF_EXTENDEDIMAGE      = 0x00002000    ; >= Vista  iExtendedImage is valid
   ; LVGF_FOOTER             = 0x00000002
   ; LVGF_GROUPID            = 0x00000010
   ; LVGF_HEADER             = 0x00000001
   ; LVGF_ITEMS              = 0x00004000    ; >= Vista  iFirstItem and cItems are valid
   ; LVGF_NONE               = 0x00000000
   ; LVGF_STATE              = 0x00000004
   ; LVGF_SUBSET             = 0x00008000    ; >= Vista  pszSubsetTitle is valid
   ; LVGF_SUBSETITEMS        = 0x00010000    ; >= Vista  readonly, cItems holds count of items in visible subset, iFirstItem is valid
   ; LVGF_SUBTITLE           = 0x00000100    ; >= Vista  pszSubtitle is valid
   ; LVGF_TASK               = 0x00000200    ; >= Vista  pszTask is valid
   ; LVGF_TITLEIMAGE         = 0x00001000    ; >= Vista  iTitleImage is valid
   GroupGetInfo(GroupID, Mask := 0xFFFFFF) {
      Static SizeOfLVGROUP := (4 * 10) + (A_PtrSize * 14)
      Return 0
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Gets the state for a specified group.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-getgroupstate
   ; LVGROUP state:
   ; LVGS_COLLAPSED          = 0x00000001
   ; LVGS_COLLAPSIBLE        = 0x00000008    ; >= Vista ?
   ; LVGS_FOCUSED            = 0x00000010    ; >= Vista ?
   ; LVGS_HIDDEN             = 0x00000002
   ; LVGS_NOHEADER           = 0x00000004    ; >= Vista ?
   ; LVGS_NORMAL             = 0x00000000
   ; LVGS_SELECTED           = 0x00000020    ; >= Vista ?
   ; LVGS_SUBSETED           = 0x00000040    ; >= Vista ?
   ; LVGS_SUBSETLINKFOCUSED  = 0x00000080    ; >= Vista ?
   GroupGetState(GroupID, StateMask := 0xFF) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x105C, "Ptr", GroupID, "Ptr", StateMask & 0xFF, "UInt")
;       Static LVGS := Map("Collapsed", 0x01, "Collapsible", 0x08, "Focused", 0x10, "Hidden", 0x02, "NoHeader", 0x04,
;                          "Normal", 0x00, "Selected", 0x20, "SUBSETED",
;       Static LVGF := 0x04 ; LVGF_STATE
;       Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4)
;       Static OffStateMask := 8 + (A_PtrSize * 3) + 8
;       Static OffState := OffStateMask + 4
;       SetStates := 0
;       LVGS := OS > 5 ? LVGS6 : LVGS5
;       For Each, State In LVGS
;          SetStates |= State
;       VarSetCapacity(LVGROUP, SizeOfLVGROUP, 0)
;       NumPut(SizeOfLVGROUP, LVGROUP, 0, "UInt")
;       NumPut(LVGF, LVGROUP, 4, "UInt")
;       NumPut(SetStates, LVGROUP, OffStateMask, "UInt")
;       SendMessage, 0x1095, %GroupID%, &LVGROUP, , % "ahk_id " . HLV
;       States := NumGet(&LVGROUP, OffState, "UInt")
;       For Each, State in LVGS
;          %Each% := States & State ? True : False
;       Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Inserts a group into a list-view control.
   ; ATM, only group attributes defined for Win XP are supported.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-insertgroup
   GroupInsert(GroupID, Header, Align := "", Index := -1) {
      ; LVM_INSERTGROUP = 0x1091 -> msdn.microsoft.com/en-us/library/bb761103(v=vs.85).aspx
      Static Alignment := {1: 1, 2: 2, 4: 4, C: 2, L: 1, R: 4}
      Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4) ; V5 (Win XP)
      Static OffHeader := 8
      Static OffGroupID := OffHeader + (A_PtrSize * 3) + 4
      Static OffAlign := OffGroupID + 12
      Static LVGF := 0x11 ; LVGF_GROUPID | LVGF_HEADER | LVGF_STATE
      Static LVGF_ALIGN := 0x00000008
      Align := SubStr(Align, 1, 1)
      Align := Alignment.HasOwnProp(Align) ? Alignment.%Align% : 0
      Mask := LVGF | (Align ? LVGF_ALIGN : 0)
      LVGROUP := Buffer(SizeOfLVGROUP, 0)
      NumPut("UInt", SizeOfLVGROUP, "UInt", Mask, LVGROUP)
      NumPut("Ptr", StrPtr(Header), LVGROUP, OffHeader)
      NumPut("Int", GroupID, LVGROUP, OffGroupID)
      NumPut("UInt", Align, LVGROUP, OffAlign)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1091, "Ptr", Index, "Ptr", LVGROUP, "Int")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Removes a group from a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-removegroup
   GroupRemove(GroupID) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1096, "Ptr", GroupID, "Ptr", 0, "Int")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Removes all groups from a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-removeallgroups
   GroupRemoveAll() {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10A0, "Ptr", 0, "Ptr", 0, "Int")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the state for a specified group.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setgroupinfo
   ; LVGROUP state:
   ; LVGS_COLLAPSED          = 0x00000001
   ; LVGS_COLLAPSIBLE        = 0x00000008    ; >= Vista ?
   ; LVGS_FOCUSED            = 0x00000010    ; >= Vista ?
   ; LVGS_HIDDEN             = 0x00000002
   ; LVGS_NOHEADER           = 0x00000004    ; >= Vista ?
   ; LVGS_NORMAL             = 0x00000000
   ; LVGS_SELECTED           = 0x00000020    ; >= Vista ?
   ; LVGS_SUBSETED           = 0x00000040    ; >= Vista ?
   ; LVGS_SUBSETLINKFOCUSED  = 0x00000080    ; >= Vista ?
   GroupSetState(GroupID, StateMask, States) {
      ; LVM_SETGROUPINFO = 0x1093 -> msdn.microsoft.com/en-us/library/bb761167(v=vs.85).aspx
      Static LVGF := 0x04 ; LVGF_STATE
      Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4) ; V5 (Win XP)
      Static OffStateMask := 8 + (A_PtrSize * 3) + 8
      LVGROUP := Buffer(SizeOfLVGROUP, 0)
      NumPut("UInt", SizeOfLVGROUP, "UInt", LVGF, LVGROUP)
      NumPut("UInt", StateMask & 0xFF, "UInt", States & 0xFF, LVGROUP, OffStateMask)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1093, "Ptr", GroupID, "Ptr", LVGROUP, "Int")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Determines whether the list-view control has a specified group.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-hasgroup
   HasGroup(GroupID) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10A1, "Ptr", 0, "Ptr", 0, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Checks whether the list-view control has group view enabled.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-isgroupviewenabled
   IsGroupViewEnabled() {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10AF, "Ptr", 0, "Ptr", 0, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Indicates if a row in the list-view control is checked.
   ; LVIS_CHECKED = 0x2000  ; not defined by MS
   IsRowChecked(Row) {
      Return This.GetItemState(Row, 0x2000)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Indicates if a row in the list-view control is focused.
   ; LVIS_FOCUSED = 0x0001
   IsRowFocused(Row) {
      Return This.GetItemState(Row, 0x0001)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Indicates if a row in the list-view control is selected.
   ; LVIS_SELECTED = 0x0002
   IsRowSelected(Row) {
      Return This.GetItemState(Row, 0x0002)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Indicates if a row in the list-view control is visible.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-isitemvisible
   IsRowVisible(Row) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10B6, "Ptr", Row - 1, "Ptr", 0, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; CommCtrl.h:
   ; // These next to methods make it easy to identify an item that can be repositioned
   ; // within listview. For example: Many developers use the lParam to store an identifier that is
   ; // unique. Unfortunatly, in order to find this item, they have to iterate through all of the items
   ; // in the listview. Listview will maintain a unique identifier.  The upper bound is the size of a DWORD.
   ; -------------------------------------------------------------------------------------------------------------------
   ; Maps the ID of an item to an index.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-mapidtoindex
   MapIDToIndex(ID) {
      Return (DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10B5, "Ptr", ID, "Ptr", 0, "Int") + 1)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Maps the index of an item to an unique ID.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-mapindextoid
   MapIndexToID(Index) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10B4, "Ptr", Index - 1, "Ptr", 0, "Ptr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Forces a list-view control to redraw a range of items.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-redrawitems
   RedrawRows(First := 0, Last := "") {
      If (First > 0) {
         If (Last = "")
            Last := First
      }
      Else {
         First := This.GetTopIndex()
         Last := First + This.GetRowsPerPage() - 1
      }
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1015, "Ptr", First - 1, "Ptr", Last - 1, "UInt") ?
             DllCall("UpdateWindow", "Ptr", This.HWND, "UInt") : False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the background image in a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setbkimage
   ; LVBKIMAGE ulFlags
   ; LVBKIF_FLAG_ALPHABLEND  = 0x20000000
   ; LVBKIF_FLAG_TILEOFFSET  = 0x00000100
   ; LVBKIF_SOURCE_HBITMAP   = 0x00000001
   ; LVBKIF_SOURCE_NONE      = 0x00000000
   ; LVBKIF_SOURCE_URL       = 0x00000002
   ; LVBKIF_STYLE_NORMAL     = 0x00000000
   ; LVBKIF_STYLE_TILE       = 0x00000010
   ; LVBKIF_TYPE_WATERMARK   = 0x10000000
   SetBkImage(Image, Width := "", Height := "") {
      Static XAlign := {C: 50, L: 0, R: 100}, YAlign := {B: 100, C: 50, T: 0}
      HBITMAP := 0
      If IsInteger(Image)
         HBITMAP := Image
      Else If FileExist(Image) {
         If (Width = "") && (Height = "") {
            RECT := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", This.HWND, "Ptr", RECT)
            Width := NumGet(RECT, 8, "Int"), Height := NumGet(RECT, 12, "Int")
         }
         Else If (Width = "")
            Width := -1
         Else If (Height = "")
            Height := -1
         HBITMAP := LoadPicture(Image, "GDI+ w" . Width . " h" . Height)
      }
      If !(HBITMAP) && (Image != 0)
         Return False
      ; Set extended style LVS_EX_DOUBLEBUFFER to avoid drawing issues
      This.SetExtendedStyle(0x00010000, 0x00010000) ; LVS_EX_DOUBLEBUFFER = 0x00010000
      Flags := (Image = 0) ? 0x10000000 : 0x30000000 ; LVBKIF_TYPE_WATERMARK | LVBKIF_FLAG_ALPHABLEND
      SizeOfLVBKIMAGE :=  (4 * 2) + (A_PtrSize * 4)
      LVBKIMAGE := Buffer(SizeOfLVBKIMAGE, 0)
      NumPut("UInt", Flags, LVBKIMAGE), NumPut("UPtr", HBITMAP, LVBKIMAGE, A_PtrSize)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x108A, "Ptr", 0, "Ptr", LVBKIMAGE, "Ptr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the left-to-right order of columns in a list-view control.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setcolumnorderarray
   SetColumnOrder(ColArray) {
      Cols := ColArray.Length
      COA := Buffer(Cols * 4, 0)
      Addr := COA.Ptr
      For I, C In ColArray
         Addr := NumPut("Int", C - 1, Addr)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x103A, "Ptr", Cols, "Ptr", COA, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets extended styles in list-view controls.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setextendedlistviewstyle
   SetExtendedStyle(StyleMask, Styles) {
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1036, "Ptr", StyleMask, "Ptr", Styles, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Assigns a list-view item to an existing group.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setitem
   ; ======================================================================================================================
   SetGroup(Row, GroupID) {
      Static OffGroupID := 28 + (A_PtrSize * 3)
      This.Create_LVITEM(&LVITEM, 0x00000100, Row) ; LVIF_GROUPID
      NumPut("Int", GroupID, LVITEM, OffGroupID)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104C, "Ptr", 0, "Ptr", LVITEM, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the spacing between icons in the icon view.
   SetIconSpacing(CX, CY) {
      If (CX < 4) && (CX != -1)
         CX := 4
      If (CY < 4) && (CY != -1)
         CY := 4
      XY := (CX & 0xFFFF) | ((CY & 0xFFFF) << 16)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1035, "Ptr", 0, "Ptr", XY, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the indent of the first column to the specified number of icon widths.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setitem
   SetItemIndent(Row, NumIcons) {
      Static OffIndent := 24 + (A_PtrSize * 3)
      This.Create_LVITEM(&LVITEM, 0x00000010, Row) ; LVIF_INDENT
      NumPut("Int", NumIcons, LVITEM, OffIndent)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104C, "Ptr", 0, "Ptr", LVITEM, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the lParam field of the item to the specified value.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setitem
   SetItemParam(Row, Value) {
      Static OffParam := 24 + (A_PtrSize * 2)
      This.Create_LVITEM(&LVITEM, 0x00000004, Row) ; LVIF_PARAM
      NumPut("Ptr", Value, LVITEM, OffParam)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104C, "Ptr", 0, "Ptr", LVITEM, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Assigns an image from the list-view's image list to this subitem.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-setitem
   SetSubItemImage(Row, Column, Index) {
      Static OffImage := 20 + (A_PtrSize * 2)
      This.SetExtendedStyle(0x00000002, 0x00000002) ; LVS_EX_SUBITEMIMAGES = 0x00000002
      This.Create_LVITEM(&LVITEM, 0x00000002, Row, Column) ; LVIF_IMAGE
      NumPut("Int", Index - 1, LVITEM, OffImage)
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104C, "Ptr", 0, "Ptr", LVITEM, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the additional columns displayed for this tile, and the order of those columns.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-settileinfo
   SetTileInfo(Row, Columns*) {
      ; Row      : The 1-based row number. If you specify a number less than 1, the tile info will be set for all rows.
      ; Colomns* : Array of column indices, specifying which columns are displayed for this item, and the order of those
      ;            columns. Indices should be greater than 1, because column 1, the item name, is already displayed.
      Static SizeOfLVTI := (4 * 2) + (A_PtrSize * 3)
      Static OffItem := 4
      Static OffCols := 8
      Static OffColArr := OffCols + A_PtrSize
      ColCount := Columns.Length
      Lines := This.GetTileViewLines()
      If ((Row = 0) && (ColCount != Lines)) || ((Row != 0) && (ColCount >= Lines))
         This.SetTileViewLines(ColCount)
      ColArr := Buffer(4 * (ColCount + 1), 0)
      Addr := ColArr.Ptr
      For I, Column In Columns
         Addr := NumPut("UInt", Column - 1, Addr)
      LVTI := Buffer(SizeOfLVTI, 0)                ; LVTILEINFO
      NumPut("UInt", SizeOfLVTI, LVTI)             ; cbSize
      NumPut("UInt", ColCount, LVTI, OffCols)      ; cColumns
      NumPut("Ptr", ColArr.Ptr, LVTI, OffColArr)   ; puColumns
      If (Row > 0) {
         NumPut("Int", Row - 1, LVTI, OffItem) ; iItem
         Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10A4, "Ptr", 0, "Ptr", LVTI, "UInt") ; LVM_SETTILEINFO
      }
      Loop This.GetCount() {
         NumPut("Int", A_Index - 1, LVTI, OffItem) ; iItem
         If !DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10A4, "Ptr", 0, "Ptr", LVTI, "UInt")
            Return False
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sets the maximum number of additional text lines in each tile, not counting the title.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-settileviewinfo
   ; Lines : Maximum number of text lines in each item label, not counting the title.
   ; One line is added internally because the item might be wrapped to two lines!
   SetTileViewLines(Lines) {
      Static SizeOfLVTVI := 40
      Static OffLines := 20
      If (Lines > 0)
         Lines++
      LVTVI := Buffer(SizeOfLVTVI, 0)      ; LVTILEVIEWINFO
      NumPut("UInt", SizeOfLVTVI, "UInt", 0x00000003, LVTVI)     ; cbSize , dwMask = LVTVIM_TILESIZE | LVTVIM_COLUMNS
      NumPut("Int", Lines, LVTVI, OffLines) ; c_lines: max lines below first line
      Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x10A2, "Ptr", 0, "Ptr", LVTVI, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Determines which list-view item or subitem is at a given position.
   ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-subitemhittest
   SubItemHitTest(X := -1, Y := -1) {
      ; LVM_SUBITEMHITTEST = 0x1039 -> http://msdn.microsoft.com/en-us/library/bb761229(v=vs.85).aspx
      LVHTI := Buffer(24, 0) ; LVHITTESTINFO
      If (X = -1) || (Y = -1) {
         DllCall("GetCursorPos", "Ptr", &LVHTI)
         DllCall("ScreenToClient", "Ptr", This.HWND, "Ptr", &LVHTI)
      }
      Else
         NumPut("Int", X, "Int", Y, LVHTI)
      Return (DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x1039, "Ptr", 0, "Ptr", LVHTI, "Int") < 0) ?
             0 : NumGet(LVHTI, 16, "Int") + 1
   }
   ; ===================================================================================================================
   ; Methods for internal use
   ; ===================================================================================================================
   Create_LVITEM(&LVITEM, Mask := 0, Row := 1, Col := 1) {
      Static LVITEMSize := 48 + (A_PtrSize * 3)
      LVITEM := Buffer(LVITEMSize, 0)
      NumPut("UInt", Mask, "Int", Row - 1, "Int", Col - 1, LVITEM)
   }
}

; ----------------------------------------------------------------------------------------------------------------------
; ======================================================================================================================
; Namespace:      LV_Colors
; Function:       Individual row and cell coloring for AHK ListView controls.
; Tested with:    AHK 2.0.2 (U32/U64)
; Tested on:      Win 10 (x64)
; Changelog:      2023-01-04/2.0.0/just me   Initial release of the AHK v2 version
; ======================================================================================================================
; CLASS LV_Colors
;
; The class provides methods to set individual colors for rows and/or cells, to clear all colors, to prevent/allow
; sorting and rezising of columns dynamically, and to deactivate/activate the notification handler for NM_CUSTOMDRAW
; notifications (see below).
;
; A message handler for NM_CUSTOMDRAW notifications will be activated for the specified ListView whenever a new
; instance is created. If you want to temporarily disable coloring call MyInstance.ShowColors(False). This must
; be done also before you try to destroy the instance. To enable it again, call MyInstance.ShowColors().
;
; To avoid the loss of Gui events and messages the message handler is set 'critical'. To prevent 'freezing' of the
; list-view or the whole GUI this script requires AHK v2.0.1+.
; ======================================================================================================================
Class LV_Colors {
   ; ===================================================================================================================
   ; __New()         Constructor - Create a new LV_Colors instance for the given ListView
   ; Parameters:     HWND        -  ListView's HWND.
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 StaticMode  -  Static color assignment, i.e. the colors will be assigned permanently to the row
   ;                                contents rather than to the row number.
   ;                                Values:  True/False
   ;                                Default: False
   ;                 NoSort      -  Prevent sorting by click on a header item.
   ;                                Values:  True/False
   ;                                Default: False
   ;                 NoSizing    -  Prevent resizing of columns.
   ;                                Values:  True/False
   ;                                Default: False
   ; ===================================================================================================================
   __New(LV, StaticMode := False, NoSort := False, NoSizing := False) {
      ;If (LV.Type != "ListView")
         ;Throw TypeError("LV_Colors requires a ListView control!", -1, LV.Type)
      ; ----------------------------------------------------------------------------------------------------------------
      ; Set LVS_EX_DOUBLEBUFFER (0x010000) style to avoid drawing issues.
      LV.Opt("+LV0x010000")
      ; Get the default colors
      BkClr := SendMessage(0x1025, 0, 0, LV) ; LVM_GETTEXTBKCOLOR
      TxClr := SendMessage(0x1023, 0, 0, LV) ; LVM_GETTEXTCOLOR
      ; Get the header control
      Header := SendMessage(0x101F, 0, 0, LV) ; LVM_GETHEADER
      ; Set other properties
      This.LV := LV
      This.HWND := LV.HWND
      This.Header := Header
      This.BkClr := BkCLr
      This.TxClr := Txclr
      This.IsStatic := !!StaticMode
      This.AltCols := False
      This.AltRows := False
      This.SelColors := False
      This.NoSort(!!NoSort)
      This.NoSizing(!!NoSizing)
      This.ShowColors()
      This.RowCount := LV.GetCount()
      This.ColCount := LV.GetCount("Col")
      This.Rows := Map()
      This.Rows.Capacity := This.RowCount
      This.Cells := Map()
      This.Cells.Capacity := This.RowCount
   }
   ; ===================================================================================================================
   ; __Delete()      Destructor
   ; ===================================================================================================================
   __Delete() {
      This.ShowColors(False)
      If WinExist(This.HWND)
         WinRedraw(This.HWND)
   }
   ; ===================================================================================================================
   ; Clear()         Clears all row and cell colors.
   ; Parameters:     AltRows     -  Reset alternate row coloring (True / False)
   ;                                Default: False
   ;                 AltCols     -  Reset alternate column coloring (True / False)
   ;                                Default: False
   ; Return Value:   Always True.
   ; ===================================================================================================================
   Clear(AltRows := False, AltCols := False) {
      If (AltCols)
         This.AltCols := False
      If (AltRows)
         This.AltRows := False
      This.Rows.Clear()
      This.Rows.Capacity := This.RowCount
      This.Cells.Clear()
      This.Cells.Capacity := This.RowCount
      Return True
   }
   ; ===================================================================================================================
   ; UpdateProps()   Updates the RowCount, ColCount, BkClr, and TxClr properties.
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   UpdateProps() {
      If !(This.HWND)
         Return False
      This.BkClr := SendMessage(0x1025, 0, 0, This.LV) ; LVM_GETTEXTBKCOLOR
      This.TxClr := SendMessage(0x1023, 0, 0, This.LV) ; LVM_GETTEXTCOLOR
      This.RowCount := This.LV.GetCount()
      This.Colcount := This.LV.GetCount("Col")
      If WinExist(This.HWND)
         WinRedraw(This.HWND)
      Return True
   }
   ; ===================================================================================================================
   ; AlternateRows() Sets background and/or text color for even row numbers.
   ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   AlternateRows(BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.AltRows := False
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      This.ARB := (BkBGR != "") ? BkBGR : This.BkClr
      This.ART := (TxBGR != "") ? TxBGR : This.TxClr
      This.AltRows := True
      Return True
   }
   ; ===================================================================================================================
   ; AlternateCols() Sets background and/or text color for even column numbers.
   ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   AlternateCols(BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.AltCols := False
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      This.ACB := (BkBGR != "") ? BkBGR : This.BkClr
      This.ACT := (TxBGR != "") ? TxBGR : This.TxClr
      This.AltCols := True
      Return True
   }
   ; ===================================================================================================================
   ; SelectionColors() Sets background and/or text color for selected rows.
   ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default selected background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default selected text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   SelectionColors(BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.SelColors := False
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      This.SELB := BkBGR
      This.SELT := TxBGR
      This.SelColors := True
      Return True
   }
   ; ===================================================================================================================
   ; Row()           Sets background and/or text color for the specified row.
   ; Parameters:     Row         -  Row number
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   Row(Row, BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      If (Row >This.RowCount)
         Return False
      If This.IsStatic
         Row := This.MapIndexToID(Row)
      If This.Rows.Has(Row)
         This.Rows.Delete(Row)
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      ; Colors := {B: (BkBGR != "") ? BkBGR : This.BkClr, T: (TxBGR != "") ? TxBGR : This.TxClr}
      This.Rows[Row] := Map("B", (BkBGR != "") ? BkBGR : This.BkClr, "T", (TxBGR != "") ? TxBGR : This.TxClr)
      Return True
   }
   ; ===================================================================================================================
   ; Cell()          Sets background and/or text color for the specified cell.
   ; Parameters:     Row         -  Row number
   ;                 Col         -  Column number
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> row's background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> row's text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   Cell(Row, Col, BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      If (Row > This.RowCount) || (Col > This.ColCount)
         Return False
      If This.IsStatic
         Row := This.MapIndexToID(Row)
      If This.Cells.Has(Row) && This.Cells[Row].Has(Col)
         This.Cells[Row].Delete(Col)
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      If !This.Cells.Has(Row)
         This.Cells[Row] := [], This.Cells[Row].Capacity := This.ColCount
      If (Col > This.Cells[Row].Length)
         This.Cells[Row].Length := Col
      This.Cells[Row][Col] := Map("B", (BkBGR != "") ? BkBGR : This.BkClr, "T", (TxBGR != "") ? TxBGR : This.TxClr)
      Return True
   }
   ; ===================================================================================================================
   ; NoSort()        Prevents/allows sorting by click on a header item for this ListView.
   ; Parameters:     Apply       -  True/False
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   NoSort(Apply := True) {
      If !(This.HWND)
         Return False
      This.LV.Opt((Apply ? "+" : "-") . "NoSort")
      Return True
   }
   ; ===================================================================================================================
   ; NoSizing()      Prevents/allows resizing of columns for this ListView.
   ; Parameters:     Apply       -  True/False
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   NoSizing(Apply := True) {
      If !(This.Header)
         Return False
      ControlSetStyle((Apply ? "+" : "-") . "0x0800", This.Header) ; HDS_NOSIZING = 0x0800
      Return True
   }
   ; ===================================================================================================================
   ; ShowColors()    Adds/removes a message handler for NM_CUSTOMDRAW notifications of this ListView.
   ; Parameters:     Apply       -  True/False
   ; Return Value:   Always True
   ; ===================================================================================================================
   ShowColors(Apply := True) {
      If (Apply) && !This.HasOwnProp("OnNotifyFunc") {
         This.OnNotifyFunc := ObjBindMethod(This, "NM_CUSTOMDRAW")
         This.LV.OnNotify(-12, This.OnNotifyFunc)
         WinRedraw(This.HWND)
      }
      Else If !(Apply) && This.HasOwnProp("OnNotifyFunc") {
         This.LV.OnNotify(-12, This.OnNotifyFunc, 0)
         This.OnNotifyFunc := ""
         This.DeleteProp("OnNotifyFunc")
         WinRedraw(This.HWND)
      }
      Return True
   }
   ; ===================================================================================================================
   ; Internally used/called Methods
   ; ===================================================================================================================
   NM_CUSTOMDRAW(LV, L) {
      ; Return values: 0x00 (CDRF_DODEFAULT), 0x20 (CDRF_NOTIFYITEMDRAW / CDRF_NOTIFYSUBITEMDRAW)
      Static SizeNMHDR := A_PtrSize * 3                  ; Size of NMHDR structure
      Static SizeNCD := SizeNMHDR + 16 + (A_PtrSize * 5) ; Size of NMCUSTOMDRAW structure
      Static OffItem := SizeNMHDR + 16 + (A_PtrSize * 2) ; Offset of dwItemSpec (NMCUSTOMDRAW)
      Static OffItemState := OffItem + A_PtrSize         ; Offset of uItemState  (NMCUSTOMDRAW)
      Static OffCT :=  SizeNCD                           ; Offset of clrText (NMLVCUSTOMDRAW)
      Static OffCB := OffCT + 4                          ; Offset of clrTextBk (NMLVCUSTOMDRAW)
      Static OffSubItem := OffCB + 4                     ; Offset of iSubItem (NMLVCUSTOMDRAW)
      Critical -1
      If !(This.HWND) || (NumGet(L, "UPtr") != This.HWND)
         Return
      ; ----------------------------------------------------------------------------------------------------------------
      DrawStage := NumGet(L + SizeNMHDR, "UInt"),
      Row := NumGet(L + OffItem, "UPtr") + 1,
      Col := NumGet(L + OffSubItem, "Int") + 1,
      Item := Row - 1
      If This.IsStatic
         Row := This.MapIndexToID(Row)
      ; CDDS_SUBITEMPREPAINT = 0x030001 --------------------------------------------------------------------------------
      If (DrawStage = 0x030001) {
         UseAltCol := (This.AltCols) && !(Col & 1),
         ColColors := (This.Cells.Has(Row) && This.Cells[Row].Has(Col)) ? This.Cells[Row][Col] : Map("B", "", "T", ""),
         ColB := (ColColors["B"] != "") ? ColColors["B"] : UseAltCol ? This.ACB : This.RowB,
         ColT := (ColColors["T"] != "") ? ColColors["T"] : UseAltCol ? This.ACT : This.RowT,
         NumPut("UInt", ColT, L + OffCT), NumPut("UInt", ColB, L + OffCB)
         Return (!This.AltCols && (Col > This.Cells[Row].Length)) ? 0x00 : 0x020
      }
      ; CDDS_ITEMPREPAINT = 0x010001 -----------------------------------------------------------------------------------
      If (DrawStage = 0x010001) {
         ; LVM_GETITEMSTATE = 0x102C, LVIS_SELECTED = 0x0002
         If (This.SelColors) && SendMessage(0x102C, Item, 0x0002, This.HWND) {
            ; Remove the CDIS_SELECTED (0x0001) and CDIS_FOCUS (0x0010) states from uItemState and set the colors.
            NumPut("UInt", NumGet(L + OffItemState, "UInt") & ~0x0011, L + OffItemState)
            If (This.SELB != "")
               NumPut("UInt", This.SELB, L + OffCB)
            If (This.SELT != "")
               NumPut("UInt", This.SELT, L + OffCT)
            Return 0x02 ; CDRF_NEWFONT
         }
         UseAltRow := This.AltRows && (Item & 1),
         RowColors := This.Rows.Has(Row) ? This.Rows[Row] : "",
         This.RowB := RowColors ? RowColors["B"] : UseAltRow ? This.ARB : This.BkClr,
         This.RowT := RowColors ? RowColors["T"] : UseAltRow ? This.ART : This.TxClr
         If (This.AltCols || This.Cells.Has(Row))
            Return 0x20
         NumPut("UInt", This.RowT, L + OffCT), NumPut("UInt", This.RowB, L + OffCB)
         Return 0x00
      }
      ; CDDS_PREPAINT = 0x000001 ---------------------------------------------------------------------------------------
      Return (DrawStage = 0x000001) ? 0x20 : 0x00
   }
   ; -------------------------------------------------------------------------------------------------------------------
   MapIndexToID(Row) { ; provides the unique internal ID of the given row number
      Return SendMessage(0x10B4, Row - 1, 0, This.HWND) ; LVM_MAPINDEXTOID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   BGR(Color, Default := "") { ; converts colors to BGR
      ; HTML Colors (BGR)
      Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                    , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                    , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
      If IsInteger(Color)
         Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
      Return (HTML.HasOwnProp(Color) ? HTML[Color] : Default)
   }
}
