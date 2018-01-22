package impl

import "fmt"

type PrinterImpl struct /* implements sample1.printer.intf.Printer */ {
	
}

func (p *PrinterImpl) Print(content string)  {
	fmt.Println(content)
}
