COMMENT #
===============================================================================
 fontexp.inc
===============================================================================
#

		IFDEF	$DSPX$FONTEXP
		
		PUBLIC	FONTEXP_TABLE, FONTEXP_COUNT
		
		ELSE
		
		EXTRN	FONTEXP_TABLE:tFont
		EXTRN	FONTEXP_COUNT:ABS
		
		ENDIF
