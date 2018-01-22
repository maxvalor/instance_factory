package printera

import "github.com/maxvalor/instancefactory/sample/sample3/extcontext"

type PrinterA interface {
	Print(content string)
	PrintTwice(content string)
}

var Class = extcontext.GetClassName()
