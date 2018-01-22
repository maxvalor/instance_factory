package printerb

import "github.com/maxvalor/instancefactory/sample/sample3/extcontext"

type PrinterB interface {
	Print(content string)
}

var Class = extcontext.GetClassName()
