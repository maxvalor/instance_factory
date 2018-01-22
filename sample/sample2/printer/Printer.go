package printer

import "github.com/maxvalor/instancefactory/sample/sample2/extcontext"

type Printer interface {
	Print(content string)
}

var Class = extcontext.GetClassName()
