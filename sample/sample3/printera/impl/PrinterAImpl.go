package impl

import (
	"fmt"
	"github.com/maxvalor/instancefactory"
	"github.com/maxvalor/instancefactory/sample/sample3/printerb"
)

type PrinterAImpl struct {
	
}

func (p *PrinterAImpl) Print(content string)  {
	instancefactory.GetFactory().GetStructImpl(printerb.Class).(printerb.PrinterB).Print(content)
}

func (p *PrinterAImpl) PrintTwice(content string)  {
	fmt.Println("The first time:" + content)
	fmt.Println("The second time:" + content)
}
