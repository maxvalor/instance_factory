package impl

import (
	"github.com/maxvalor/instancefactory"
	"github.com/maxvalor/instancefactory/sample/sample3/printera"
)

type PrinterBImpl struct {
	
}

func (p *PrinterBImpl) Print(content string)  {
	instancefactory.GetFactory().GetStructImpl(printera.Class).(printera.PrinterA).PrintTwice(content)
}
